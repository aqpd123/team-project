from typing import Dict, Any, Optional, List

from app.common.exceptions import ValidationError
from app.domain.celebrity.models import Celebrity
from app.infrastructure.database.repositories.celebrity_repository import celebrity_repository
from app.domain.saju_core.saju_calculator import SajuCalculator
from app.domain.saju_core.data_validator import DataValidator
from app.domain.saju_core.personality_analyzer import PersonalityAnalyzer
from app.domain.saju_core.character_system import CharacterSystem
from app.infrastructure.external.gemini_client import get_gemini_client


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
        use_ai: bool = True,
    ) -> Dict[str, Any]:
        celeb = self._require_celebrity(celebrity_id)
        scores = self.calculator.calculate_compatibility(
            user_saju,
            celeb.saju,
            gender1=user_gender,
            gender2=celeb.gender,
        )
        
        # 점수 아래 설명은 항상 기본 설명 사용 (AI 사용 안 함)
        description = self._describe(scores["final"])
        
        # 카테고리별 인사이트는 AI로 생성 시도 (use_ai가 True인 경우만)
        insights = {}
        
        if use_ai:
            try:
                gemini = get_gemini_client()
                celeb_summary = self._celebrity_summary(celeb)
                user_element = self.calculator.determine_character_type(user_saju)
                user_element_kr = {
                    "wood": "목", "fire": "화", "earth": "토",
                    "metal": "금", "water": "수"
                }.get(user_element, "알 수 없음")
                
                # 카테고리별 인사이트 생성
                for category in ["연애", "우정", "직장"]:
                    try:
                        insight = gemini.generate_insight_description(
                            category=category,
                            celebrity_name=celeb.name,
                            scores=scores,
                            user_element=user_element_kr,
                            celebrity_element=celeb_summary.get("element"),
                        )
                        if insight:
                            insights[category] = insight
                    except Exception as e:
                        print(f"⚠️ 인사이트 생성 실패 ({category}): {e}")
                        continue
            except Exception as e:
                print(f"⚠️ AI 인사이트 생성 실패: {e}")
                import traceback
                traceback.print_exc()
        
        # 기본 인사이트 (AI가 실패한 경우)
        if not insights:
            celeb_name = celeb.name
            insights = {
                "연애": f'{celeb_name}님과는 서로의 감정을 섬세하게 공감할 수 있어요. 감성적인 면이 잘 맞아 부드러운 관계가 기대됩니다.',
                "우정": '같은 목표를 향해 나아갈 때 협력 관계가 빛을 발합니다. 진솔한 대화를 자주 나누면 서로에게 든든한 친구가 되어줄 수 있어요.',
                "직장": '서로의 장점을 살려 시너지를 낼 수 있는 관계입니다. 업무에서도 좋은 파트너가 될 수 있어요.',
            }
        
        return {
            "celebrity": self._celebrity_summary(celeb),
            "scores": scores,
            "description": description,
            "insights": insights,
        }

    def get_compatibility_description(self, scores: Dict[str, float]) -> str:
        final = scores.get("final", 0.0)
        return self._describe(final)

    def _celebrity_summary(self, celeb: Celebrity) -> Dict[str, Any]:
        data = celeb.to_dict()
        # 사주에서 오행 계산하여 character_type 추가
        character_type = self.calculator.determine_character_type(celeb.saju)
        data.pop("saju", None)
        data["character_type"] = character_type
        # 영어 오행 키를 한글 오행으로 변환
        element_map = {
            "wood": "목",
            "fire": "화",
            "earth": "토",
            "metal": "금",
            "water": "수",
        }
        data["element"] = element_map.get(character_type, "목")
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
