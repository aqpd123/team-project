from __future__ import annotations

from typing import List, Dict, Any

from app.common.exceptions import (
    ValidationError,
    NotFoundError,
    AuthorizationError,
)
from app.domain.community.models import Friendship
from app.infrastructure.database.repositories.friend_repository import friend_repository
from app.infrastructure.database.repositories.user_repository import user_repository
from app.infrastructure.database.repositories.notification_repository import (
    notification_repository,
)


class FriendService:
    def __init__(
        self,
        friend_repo=friend_repository,
        user_repo=user_repository,
        notification_repo=notification_repository,
    ) -> None:
        self.friends = friend_repo
        self.users = user_repo
        self.notifications = notification_repo

    def send_request(self, requester_id: int, addressee_id: int) -> int:
        if requester_id == addressee_id:
            raise ValidationError("자기 자신에게 친구 요청을 보낼 수 없습니다.")
        self._ensure_user(requester_id)
        self._ensure_user(addressee_id)

        existing = self.friends.find_between(requester_id, addressee_id)
        if existing:
            status = existing["status"]
            if status == "pending":
                raise ValidationError("이미 대기 중인 친구 요청이 있습니다.")
            if status == "accepted":
                raise ValidationError("이미 친구 상태입니다.")

        friendship_id = self.friends.create_request(requester_id, addressee_id)
        if self.notifications:
            self.notifications.create(
                user_id=addressee_id,
                notification_type="friend_request",
                payload={"friendship_id": friendship_id, "from_user_id": requester_id},
            )
        return friendship_id

    def respond_request(self, friendship_id: int, actor_id: int, accept: bool) -> Dict[str, Any]:
        record = self._require_friendship(friendship_id)
        if record["status"] != "pending":
            raise ValidationError("이미 처리된 친구 요청입니다.")
        if record["addressee_id"] != actor_id:
            raise AuthorizationError("수신자만 친구 요청을 처리할 수 있습니다.")

        new_status = "accepted" if accept else "rejected"
        self.friends.update_status(friendship_id, new_status)
        updated = self._require_friendship(friendship_id)

        if self.notifications:
            self.notifications.create(
                user_id=record["requester_id"],
                notification_type="friend_response",
                payload={
                    "friendship_id": friendship_id,
                    "accept": accept,
                },
            )
        return updated

    def list_friends(self, user_id: int) -> List[Dict[str, Any]]:
        self._ensure_user(user_id)
        rows = self.friends.list_friends(user_id)
        return [Friendship.from_record(row).to_dict() for row in rows]

    def list_pending_requests(self, user_id: int, inbox: bool = True) -> List[Dict[str, Any]]:
        self._ensure_user(user_id)
        rows = self.friends.list_pending(user_id, inbox=inbox)
        return [Friendship.from_record(row).to_dict() for row in rows]

    def are_friends(self, user_id: int, other_id: int) -> bool:
        return self.friends.are_friends(user_id, other_id)

    def cancel_request(self, friendship_id: int, actor_id: int) -> None:
        record = self._require_friendship(friendship_id)
        if record["status"] != "pending":
            raise ValidationError("대기 중인 요청만 취소할 수 있습니다.")
        if record["requester_id"] != actor_id:
            raise AuthorizationError("요청자만 취소할 수 있습니다.")
        self.friends.delete(friendship_id)
        if self.notifications:
            self.notifications.create(
                user_id=record["addressee_id"],
                notification_type="friend_request_cancelled",
                payload={"friendship_id": friendship_id, "from_user_id": actor_id},
            )

    def remove_friend(self, friendship_id: int, actor_id: int) -> None:
        record = self._require_friendship(friendship_id)
        if record["status"] != "accepted":
            raise ValidationError("수락된 친구만 삭제할 수 있습니다.")
        if actor_id not in (record["requester_id"], record["addressee_id"]):
            raise AuthorizationError("해당 친구 관계에 속한 사용자만 삭제할 수 있습니다.")
        self.friends.delete(friendship_id)
        other_id = (
            record["addressee_id"] if actor_id == record["requester_id"] else record["requester_id"]
        )
        if self.notifications:
            self.notifications.create(
                user_id=other_id,
                notification_type="friend_removed",
                payload={"friendship_id": friendship_id, "by_user_id": actor_id},
            )

    def _ensure_user(self, user_id: int) -> Dict[str, Any]:
        user = self.users.get_by_id(user_id)
        if not user:
            raise NotFoundError(f"사용자(ID: {user_id})를 찾을 수 없습니다.")
        return user

    def _require_friendship(self, friendship_id: int) -> Dict[str, Any]:
        record = self.friends.get(friendship_id)
        if not record:
            raise NotFoundError(f"친구 요청(ID: {friendship_id})을 찾을 수 없습니다.")
        return record



