import json
from datetime import datetime

from flask import Blueprint, request, jsonify

from app.domain.saju_core.saju_calculator import SajuCalculator
from app.domain.saju_core.data_validator import DataValidator
from app.domain.saju_core.personality_analyzer import PersonalityAnalyzer
from app.domain.saju_core.character_system import CharacterSystem
from app.common.exceptions import ValidationError
from app.common.security.auth import require_auth, get_current_user
from app.common.schemas import (
    SajuTraitsSchema,
    SajuCompatibilitySchema,
    SajuBirthTraitsSchema,
    SajuBirthCompatibilitySchema,
    load_json,
)
from app.infrastructure.database.repositories.user_repository import user_repository
from app.infrastructure.external.gemini_client import get_gemini_client

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
        result["saju"] = saju
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


@bp.post("/traits/birth")
@require_auth()
def analyze_traits_from_birth():
    calc = get_calculator()
    try:
        data = load_json(SajuBirthTraitsSchema, request.get_json(silent=True))
        birth = data["birth"]
        gender = data.get("gender", 0)
        saju = calc.get_birth_data(
            year=birth["year"],
            month=birth["month"],
            day=birth["day"],
            hour=birth.get("hour", 12),
            minute=birth.get("minute", 0),
        )
        result = calc.analyze_personality(saju, gender=gender)
        character_type = calc.determine_character_type(saju)
        result["character"] = character_type
        result["saju"] = saju

        # Gemini를 사용한 개인 사주 전반 분석 요약 생성
        try:
            gemini = get_gemini_client()
            print("🔮 Gemini 개인 사주 분석 시도 (/saju/traits/birth)")
            personal_summary = gemini.generate_personal_analysis(
                name=None,  # 아래에서 current_user 조회 후 다시 설정
                character_type=character_type,
                five_elements=result.get("five", {}),
                traits=result.get("traits", {}),
                flags=result.get("flags", []),
                gender=gender,
            )
            if personal_summary:
                print("✅ Gemini 개인 사주 분석 성공: 요약 생성 완료")
                result["ai_summary"] = personal_summary
                print(f"📝 ai_summary 길이: {len(personal_summary)}자")
                print(f"📝 ai_summary 미리보기: {personal_summary[:100]}...")
            else:
                print("⚠️ Gemini 개인 사주 분석: 응답이 비어 있음(None 또는 빈 문자열)")
        except Exception as ai_error:
            # AI 분석 실패는 무시하고 기본 데이터만 반환
            import traceback
            print(f"❌ Gemini 개인 사주 분석 생성 실패: {ai_error}")
            traceback.print_exc()

        # 현재 로그인한 사용자의 정보를 데이터베이스에 업데이트
        try:
            current_user = get_current_user()
            user_id = current_user.get("user_id")
            
            if user_id:
                # 생년월일을 datetime 형식으로 변환 (YYYY-MM-DD)
                birth_date_str = f"{birth['year']}-{birth['month']:02d}-{birth['day']:02d}"

                # DB에 저장할 전체 결과 구성 (ai_summary 포함)
                full_result = {
                    "character": result.get("character"),
                    "five": result.get("five", {}),
                    "traits": result.get("traits", {}),
                    "flags": result.get("flags", []),
                    "report": result.get("report", ""),
                    "saju": result.get("saju", saju),
                }
                # AI 요약이 있으면 함께 저장
                if "ai_summary" in result:
                    full_result["ai_summary"] = result["ai_summary"]

                saju_json = json.dumps(full_result, ensure_ascii=False)
                
                print(f"💾 사용자 {user_id} 사주 데이터 저장 시도")
                print(f"💾 character_type: {character_type}")
                print(f"💾 birth_date: {birth_date_str}")
                print(f"💾 gender: {gender}")
                print(f"💾 saju_data 길이: {len(saju_json)}")
                if "ai_summary" in full_result:
                    print(f"💾 saju_data에 ai_summary 포함 (길이: {len(full_result['ai_summary'])}자)")
                else:
                    print("⚠️ saju_data에 ai_summary가 포함되지 않음")
                
                # character_type은 이미 영어("wood", "fire" 등)로 반환됨
                character_type_en = _convert_character_to_en(character_type)
                
                # 사용자 정보 업데이트
                user_repository.update_saju_info(
                    user_id=user_id,
                    character_type=character_type_en,
                    birth_date=birth_date_str,
                    gender=gender,
                    saju_data=saju_json,
                )
                print(f"✅ 사용자 {user_id} 사주 데이터 저장 완료")
        except Exception as db_error:
            # 데이터베이스 업데이트 실패해도 분석 결과는 반환
            import traceback
            print(f"⚠️ 사용자 정보 업데이트 실패: {db_error}")
            traceback.print_exc()

        # 응답 직전에 ai_summary 포함 여부 확인
        if "ai_summary" in result:
            print(f"✅ 응답에 ai_summary 포함됨 (길이: {len(result['ai_summary'])}자)")
        else:
            print("⚠️ 응답에 ai_summary가 포함되지 않음")
        
        return jsonify(result), 200
    except (ValidationError, ValueError) as e:
        return jsonify({"error": str(e)}), 400


def _convert_character_to_en(character: str) -> str | None:
    """캐릭터 타입을 영어로 변환 (이미 영어일 수도 있음)"""
    # determine_character_type은 이미 영어("wood", "fire" 등)를 반환하므로
    # 그대로 사용하되, 혹시 한글이 들어올 경우를 대비해 변환
    if character in ("wood", "fire", "earth", "metal", "water"):
        return character
    
    # 한글인 경우 영어로 변환
    mapping = {
        "목의 사람": "wood",
        "화의 사람": "fire",
        "토의 사람": "earth",
        "금의 사람": "metal",
        "수의 사람": "water",
        "목": "wood",
        "화": "fire",
        "토": "earth",
        "금": "metal",
        "수": "water",
    }
    return mapping.get(character, character)  # 매핑이 없으면 원본 반환


@bp.post("/compatibility/birth")
def compatibility_from_birth():
    calc = get_calculator()
    try:
        data = load_json(SajuBirthCompatibilitySchema, request.get_json(silent=True))
        birth1 = data["birth1"]
        birth2 = data["birth2"]
        saju1 = calc.get_birth_data(
            year=birth1["year"],
            month=birth1["month"],
            day=birth1["day"],
            hour=birth1.get("hour", 12),
            minute=birth1.get("minute", 0),
        )
        saju2 = calc.get_birth_data(
            year=birth2["year"],
            month=birth2["month"],
            day=birth2["day"],
            hour=birth2.get("hour", 12),
            minute=birth2.get("minute", 0),
        )
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
            "saju1": saju1,
            "saju2": saju2,
        }
        return jsonify(response), 200
    except (ValidationError, ValueError) as e:
        return jsonify({"error": str(e)}), 400

