from flask import Blueprint, request, jsonify

from app.domain.saju_core.saju_calculator import SajuCalculator
from app.domain.saju_core.data_validator import DataValidator
from app.domain.saju_core.personality_analyzer import PersonalityAnalyzer
from app.domain.saju_core.character_system import CharacterSystem
from app.common.exceptions import ValidationError
from app.common.schemas import (
    SajuTraitsSchema,
    SajuCompatibilitySchema,
    load_json,
)

bp = Blueprint("saju", __name__, url_prefix="/saju")


def get_calculator() -> SajuCalculator:
    return SajuCalculator(
        validator=DataValidator(),
        analyzer=PersonalityAnalyzer(),
        characters=CharacterSystem(),
    )


@bp.post("/traits")
def analyze_traits():
    calc = get_calculator()
    try:
        data = load_json(SajuTraitsSchema, request.get_json(silent=True))
        saju = data["saju"]
        gender = data.get("gender", 0)
        result = calc.analyze_personality(saju, gender=gender)
        # 캐릭터 타입 추가
        result["character"] = calc.determine_character_type(saju)
        return jsonify(result), 200
    except (ValidationError, ValueError) as e:
        return jsonify({"error": str(e)}), 400


@bp.post("/compatibility")
def compatibility():
    calc = get_calculator()
    try:
        data = load_json(SajuCompatibilitySchema, request.get_json(silent=True))
        saju1 = data["saju1"]
        saju2 = data["saju2"]
        gender1 = data.get("gender1", 0)
        gender2 = data.get("gender2", 0)
        scores = calc.calculate_compatibility(saju1, saju2, gender1, gender2)
        response = {
            "original": scores["original"],
            "final": scores["final"],
            "stress": scores["stress"],
            "details": {
                "method": "hd2",
                "gender1": gender1,
                "gender2": gender2,
            },
        }
        return jsonify(response), 200
    except (ValidationError, ValueError) as e:
        return jsonify({"error": str(e)}), 400

