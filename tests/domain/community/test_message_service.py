from __future__ import annotations

from typing import Any, Dict, List

import pytest

from app.common.exceptions import AuthorizationError
from app.domain.community.services.message_service import MessageService


class FakeMessageRepository:
    def __init__(self) -> None:
        self._rows: Dict[int, Dict[str, Any]] = {}
        self._pk = 1

    def create(self, sender_id: int, recipient_id: int, content: str) -> int:
        message_id = self._pk
        self._pk += 1
        record = {
            "message_id": message_id,
            "sender_id": sender_id,
            "recipient_id": recipient_id,
            "content": content,
            "is_read": False,
            "created_at": None,
            "thread_key": self._thread_key(sender_id, recipient_id),
        }
        self._rows[message_id] = record
        return message_id

    def get(self, message_id: int) -> Dict[str, Any] | None:
        return self._rows.get(message_id)

    def list_conversation(
        self,
        user_id: int,
        other_id: int,
        limit: int = 50,
        before_id: int | None = None,
    ) -> List[Dict[str, Any]]:
        thread_key = self._thread_key(user_id, other_id)
        rows = [
            row
            for row in self._rows.values()
            if row["thread_key"] == thread_key and (before_id is None or row["message_id"] < before_id)
        ]
        return sorted(rows, key=lambda r: r["message_id"], reverse=True)[:limit]

    def mark_read(self, user_id: int, other_id: int) -> None:
        thread_key = self._thread_key(user_id, other_id)
        for row in self._rows.values():
            if row["thread_key"] == thread_key and row["recipient_id"] == user_id:
                row["is_read"] = True

    def list_threads(self, user_id: int, limit: int = 20, offset: int = 0) -> List[Dict[str, Any]]:
        threads: Dict[str, Dict[str, Any]] = {}
        for row in sorted(self._rows.values(), key=lambda r: r["message_id"], reverse=True):
            if row["sender_id"] != user_id and row["recipient_id"] != user_id:
                continue
            thread_key = row["thread_key"]
            if thread_key not in threads:
                other_id = row["recipient_id"] if row["sender_id"] == user_id else row["sender_id"]
                unread = sum(
                    1
                    for candidate in self._rows.values()
                    if candidate["thread_key"] == thread_key
                    and candidate["recipient_id"] == user_id
                    and not candidate["is_read"]
                )
                data = dict(row)
                data["other_user_id"] = other_id
                data["unread_count"] = unread
                threads[thread_key] = data
        items = list(threads.values())[offset : offset + limit]
        return items

    def _thread_key(self, user_a: int, user_b: int) -> str:
        lower = min(user_a, user_b)
        higher = max(user_a, user_b)
        return f"{lower}:{higher}"


class FakeFriendRepository:
    def __init__(self) -> None:
        self._friends: set[tuple[int, int]] = set()

    def are_friends(self, user_id: int, other_id: int) -> bool:
        key = tuple(sorted((user_id, other_id)))
        return key in self._friends

    def set_friends(self, user_id: int, other_id: int) -> None:
        key = tuple(sorted((user_id, other_id)))
        self._friends.add(key)


class FakeUserRepository:
    def __init__(self) -> None:
        self._rows = {
            1: {"user_id": 1, "username": "alpha", "email": "alpha@example.com", "character_type": "fire"},
            2: {"user_id": 2, "username": "beta", "email": "beta@example.com", "character_type": "water"},
        }

    def get_by_id(self, user_id: int) -> Dict[str, Any] | None:
        return self._rows.get(user_id)


def make_service(with_friendship: bool = False) -> MessageService:
    message_repo = FakeMessageRepository()
    friend_repo = FakeFriendRepository()
    if with_friendship:
        friend_repo.set_friends(1, 2)
    user_repo = FakeUserRepository()
    return MessageService(
        message_repo=message_repo,
        friend_repo=friend_repo,
        user_repo=user_repo,
    )


def test_send_message_requires_friendship() -> None:
    svc = make_service(with_friendship=False)
    with pytest.raises(AuthorizationError):
        svc.send_message(sender_id=1, recipient_id=2, content="안녕")


def test_send_message_success_returns_payload() -> None:
    svc = make_service(with_friendship=True)
    data = svc.send_message(sender_id=1, recipient_id=2, content="  안녕하세요  ")
    assert data["content"] == "안녕하세요"
    assert data["recipient"]["user_id"] == 2


def test_list_conversation_requires_friendship() -> None:
    svc = make_service(with_friendship=False)
    with pytest.raises(AuthorizationError):
        svc.list_conversation(user_id=1, other_id=2)


def test_list_threads_includes_peer_info() -> None:
    svc = make_service(with_friendship=True)
    svc.send_message(sender_id=1, recipient_id=2, content="첫 메시지")
    svc.send_message(sender_id=2, recipient_id=1, content="답장")
    threads = svc.list_threads(1)
    assert len(threads) == 1
    thread = threads[0]
    assert thread["peer"]["user_id"] == 2
    assert "unread_count" in thread


