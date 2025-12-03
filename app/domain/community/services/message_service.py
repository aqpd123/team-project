from __future__ import annotations

from typing import Dict, Any, List

from app.common.exceptions import ValidationError, AuthorizationError, NotFoundError
from app.domain.community.models import Message
from app.infrastructure.database.repositories.message_repository import message_repository
from app.infrastructure.database.repositories.friend_repository import friend_repository
from app.infrastructure.database.repositories.user_repository import user_repository


class MessageService:
    def __init__(
        self,
        message_repo=message_repository,
        friend_repo=friend_repository,
        user_repo=user_repository,
    ) -> None:
        self.messages = message_repo
        self.friends = friend_repo
        self.users = user_repo

    def send_message(self, sender_id: int, recipient_id: int, content: str) -> Dict[str, Any]:
        content = (content or "").strip()
        if not content:
            raise ValidationError("쪽지 내용을 입력해주세요.")
        if sender_id == recipient_id:
            raise ValidationError("자기 자신에게 쪽지를 보낼 수 없습니다.")
        self._ensure_user(sender_id)
        recipient = self._ensure_user(recipient_id)
        if not self.friends.are_friends(sender_id, recipient_id):
            raise AuthorizationError("친구 관계에서만 쪽지를 주고받을 수 있습니다.")

        message_id = self.messages.create(sender_id, recipient_id, content)
        record = self.messages.get(message_id)
        if not record:
            raise NotFoundError("쪽지 정보를 조회할 수 없습니다.")
        data = Message.from_record(record).to_dict()
        data["recipient"] = self._serialize_user(recipient)
        return data

    def list_threads(self, user_id: int, limit: int = 20, offset: int = 0) -> List[Dict[str, Any]]:
        self._ensure_user(user_id)
        rows = self.messages.list_threads(user_id=user_id, limit=limit, offset=offset)
        results: List[Dict[str, Any]] = []
        for row in rows:
            other_id = row["other_user_id"]
            other = self._ensure_user(other_id)
            message = Message.from_record(row).to_dict()
            message["peer"] = self._serialize_user(other)
            message["unread_count"] = row.get("unread_count", 0)
            results.append(message)
        return results

    def list_conversation(
        self,
        user_id: int,
        other_id: int,
        limit: int = 50,
        before_id: int | None = None,
    ) -> List[Dict[str, Any]]:
        self._ensure_user(user_id)
        self._ensure_user(other_id)
        if user_id != other_id and not self.friends.are_friends(user_id, other_id):
            raise AuthorizationError("친구 관계에서만 쪽지를 확인할 수 있습니다.")
        rows = self.messages.list_conversation(
            user_id=user_id,
            other_id=other_id,
            limit=limit,
            before_id=before_id,
        )
        return [Message.from_record(row).to_dict() for row in rows]

    def mark_read(self, user_id: int, other_id: int) -> None:
        self._ensure_user(user_id)
        self._ensure_user(other_id)
        self.messages.mark_read(user_id, other_id)

    def _ensure_user(self, user_id: int) -> Dict[str, Any]:
        user = self.users.get_by_id(user_id)
        if not user:
            raise NotFoundError(f"사용자(ID: {user_id})를 찾을 수 없습니다.")
        return user

    def _serialize_user(self, user: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "user_id": user["user_id"],
            "username": user.get("username"),
            "email": user.get("email"),
            "character_type": user.get("character_type"),
        }


message_service = MessageService()


