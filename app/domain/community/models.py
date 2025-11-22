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

    @classmethod
    def from_record(cls, record: Dict[str, Any]) -> "Post":
        return cls(**record)

    def to_dict(self) -> Dict[str, Any]:
        data = {
            "post_id": self.post_id,
            "author_id": self.author_id,
            "title": self.title,
            "content": self.content,
            "board_type": self.board_type,
            "view_count": self.view_count,
            "like_count": self.like_count,
        }
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
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    @classmethod
    def from_record(cls, record: Dict[str, Any]) -> "Comment":
        return cls(**record)

    def to_dict(self) -> Dict[str, Any]:
        data = {
            "comment_id": self.comment_id,
            "post_id": self.post_id,
            "author_id": self.author_id,
            "content": self.content,
        }
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


