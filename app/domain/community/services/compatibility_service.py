from __future__ import annotations

import json
from typing import Dict, Any, Optional

from app.common.exceptions import NotFoundError, ValidationError, AuthorizationError
from app.domain.saju_core.character_system import CharacterSystem
from app.domain.saju_core.data_validator import DataValidator
from app.domain.saju_core.personality_analyzer import PersonalityAnalyzer
from app.domain.saju_core.saju_calculator import SajuCalculator
from app.infrastructure.database.repositories.compatibility_repository import compatibility_repository
from app.infrastructure.database.repositories.notification_repository import notification_repository
from app.infrastructure.database.repositories.user_repository import user_repository
from app.infrastructure.database.repositories.friend_repository import friend_repository


class CompatibilityService:
    def __init__(
        self,
        compatibility_repo=compatibility_repository,
        user_repo=user_repository,
        notification_repo=notification_repository,
        calculator: Optional[SajuCalculator] = None,
        friend_repo=friend_repository,
    ) -> None:
        self.compatibility_repo = compatibility_repo
        self.users = user_repo
        self.notifications = notification_repo
        self.friendships = friend_repo
        self.calculator = calculator or SajuCalculator(
            validator=DataValidator(),
            analyzer=PersonalityAnalyzer(),
            characters=CharacterSystem(),
        )

    def request_compatibility(self, requester_id: int, target_id: int, message: str | None = None) -> int:
        if requester_id == target_id:
            raise ValidationError("본인에게 궁합을 요청할 수 없습니다.")
        requester = self._require_user(requester_id)
        target = self._require_user(target_id)
        if not self.friendships.are_friends(requester_id, target_id):
            raise ValidationError("친구에게만 궁합 요청을 보낼 수 있습니다.")
        request_id = self.compatibility_repo.create(
            requester_id=requester["user_id"],
            target_id=target["user_id"],
            message=message,
        )
        if self.notifications:
            self.notifications.create(
                user_id=target["user_id"],
                notification_type="compatibility_requested",
                payload={"request_id": request_id, "from_user_id": requester["user_id"]},
            )
        return request_id

    def accept_compatibility(self, request_id: int, actor_id: int, accept: bool) -> Optional[Dict[str, Any]]:
        record = self.compatibility_repo.get(request_id)
        if not record:
            raise NotFoundError("궁합 요청을 찾을 수 없습니다.")
        if record.get("status") and record["status"] != "pending":
            raise ValidationError("이미 처리된 요청입니다.")
        if actor_id != record["target_id"]:
            raise AuthorizationError("요청 대상자만 응답할 수 있습니다.")

        description = "요청이 거절되었습니다."
        scores: Optional[Dict[str, float]] = None
        if accept:
            requester = self._require_user(record["requester_id"])
            target = self._require_user(record["target_id"])
            scores = self.calculator.calculate_compatibility(
                self._load_saju(requester),
                self._load_saju(target),
                gender1=requester.get("gender") or 0,
                gender2=target.get("gender") or 0,
            )
            description = self._build_description(scores["final"])

        self.compatibility_repo.set_response(
            request_id=request_id,
            accept=accept,
            scores=scores,
            description=description,
        )
        if self.notifications:
            self.notifications.create(
                user_id=record["requester_id"],
                notification_type="compatibility_resolved",
                payload={"request_id": request_id, "accept": accept},
            )
        return self.compatibility_repo.get(request_id)

    def get_request(self, request_id: int) -> Dict[str, Any]:
        record = self.compatibility_repo.get(request_id)
        if not record:
            raise NotFoundError(f"궁합 요청(ID: {request_id})을 찾을 수 없습니다.")
        return record

    def calculate_for_users(self, user_id_1: int, user_id_2: int) -> Dict[str, float]:
        user_a = self._require_user(user_id_1)
        user_b = self._require_user(user_id_2)
        return self.calculator.calculate_compatibility(
            self._load_saju(user_a),
            self._load_saju(user_b),
            gender1=user_a.get("gender") or 0,
            gender2=user_b.get("gender") or 0,
        )

    def _require_user(self, user_id: int) -> Dict[str, Any]:
        user = self.users.get_by_id(user_id)
        if not user:
            raise NotFoundError(f"사용자(ID: {user_id})를 찾을 수 없습니다.")
        return user

    def _load_saju(self, user: Dict[str, Any]) -> Dict[str, Any]:
        raw = user.get("saju_data")
        if not raw:
            raise ValidationError(f"{user.get('username', '사용자')}의 사주 정보가 필요합니다.")
        try:
            return json.loads(raw)
        except json.JSONDecodeError as exc:
            raise ValidationError("사주 데이터 형식이 올바르지 않습니다.") from exc

    def _build_description(self, final_score: float) -> str:
        if final_score >= 85:
            return "궁합이 매우 좋습니다. 안정적인 관계가 기대됩니다."
        if final_score >= 70:
            return "좋은 궁합입니다. 서로의 장점을 살려보세요."
        if final_score >= 55:
            return "보통 궁합입니다. 소통과 배려가 필요합니다."
        return "상대적으로 어려운 궁합입니다. 충분한 이해와 노력이 요구됩니다."


