from typing import Dict, Any, Optional, List

from app.common.exceptions import ValidationError
from app.domain.celebrity.models import Celebrity
from app.infrastructure.database.repositories.celebrity_repository import celebrity_repository
from app.domain.saju_core.saju_calculator import SajuCalculator
from app.domain.saju_core.data_validator import DataValidator
from app.domain.saju_core.personality_analyzer import PersonalityAnalyzer
from app.domain.saju_core.character_system import CharacterSystem


class CelebrityService:
    def __init__(
        self,
        repository=celebrity_repository,
        calculator: Optional[SajuCalculator] = None,
    ) -> None:
        self.repository = repository
        self.calculator = calculator or SajuCalculator(
            validator=DataValidator(),
            analyzer=PersonalityAnalyzer(),
            characters=CharacterSystem(),
        )

    def list_celebrities(self, keyword: Optional[str] = None) -> List[Dict[str, Any]]:
        celebs = self.repository.list(keyword)
        return [self._celebrity_summary(c) for c in celebs]

    def get_celebrity(self, celebrity_id: int) -> Dict[str, Any]:
        celeb = self._require_celebrity(celebrity_id)
        return celeb.to_dict()

    def calculate_with_celebrity(
        self,
        user_saju: Dict[str, str],
        celebrity_id: int,
        user_gender: int = 0,
    ) -> Dict[str, Any]:
        celeb = self._require_celebrity(celebrity_id)
        scores = self.calculator.calculate_compatibility(
            user_saju,
            celeb.saju,
            gender1=user_gender,
            gender2=celeb.gender,
        )
        return {
            "celebrity": self._celebrity_summary(celeb),
            "scores": scores,
            "description": self._describe(scores["final"]),
        }

    def get_compatibility_description(self, scores: Dict[str, float]) -> str:
        final = scores.get("final", 0.0)
        return self._describe(final)

    def _celebrity_summary(self, celeb: Celebrity) -> Dict[str, Any]:
        data = celeb.to_dict()
        data.pop("saju", None)
        return data

    def _require_celebrity(self, celebrity_id: int) -> Celebrity:
        celeb = self.repository.get_by_id(celebrity_id)
        if celeb is None:
            raise ValidationError(f"ID {celebrity_id} 유명인을 찾을 수 없습니다.")
        return celeb

    def _describe(self, final_score: float) -> str:
        if final_score >= 85:
            return "매우 좋은 궁합입니다. 서로의 강점을 크게 북돋울 수 있어요."
        if final_score >= 70:
            return "좋은 궁합이에요. 공통점을 살리면 안정적인 관계가 가능합니다."
        if final_score >= 55:
            return "보통 수준의 궁합입니다. 배려와 대화가 중요합니다."
        return "다소 어려운 궁합입니다. 차이를 이해하고 조율하는 노력이 필요합니다."
