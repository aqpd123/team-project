from flask import Blueprint, jsonify, request

from app.common.exceptions import AppError, ValidationError, NotFoundError, AuthorizationError
from app.common.security.auth import require_auth, get_current_user
from app.domain.community.services.friend_service import FriendService
from app.common.schemas import (
    FriendRequestSchema,
    FriendRespondSchema,
    load_json,
)

bp = Blueprint("friends", __name__, url_prefix="/friends")
friend_service = FriendService()


def _error_response(exc: AppError):
    if isinstance(exc, ValidationError):
        return jsonify({"error": str(exc)}), 400
    if isinstance(exc, AuthorizationError):
        return jsonify({"error": str(exc)}), 403
    if isinstance(exc, NotFoundError):
        return jsonify({"error": str(exc)}), 404
    return jsonify({"error": "서버 오류가 발생했습니다."}), 500


@bp.post("/requests")
@require_auth()
def send_friend_request():
    try:
        payload = load_json(FriendRequestSchema, request.get_json(silent=True))
        current_user = get_current_user()
        friendship_id = friend_service.send_request(
            requester_id=current_user["user_id"],
            addressee_id=payload["target_id"],
        )
        return jsonify({"friendship_id": friendship_id, "status": "pending"}), 201
    except AppError as exc:
        return _error_response(exc)


@bp.post("/requests/<int:friendship_id>/response")
@require_auth()
def respond_friend_request(friendship_id: int):
    current_user = get_current_user()
    try:
        payload = load_json(FriendRespondSchema, request.get_json(silent=True))
        record = friend_service.respond_request(
            friendship_id=friendship_id,
            actor_id=current_user["user_id"],
            accept=payload["accept"],
        )
        return jsonify(record)
    except AppError as exc:
        return _error_response(exc)


@bp.get("")
@require_auth()
def list_friends():
    current_user = get_current_user()
    try:
        items = friend_service.list_friends(current_user["user_id"])
        return jsonify({"items": items, "count": len(items)})
    except AppError as exc:
        return _error_response(exc)


@bp.get("/requests")
@require_auth()
def list_friend_requests():
    current_user = get_current_user()
    box = request.args.get("box", "inbox")
    inbox = box != "outbox"
    try:
        items = friend_service.list_pending_requests(current_user["user_id"], inbox=inbox)
        return jsonify({"items": items, "count": len(items), "box": "inbox" if inbox else "outbox"})
    except AppError as exc:
        return _error_response(exc)


@bp.delete("/requests/<int:friendship_id>")
@require_auth()
def cancel_friend_request(friendship_id: int):
    current_user = get_current_user()
    try:
        friend_service.cancel_request(friendship_id, current_user["user_id"])
        return jsonify({"friendship_id": friendship_id, "status": "cancelled"}), 200
    except AppError as exc:
        return _error_response(exc)


@bp.delete("/<int:friendship_id>")
@require_auth()
def delete_friend(friendship_id: int):
    current_user = get_current_user()
    try:
        friend_service.remove_friend(friendship_id, current_user["user_id"])
        return jsonify({"friendship_id": friendship_id, "status": "deleted"}), 200
    except AppError as exc:
        return _error_response(exc)



