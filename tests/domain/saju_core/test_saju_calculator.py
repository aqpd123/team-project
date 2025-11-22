from app.domain.saju_core.saju_calculator import SajuCalculator
from app.domain.saju_core.data_validator import DataValidator
from app.domain.saju_core.personality_analyzer import PersonalityAnalyzer
from app.domain.saju_core.character_system import CharacterSystem
from app.domain.saju_core.calendar_converter import GanjiCalculator


def test_analyze_personality_shape(saju_calculator: SajuCalculator, sample_saju: dict) -> None:
    result = saju_calculator.analyze_personality(sample_saju, gender=0)
    assert isinstance(result, dict)
    assert "five" in result
    assert "traits" in result
    assert "flags" in result
    assert "report" in result


def test_personality_flags_shape(saju_calculator: SajuCalculator, sample_saju: dict) -> None:
    flags = saju_calculator.calculate_personality_flags_hd2(sample_saju, gender=0)
    assert isinstance(flags, dict)
    assert "flags" in flags
    assert "sal" in flags
    assert isinstance(flags["sal"], list)
    assert len(flags["sal"]) == 8


def test_determine_character_type_returns_str(saju_calculator: SajuCalculator, sample_saju: dict) -> None:
    result = saju_calculator.determine_character_type(sample_saju)
    assert isinstance(result, str)


def test_calculate_compatibility_returns_dict(saju_calculator: SajuCalculator, sample_saju: dict) -> None:
    out = saju_calculator.calculate_compatibility(sample_saju, sample_saju, 0, 0)
    assert isinstance(out, dict)
    # hd2 규칙 출력 키 확인
    assert "original" in out
    assert "final" in out
    assert "stress" in out
    # 수치형 검증
    assert isinstance(out["original"], float)
    assert isinstance(out["final"], float)
    assert isinstance(out["stress"], float)


def test_get_birth_data_returns_lunar_payload() -> None:
    class DummyCalendarClient:
        def convert_solar_to_lunar(self, year, month, day):
            return {
                "solar": {"year": str(year), "month": f"{month:02d}", "day": f"{day:02d}"},
                "lunar": {"year": "2000", "month": "01", "day": "01", "is_leap": False},
            }

    calc = SajuCalculator(
        validator=DataValidator(),
        analyzer=PersonalityAnalyzer(),
        characters=CharacterSystem(),
        calendar_client=DummyCalendarClient(),
    )
    payload = calc.get_birth_data(2000, 1, 15)
    assert payload["year_gan"] in ("경", "신", "임", "계", "갑", "을", "병", "정", "무", "기")
    assert payload["lunar"]["year"] == "2000"


def test_ganji_calculator_known_year_and_day() -> None:
    converter = GanjiCalculator()
    data = converter.calculate(1988, 9, 17)
    assert data["year_gan"] == "무"
    assert data["year_ji"] == "진"

    # Reference day: 1984-02-02 is 갑자일
    ref = converter.calculate(1984, 2, 2)
    assert ref["day_gan"] == "갑"
    assert ref["day_ji"] == "자"


