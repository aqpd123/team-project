from flask import Blueprint, jsonify, request

from app.common.exceptions import AppError, NotFoundError, ValidationError, AuthorizationError
from app.common.security.auth import require_auth, get_current_user
from app.domain.community.services.compatibility_service import CompatibilityService
from app.common.schemas import (
    CompatibilityRequestSchema,
    CompatibilityRespondSchema,
    load_json,
)

bp = Blueprint("compatibility", __name__, url_prefix="/compatibility")
compatibility_service = CompatibilityService()


def _error_response(exc: AppError):
    if isinstance(exc, ValidationError):
        return jsonify({"error": str(exc)}), 400
    if isinstance(exc, NotFoundError):
        return jsonify({"error": str(exc)}), 404
    if isinstance(exc, AuthorizationError):
        return jsonify({"error": str(exc)}), 403
    return jsonify({"error": "서버 오류가 발생했습니다."}), 500


@bp.post("/requests")
@require_auth()
def create_request():
    try:
        payload = load_json(CompatibilityRequestSchema, request.get_json(silent=True))
        current_user = get_current_user()
        requester_id = payload.get("requester_id", current_user["user_id"])
        if requester_id != current_user["user_id"]:
            raise AuthorizationError("요청자 정보가 토큰과 일치하지 않습니다.")
        request_id = compatibility_service.request_compatibility(
            requester_id=requester_id,
            target_id=payload["target_id"],
            message=payload.get("message"),
        )
        return jsonify({"request_id": request_id, "status": "pending"}), 201
    except AppError as exc:
        return _error_response(exc)


@bp.get("/requests/<int:request_id>")
@require_auth()
def get_request(request_id: int):
    try:
        record = compatibility_service.get_request(request_id)
        current_user = get_current_user()
        if current_user["user_id"] not in (record["requester_id"], record["target_id"]):
            raise AuthorizationError("해당 요청에 접근할 권한이 없습니다.")
        return jsonify(record)
    except AppError as exc:
        return _error_response(exc)


@bp.post("/requests/<int:request_id>/response")
@require_auth()
def respond_request(request_id: int):
    try:
        payload = load_json(CompatibilityRespondSchema, request.get_json(silent=True))
        current_user = get_current_user()
        result = compatibility_service.accept_compatibility(
            request_id=request_id,
            actor_id=current_user["user_id"],
            accept=payload["accept"],
        )
        return jsonify(result)
    except AppError as exc:
        return _error_response(exc)


