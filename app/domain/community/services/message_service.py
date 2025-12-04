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

    def send_message(self, sender_id: int, recipient_id: int, content: str, is_anonymous: bool = False) -> Dict[str, Any]:
        content = (content or "").strip()
        if not content:
            raise ValidationError("쪽지 내용을 입력해주세요.")
        if sender_id == recipient_id:
            raise ValidationError("자기 자신에게 쪽지를 보낼 수 없습니다.")
        self._ensure_user(sender_id)
        recipient = self._ensure_user(recipient_id)
        # 친구 관계 확인 제거 - 익명 사용자와 게시글 작성자에게도 쪽지 보낼 수 있도록

        message_id = self.messages.create(sender_id, recipient_id, content, is_anonymous=is_anonymous)
        record = self.messages.get(message_id)
        if not record:
            raise NotFoundError("쪽지 정보를 조회할 수 없습니다.")
        data = Message.from_record(record).to_dict()
        data["recipient"] = self._serialize_user(recipient)
        return data

    def list_threads(self, user_id: int, limit: int = 20, offset: int = 0) -> List[Dict[str, Any]]:
        self._ensure_user(user_id)
        rows = self.messages.list_threads(user_id=user_id, limit=limit, offset=offset)
        print(f"list_threads: Found {len(rows)} rows from repository for user {user_id}")
        results: List[Dict[str, Any]] = []
        for row in rows:
            print(f"list_threads: Processing row: {row}")
            other_id = row.get("other_user_id")
            if not other_id:
                print(f"list_threads: Skipping row - no other_user_id: {row}")
                continue
            is_anonymous = bool(row.get("is_anonymous", False))
            print(f"list_threads: other_id={other_id}, is_anonymous={is_anonymous}")
            try:
                other = self._ensure_user(other_id)
            except NotFoundError as e:
                # 사용자를 찾을 수 없는 경우 건너뛰기
                print(f"list_threads: User {other_id} not found, skipping: {e}")
                continue
            # Message.from_record는 메시지 필드만 처리하므로, 추가 필드는 직접 포함
            created_at = row.get("created_at")
            if created_at and hasattr(created_at, 'isoformat'):
                created_at = created_at.isoformat()
            message_data = {
                "message_id": row.get("message_id"),
                "sender_id": row.get("sender_id"),
                "recipient_id": row.get("recipient_id"),
                "content": row.get("content", ""),
                "is_read": bool(row.get("is_read", False)),
                "created_at": created_at,
            }
            # 익명 쪽지인 경우 사용자 정보를 익명으로 표시
            if is_anonymous:
                message_data["peer"] = {
                    "user_id": other_id,
                    "username": "익명",
                    "email": None,
                    "character_type": None,
                }
            else:
                message_data["peer"] = self._serialize_user(other)
            message_data["unread_count"] = row.get("unread_count", 0)
            message_data["is_anonymous"] = is_anonymous
            print(f"list_threads: Adding message_data: {message_data}")
            results.append(message_data)
        print(f"list_threads: Returning {len(results)} results")
        return results

    def list_conversation(
        self,
        user_id: int,
        other_id: int,
        limit: int = 50,
        before_id: int | None = None,
        is_anonymous: bool = False,
    ) -> List[Dict[str, Any]]:
        self._ensure_user(user_id)
        self._ensure_user(other_id)
        # 친구 관계 확인 제거 - 쪽지를 주고받은 모든 사용자와의 대화를 볼 수 있도록
        rows = self.messages.list_conversation(
            user_id=user_id,
            other_id=other_id,
            limit=limit,
            before_id=before_id,
            is_anonymous=is_anonymous,
        )
        return [Message.from_record(row).to_dict() for row in rows]

    def mark_read(self, user_id: int, other_id: int, is_anonymous: bool = False) -> None:
        self._ensure_user(user_id)
        self._ensure_user(other_id)
        self.messages.mark_read(user_id, other_id, is_anonymous=is_anonymous)

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


