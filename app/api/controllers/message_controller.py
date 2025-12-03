from flask import Blueprint, jsonify, request

from app.common.exceptions import AppError, ValidationError, AuthorizationError, NotFoundError
from marshmallow import fields, validate

from app.common.schemas import load_json, BaseSchema
from app.common.security.auth import require_auth, get_current_user
from app.domain.community.services.message_service import message_service

bp = Blueprint("messages", __name__, url_prefix="/messages")


class MessageSendSchema(BaseSchema):
    recipient_id = fields.Int(required=True)
    content = fields.Str(required=True, validate=validate.Length(min=1))


def _error_response(exc: AppError):
    if isinstance(exc, ValidationError):
        return jsonify({"error": str(exc)}), 400
    if isinstance(exc, AuthorizationError):
        return jsonify({"error": str(exc)}), 403
    if isinstance(exc, NotFoundError):
        return jsonify({"error": str(exc)}), 404
    return jsonify({"error": "서버 오류가 발생했습니다."}), 500


@bp.post("")
@require_auth()
def send_message():
    current_user = get_current_user()
    try:
        payload = load_json(MessageSendSchema, request.get_json(silent=True))
        data = message_service.send_message(
            sender_id=current_user["user_id"],
            recipient_id=payload["recipient_id"],
            content=payload["content"],
        )
        return jsonify({"message": data}), 201
    except AppError as exc:
        return _error_response(exc)


@bp.get("/threads")
@require_auth()
def list_threads():
    current_user = get_current_user()
    limit = min(int(request.args.get("limit", 20)), 100)
    offset = int(request.args.get("offset", 0))
    try:
        items = message_service.list_threads(current_user["user_id"], limit=limit, offset=offset)
        return jsonify({"items": items, "count": len(items)})
    except AppError as exc:
        return _error_response(exc)


@bp.get("/conversations/<int:peer_id>")
@require_auth()
def list_conversation(peer_id: int):
    current_user = get_current_user()
    limit = min(int(request.args.get("limit", 50)), 200)
    before_id = request.args.get("before_id")
    before = int(before_id) if before_id else None
    try:
        items = message_service.list_conversation(
            user_id=current_user["user_id"],
            other_id=peer_id,
            limit=limit,
            before_id=before,
        )
        return jsonify({"items": items, "count": len(items)})
    except AppError as exc:
        return _error_response(exc)


@bp.post("/conversations/<int:peer_id>/read")
@require_auth()
def mark_conversation_read(peer_id: int):
    current_user = get_current_user()
    try:
        message_service.mark_read(current_user["user_id"], peer_id)
        return jsonify({"status": "ok"})
    except AppError as exc:
        return _error_response(exc)


