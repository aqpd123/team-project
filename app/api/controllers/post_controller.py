from flask import Blueprint, jsonify, request

from app.common.exceptions import (
    AppError,
    NotFoundError,
    ValidationError,
    AuthorizationError,
)
from app.common.security.auth import require_auth, get_current_user
from app.domain.community.services.community_service import CommunityService
from app.common.schemas import (
    PostCreateSchema,
    CommentCreateSchema,
    load_json,
)

bp = Blueprint("posts", __name__, url_prefix="/posts")
community_service = CommunityService()


def _error_response(exc: AppError):
    if isinstance(exc, ValidationError):
        return jsonify({"error": str(exc)}), 400
    if isinstance(exc, NotFoundError):
        return jsonify({"error": str(exc)}), 404
    if isinstance(exc, AuthorizationError):
        return jsonify({"error": str(exc)}), 403
    return jsonify({"error": "서버 오류가 발생했습니다."}), 500


def _handle_exception(exc: Exception):
    """예상치 못한 예외 처리 (디버깅용)"""
    import traceback
    error_msg = str(exc)
    traceback_str = traceback.format_exc()
    print(f"❌ 예외 발생: {error_msg}")
    print(traceback_str)
    return jsonify({"error": f"서버 오류: {error_msg}"}), 500


@bp.post("")
@require_auth()
def create_post():
    try:
        payload = load_json(PostCreateSchema, request.get_json(silent=True))
        current_user = get_current_user()
        author_id = payload.get("author_id", current_user["user_id"])
        if author_id != current_user["user_id"]:
            raise AuthorizationError("요청자 정보가 토큰과 일치하지 않습니다.")
        post_id = community_service.create_post(
            author_id=author_id,
            title=payload["title"],
            content=payload["content"],
            board_type=payload.get("board_type"),
        )
        post = community_service.get_post(post_id)
        return jsonify({"post": post}), 201
    except AppError as exc:
        return _error_response(exc)
    except Exception as exc:
        return _handle_exception(exc)


@bp.get("")
@require_auth(optional=True)
def list_posts():
    page = int(request.args.get("page", 1))
    page_size = int(request.args.get("page_size", 20))
    try:
        items = community_service.list_posts(page=page, page_size=page_size)
        return jsonify({"items": items, "count": len(items), "page": page})
    except AppError as exc:
        return _error_response(exc)
    except Exception as exc:
        return _handle_exception(exc)


@bp.get("/<int:post_id>")
@require_auth(optional=True)
def get_post(post_id: int):
    try:
        current_user = get_current_user()
        user_id = current_user.get("user_id") if current_user else None
        post = community_service.get_post(post_id, user_id=user_id)
        comments = post.get("comments", [])
        body = dict(post)
        body.pop("comments", None)
        return jsonify({"post": body, "comments": comments})
    except AppError as exc:
        return _error_response(exc)


@bp.get("/my")
@require_auth()
def list_my_posts():
    page = int(request.args.get("page", 1))
    page_size = int(request.args.get("page_size", 20))
    try:
        current_user = get_current_user()
        items = community_service.list_my_posts(
            author_id=current_user["user_id"],
            page=page,
            page_size=page_size,
        )
        return jsonify({"items": items, "count": len(items), "page": page})
    except AppError as exc:
        return _error_response(exc)
    except Exception as exc:
        return _handle_exception(exc)


@bp.post("/<int:post_id>/comments")
@require_auth()
def add_comment(post_id: int):
    try:
        payload = load_json(CommentCreateSchema, request.get_json(silent=True))
        current_user = get_current_user()
        author_id = payload.get("author_id", current_user["user_id"])
        if author_id != current_user["user_id"]:
            raise AuthorizationError("요청자 정보가 토큰과 일치하지 않습니다.")
        comment_id = community_service.add_comment(
            post_id=post_id,
            author_id=author_id,
            content=payload["content"],
        )
        post = community_service.get_post(post_id, user_id=current_user["user_id"])
        comment = next((c for c in post.get("comments", []) if c["comment_id"] == comment_id), None)
        return jsonify({"comment": comment}), 201
    except AppError as exc:
        return _error_response(exc)


@bp.post("/<int:post_id>/like")
@require_auth()
def toggle_like(post_id: int):
    try:
        current_user = get_current_user()
        is_liked, like_count = community_service.toggle_like(
            post_id=post_id,
            user_id=current_user["user_id"],
        )
        return jsonify({"is_liked": is_liked, "like_count": like_count}), 200
    except AppError as exc:
        return _error_response(exc)
    except Exception as exc:
        return _handle_exception(exc)


@bp.put("/<int:post_id>")
@require_auth()
def update_post(post_id: int):
    """게시글 수정"""
    try:
        payload = load_json(PostCreateSchema, request.get_json(silent=True))
        current_user = get_current_user()
        community_service.update_post(
            post_id=post_id,
            user_id=current_user["user_id"],
            title=payload["title"],
            content=payload["content"],
        )
        return jsonify({"ok": True}), 200
    except AppError as exc:
        return _error_response(exc)
    except Exception as exc:
        return _handle_exception(exc)


@bp.delete("/<int:post_id>")
@require_auth()
def delete_post(post_id: int):
    """게시글 삭제"""
    try:
        current_user = get_current_user()
        community_service.delete_post(
            post_id=post_id,
            user_id=current_user["user_id"],
        )
        return jsonify({"ok": True}), 204
    except AppError as exc:
        return _error_response(exc)
    except Exception as exc:
        return _handle_exception(exc)


