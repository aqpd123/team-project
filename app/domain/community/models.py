from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Any, Dict, Optional


@dataclass(slots=True)
class Post:
    post_id: int
    author_id: int
    title: str
    content: str
    board_type: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    view_count: Optional[int] = None
    like_count: Optional[int] = None
    comment_count: Optional[int] = None  # 계산된 값, DB에 저장되지 않음
    author_name: Optional[str] = None  # 작성자 닉네임

    @classmethod
    def from_record(cls, record: Dict[str, Any]) -> "Post":
        # comment_count는 Post 모델의 필드이지만 from_record에서 제외 (별도 처리)
        filtered = {k: v for k, v in record.items() if k != 'comment_count'}
        post = cls(**filtered)
        # comment_count는 별도로 저장 (to_dict에서 사용)
        if 'comment_count' in record:
            post.comment_count = record.get('comment_count')
        return post

    def to_dict(self) -> Dict[str, Any]:
        data = {
            "post_id": self.post_id,
            "author_id": self.author_id,
            "title": self.title,
            "content": self.content,
            "board_type": self.board_type,
            "view_count": self.view_count,
            "like_count": self.like_count,
            "comment_count": self.comment_count or 0,
        }
        # author_name 포함
        if self.author_name:
            data["author_name"] = self.author_name
        if self.created_at:
            data["created_at"] = self.created_at.isoformat()
        if self.updated_at:
            data["updated_at"] = self.updated_at.isoformat()
        return data


@dataclass(slots=True)
class Comment:
    comment_id: int
    post_id: int
    author_id: int
    content: str
    anonymous_number: Optional[int] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    author_name: Optional[str] = None  # 작성자 닉네임

    @classmethod
    def from_record(cls, record: Dict[str, Any]) -> "Comment":
        return cls(**record)

    def to_dict(self) -> Dict[str, Any]:
        data = {
            "comment_id": self.comment_id,
            "post_id": self.post_id,
            "author_id": self.author_id,
            "content": self.content,
            "anonymous_number": self.anonymous_number,
        }
        # author_name 포함
        if self.author_name:
            data["author_name"] = self.author_name
        if self.created_at:
            data["created_at"] = self.created_at.isoformat()
        if self.updated_at:
            data["updated_at"] = self.updated_at.isoformat()
        return data


@dataclass(slots=True)
class Friendship:
    friendship_id: int
    requester_id: int
    addressee_id: int
    status: str
    created_at: Optional[datetime] = None
    responded_at: Optional[datetime] = None

    @classmethod
    def from_record(cls, record: Dict[str, Any]) -> "Friendship":
        return cls(**record)

    def to_dict(self) -> Dict[str, Any]:
        data = {
            "friendship_id": self.friendship_id,
            "requester_id": self.requester_id,
            "addressee_id": self.addressee_id,
            "status": self.status,
        }
        if self.created_at:
            data["created_at"] = self.created_at.isoformat()
        if self.responded_at:
            data["responded_at"] = self.responded_at.isoformat()
        return data


@dataclass(slots=True)
class Message:
    message_id: int
    sender_id: int
    recipient_id: int
    content: str
    is_read: bool
    created_at: Optional[datetime] = None

    @classmethod
    def from_record(cls, record: Dict[str, Any]) -> "Message":
        return cls(
            message_id=record["message_id"],
            sender_id=record["sender_id"],
            recipient_id=record["recipient_id"],
            content=record["content"],
            is_read=bool(record.get("is_read", False)),
            created_at=record.get("created_at"),
        )

    def to_dict(self) -> Dict[str, Any]:
        data = {
            "message_id": self.message_id,
            "sender_id": self.sender_id,
            "recipient_id": self.recipient_id,
            "content": self.content,
            "is_read": self.is_read,
        }
        if self.created_at:
            data["created_at"] = self.created_at.isoformat()
        return data


