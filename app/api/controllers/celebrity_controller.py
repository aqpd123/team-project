from flask import Blueprint, request, jsonify

from app.domain.celebrity.services.celebrity_service import CelebrityService
from app.common.exceptions import ValidationError
from app.common.schemas import CelebrityCompatibilitySchema, load_json

bp = Blueprint("celebrities", __name__, url_prefix="/celebrities")
service = CelebrityService()


@bp.get("")
def list_celebrities():
    keyword = request.args.get("keyword")
    items = service.list_celebrities(keyword)
    return jsonify({"items": items, "count": len(items)})


@bp.get("/<int:celebrity_id>")
def get_celebrity(celebrity_id: int):
    try:
        celeb = service.get_celebrity(celebrity_id)
        return jsonify(celeb)
    except ValidationError as e:
        return jsonify({"error": str(e)}), 404


@bp.post("/<int:celebrity_id>/compatibility")
def celebrity_compatibility(celebrity_id: int):
    try:
        payload = load_json(CelebrityCompatibilitySchema, request.get_json(silent=True))
    except ValidationError as exc:
        return jsonify({"error": str(exc)}), 400
    try:
        result = service.calculate_with_celebrity(
            payload["saju"], celebrity_id, user_gender=payload.get("gender", 0)
        )
        return jsonify(result)
    except ValidationError as e:
        return jsonify({"error": str(e)}), 400
    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        import traceback
        print(f"❌ Celebrity compatibility 오류: {e}")
        traceback.print_exc()
        return jsonify({"error": f"서버 오류가 발생했습니다: {str(e)}"}), 500
