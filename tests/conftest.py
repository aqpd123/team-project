import pytest

from app.domain.saju_core.saju_calculator import SajuCalculator
from app.domain.saju_core.data_validator import DataValidator
from app.domain.saju_core.personality_analyzer import PersonalityAnalyzer
from app.domain.saju_core.character_system import CharacterSystem


@pytest.fixture
def sample_saju() -> dict:
    # 상세설계 기준 키 6개: year_gan/ji, month_gan/ji, day_gan/ji
    return {
        "year_gan": "갑",
        "year_ji": "자",
        "month_gan": "을",
        "month_ji": "축",
        "day_gan": "병",
        "day_ji": "인",
    }


@pytest.fixture
def saju_calculator() -> SajuCalculator:
    return SajuCalculator(
        validator=DataValidator(),
        analyzer=PersonalityAnalyzer(),
        characters=CharacterSystem(),
    )


