from __future__ import annotations

from typing import Optional, List, Dict, Any

from app.common.exceptions import NotFoundError, ValidationError
from app.domain.community.models import Post, Comment
from app.infrastructure.database.repositories.post_repository import post_repository
from app.infrastructure.database.repositories.comment_repository import comment_repository
from app.infrastructure.database.repositories.user_repository import user_repository
from app.infrastructure.database.repositories.notification_repository import notification_repository


class CommunityService:
    def __init__(
        self,
        post_repo=post_repository,
        comment_repo=comment_repository,
        user_repo=user_repository,
        notification_repo=notification_repository,
    ) -> None:
        self.posts = post_repo
        self.comments = comment_repo
        self.users = user_repo
        self.notifications = notification_repo

    def create_post(self, author_id: int, title: str, content: str, board_type: str | None = None) -> int:
        self._ensure_user(author_id)
        if not title or not content:
            raise ValidationError("제목과 내용은 필수입니다.")
        post_id = self.posts.create(author_id=author_id, title=title, content=content, board_type=board_type)
        if self.notifications:
            self.notifications.create(
                user_id=author_id,
                notification_type="post_created",
                payload={"post_id": post_id, "title": title},
            )
        return post_id

    def get_post(self, post_id: int, user_id: int | None = None) -> Dict[str, Any]:
        record = self.posts.get(post_id)
        if not record:
            raise NotFoundError(f"게시글(ID: {post_id})을 찾을 수 없습니다.")
        post = Post.from_record(record)
        comments = [Comment.from_record(row) for row in self.comments.list_by_post(post_id)]
        data = post.to_dict()
        data["comments"] = [c.to_dict() for c in comments]
        data["comment_count"] = len(comments)
        # 사용자가 좋아요를 눌렀는지 확인
        if user_id is not None:
            data["is_liked"] = self.posts.is_liked_by_user(post_id, user_id)
        return data

    def add_comment(self, post_id: int, author_id: int, content: str) -> int:
        if not content:
            raise ValidationError("댓글 내용은 필수입니다.")
        post = self._ensure_post(post_id)
        self._ensure_user(author_id)
        # anonymous_number는 repository에서 자동으로 계산됨
        comment_id = self.comments.add(post_id=post_id, author_id=author_id, content=content)
        if self.notifications and post["author_id"] != author_id:
            self.notifications.create(
                user_id=post["author_id"],
                notification_type="comment_created",
                payload={"post_id": post_id, "comment_id": comment_id, "from_user_id": author_id},
            )
        return comment_id

    def list_posts(self, page: int = 1, page_size: int = 20) -> List[Dict[str, Any]]:
        rows = self.posts.list(page=page, page_size=page_size)
        return [Post.from_record(row).to_dict() for row in rows]

    def list_my_posts(self, author_id: int, page: int = 1, page_size: int = 20) -> List[Dict[str, Any]]:
        rows = self.posts.list_by_author(author_id=author_id, page=page, page_size=page_size)
        return [Post.from_record(row).to_dict() for row in rows]

    def _ensure_user(self, user_id: int) -> Dict[str, Any]:
        user = self.users.get_by_id(user_id)
        if not user:
            raise NotFoundError(f"사용자(ID: {user_id})를 찾을 수 없습니다.")
        return user

    def _ensure_post(self, post_id: int) -> Dict[str, Any]:
        post = self.posts.get(post_id)
        if not post:
            raise NotFoundError(f"게시글(ID: {post_id})을 찾을 수 없습니다.")
        return post
    
    def toggle_like(self, post_id: int, user_id: int) -> tuple[bool, int]:
        """좋아요 토글"""
        self._ensure_post(post_id)
        self._ensure_user(user_id)
        return self.posts.toggle_like(post_id, user_id)


