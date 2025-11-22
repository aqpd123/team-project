from __future__ import annotations

from typing import Dict, Any, List

import pytest

from app.domain.community.services.friend_service import FriendService
from app.common.exceptions import ValidationError, AuthorizationError


class FakeFriendRepository:
    def __init__(self) -> None:
        self._rows: Dict[int, Dict[str, Any]] = {}
        self._pk = 1

    def create_request(self, requester_id: int, addressee_id: int) -> int:
        fid = self._pk
        self._pk += 1
        self._rows[fid] = {
            "friendship_id": fid,
            "requester_id": requester_id,
            "addressee_id": addressee_id,
            "status": "pending",
            "created_at": None,
            "responded_at": None,
        }
        return fid

    def get(self, friendship_id: int) -> Dict[str, Any] | None:
        return self._rows.get(friendship_id)

    def find_between(self, user_id: int, other_id: int) -> Dict[str, Any] | None:
        for row in self._rows.values():
            if (
                (row["requester_id"] == user_id and row["addressee_id"] == other_id)
                or (row["requester_id"] == other_id and row["addressee_id"] == user_id)
            ):
                return row
        return None

    def update_status(self, friendship_id: int, status: str) -> None:
        row = self._rows[friendship_id]
        row["status"] = status

    def list_friends(self, user_id: int) -> List[Dict[str, Any]]:
        return [
            row
            for row in self._rows.values()
            if row["status"] == "accepted"
            and (row["requester_id"] == user_id or row["addressee_id"] == user_id)
        ]

    def list_pending(self, user_id: int, inbox: bool = True) -> List[Dict[str, Any]]:
        column = "addressee_id" if inbox else "requester_id"
        return [row for row in self._rows.values() if row["status"] == "pending" and row[column] == user_id]

    def are_friends(self, user_id: int, other_id: int) -> bool:
        row = self.find_between(user_id, other_id)
        return bool(row and row["status"] == "accepted")

    def delete(self, friendship_id: int) -> None:
        if friendship_id in self._rows:
            del self._rows[friendship_id]


class FakeUserRepository:
    def __init__(self) -> None:
        self._rows = {
            1: {"user_id": 1, "username": "alpha"},
            2: {"user_id": 2, "username": "beta"},
        }

    def get_by_id(self, user_id: int):
        return self._rows.get(user_id)


class FakeNotificationRepository:
    def __init__(self) -> None:
        self.sent: List[Dict[str, Any]] = []

    def create(self, user_id: int, notification_type: str, payload: Dict[str, Any]) -> int:
        self.sent.append({"user_id": user_id, "type": notification_type, "payload": payload})
        return len(self.sent)


def make_service() -> FriendService:
    return FriendService(
        friend_repo=FakeFriendRepository(),
        user_repo=FakeUserRepository(),
        notification_repo=FakeNotificationRepository(),
    )


def test_send_request_creates_pending_friendship() -> None:
    svc = make_service()
    fid = svc.send_request(requester_id=1, addressee_id=2)
    assert fid == 1
    rows = svc.friends.list_pending(2)
    assert len(rows) == 1


def test_send_request_duplicate_pending_raises() -> None:
    svc = make_service()
    svc.send_request(1, 2)
    with pytest.raises(ValidationError):
        svc.send_request(1, 2)


def test_respond_request_accepts_friendship() -> None:
    svc = make_service()
    fid = svc.send_request(1, 2)
    result = svc.respond_request(friendship_id=fid, actor_id=2, accept=True)
    assert result["status"] == "accepted"
    assert svc.friends.are_friends(1, 2)


def test_respond_request_by_non_addressee_forbidden() -> None:
    svc = make_service()
    fid = svc.send_request(1, 2)
    with pytest.raises(AuthorizationError):
        svc.respond_request(friendship_id=fid, actor_id=1, accept=True)


def test_cancel_request_by_requester() -> None:
    svc = make_service()
    fid = svc.send_request(1, 2)
    svc.cancel_request(friendship_id=fid, actor_id=1)
    assert svc.friends.get(fid) is None


def test_remove_friend_requires_membership() -> None:
    svc = make_service()
    fid = svc.send_request(1, 2)
    svc.respond_request(friendship_id=fid, actor_id=2, accept=True)
    svc.remove_friend(friendship_id=fid, actor_id=1)
    assert svc.friends.get(fid) is None



