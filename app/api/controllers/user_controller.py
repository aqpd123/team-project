import json

from flask import Blueprint, jsonify, request

from app.common.security.auth import require_auth
from app.infrastructure.database.repositories.user_repository import user_repository

bp = Blueprint("users", __name__, url_prefix="/users")


def _serialize_user(row):
    if not row:
        return None
    data = dict(row)
    data.pop("password_hash", None)
    saju = data.pop("saju_data", None)
    if saju:
        try:
            data["saju"] = json.loads(saju)
        except json.JSONDecodeError:
            data["saju"] = None
    return data


@bp.get("")
@require_auth()
def list_users():
    page = int(request.args.get("page", 1))
    page_size = int(request.args.get("page_size", 20))
    rows = user_repository.list(page=page, page_size=page_size)
    return jsonify(
        {
            "items": [_serialize_user(row) for row in rows],
            "count": len(rows),
            "page": page,
        }
    )


@bp.get("/<int:user_id>")
@require_auth()
def get_user(user_id: int):
    user = user_repository.get_by_id(user_id)
    if not user:
        return jsonify({"error": "사용자를 찾을 수 없습니다."}), 404
    return jsonify(_serialize_user(user))


