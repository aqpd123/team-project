from __future__ import annotations

import json
from typing import Dict, Any, Optional

import pytest

from app.domain.community.services.compatibility_service import CompatibilityService
from app.common.exceptions import ValidationError


class FakeCompatibilityRepository:
    def __init__(self) -> None:
        self._rows: Dict[int, Dict[str, Any]] = {}
        self._pk = 1

    def create(self, requester_id: int, target_id: int, message: str | None = None) -> int:
        request_id = self._pk
        self._pk += 1
        self._rows[request_id] = {
            "request_id": request_id,
            "requester_id": requester_id,
            "target_id": target_id,
            "request_message": message,
            "status": "pending",
        }
        return request_id

    def set_response(self, request_id: int, accept: bool, scores: Optional[Dict[str, float]], description: str | None) -> None:
        row = self._rows[request_id]
        row["status"] = "accepted" if accept else "rejected"
        row["result_final"] = scores.get("final") if scores else None
        row["compatibility_result"] = description

    def get(self, request_id: int) -> Dict[str, Any] | None:
        return self._rows.get(request_id)


class FakeUserRepository:
    def __init__(self) -> None:
        base_saju = json.dumps({"year": "갑자", "month": "을축", "day": "병인"})
        self._rows = {
            1: {"user_id": 1, "username": "u1", "saju_data": base_saju, "gender": 1},
            2: {"user_id": 2, "username": "u2", "saju_data": base_saju, "gender": 0},
        }

    def get_by_id(self, user_id: int) -> Dict[str, Any] | None:
        return self._rows.get(user_id)


class FakeNotificationRepository:
    def __init__(self) -> None:
        self.calls = []

    def create(self, user_id: int, notification_type: str, payload: Dict[str, Any]) -> int:
        self.calls.append({"user_id": user_id, "type": notification_type, "payload": payload})
        return len(self.calls)


class FakeCalculator:
    def calculate_compatibility(self, saju1, saju2, gender1: int, gender2: int):
        return {"original": 75.0, "final": 80.0, "stress": 10.0}


class FakeFriendRepository:
    def __init__(self, friends: Optional[set[tuple[int, int]]] = None) -> None:
        if friends is None:
            friends = {(1, 2), (2, 1)}
        self.friends = friends

    def are_friends(self, user_id: int, other_id: int) -> bool:
        return (user_id, other_id) in self.friends or (other_id, user_id) in self.friends


def test_request_and_accept_flow() -> None:
    svc = CompatibilityService(
        compatibility_repo=FakeCompatibilityRepository(),
        user_repo=FakeUserRepository(),
        notification_repo=FakeNotificationRepository(),
        calculator=FakeCalculator(),
        friend_repo=FakeFriendRepository(),
    )
    req_id = svc.request_compatibility(requester_id=1, target_id=2, message="hi")
    assert req_id == 1
    pending = svc.get_request(req_id)
    assert pending["status"] == "pending"
    result = svc.accept_compatibility(request_id=req_id, actor_id=2, accept=True)
    assert result is not None
    assert result["status"] == "accepted"
    assert result["result_final"] == 80.0


def test_request_rejected_when_not_friend() -> None:
    svc = CompatibilityService(
        compatibility_repo=FakeCompatibilityRepository(),
        user_repo=FakeUserRepository(),
        notification_repo=FakeNotificationRepository(),
        calculator=FakeCalculator(),
        friend_repo=FakeFriendRepository(friends=set()),
    )
    with pytest.raises(ValidationError):
        svc.request_compatibility(requester_id=1, target_id=2, message=None)


