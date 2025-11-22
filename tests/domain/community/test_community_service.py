from __future__ import annotations

from typing import Dict, Any, List

from app.domain.community.services.community_service import CommunityService


class FakePostRepository:
    def __init__(self) -> None:
        self._rows: Dict[int, Dict[str, Any]] = {}
        self._pk = 1

    def create(self, author_id: int, title: str, content: str, board_type: str | None = None) -> int:
        post_id = self._pk
        self._pk += 1
        self._rows[post_id] = {
            "post_id": post_id,
            "author_id": author_id,
            "title": title,
            "content": content,
            "board_type": board_type,
        }
        return post_id

    def get(self, post_id: int) -> Dict[str, Any] | None:
        return self._rows.get(post_id)

    def list(self, page: int = 1, page_size: int = 20) -> List[Dict[str, Any]]:
        return list(self._rows.values())


class FakeCommentRepository:
    def __init__(self) -> None:
        self._rows: Dict[int, Dict[str, Any]] = {}
        self._pk = 1

    def add(self, post_id: int, author_id: int, content: str) -> int:
        comment_id = self._pk
        self._pk += 1
        self._rows[comment_id] = {
            "comment_id": comment_id,
            "post_id": post_id,
            "author_id": author_id,
            "content": content,
        }
        return comment_id

    def list_by_post(self, post_id: int) -> List[Dict[str, Any]]:
        return [row for row in self._rows.values() if row["post_id"] == post_id]


class FakeUserRepository:
    def __init__(self) -> None:
        self._rows = {
            1: {"user_id": 1, "username": "user1"},
            2: {"user_id": 2, "username": "user2"},
        }

    def get_by_id(self, user_id: int) -> Dict[str, Any] | None:
        return self._rows.get(user_id)


class FakeNotificationRepository:
    def __init__(self) -> None:
        self.sent: List[Dict[str, Any]] = []

    def create(self, user_id: int, notification_type: str, payload: Dict[str, Any]) -> int:
        self.sent.append({"user_id": user_id, "type": notification_type, "payload": payload})
        return len(self.sent)


def make_service() -> CommunityService:
    return CommunityService(
        post_repo=FakePostRepository(),
        comment_repo=FakeCommentRepository(),
        user_repo=FakeUserRepository(),
        notification_repo=FakeNotificationRepository(),
    )


def test_create_and_get_post() -> None:
    svc = make_service()
    post_id = svc.create_post(author_id=1, title="t", content="c")
    post = svc.get_post(post_id)
    assert post is not None
    assert post["title"] == "t"
    assert post["comment_count"] == 0


def test_add_comment_and_list_posts() -> None:
    svc = make_service()
    post_id = svc.create_post(author_id=1, title="hello", content="body")
    comment_id = svc.add_comment(post_id=post_id, author_id=2, content="nice")
    assert comment_id == 1
    post = svc.get_post(post_id)
    assert post and post["comment_count"] == 1
    posts = svc.list_posts()
    assert len(posts) == 1
    assert posts[0]["title"] == "hello"


