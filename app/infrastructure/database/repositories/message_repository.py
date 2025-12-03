from __future__ import annotations

from typing import Any, Dict, List, Optional

from sqlalchemy import text

from app.infrastructure.database.db import db


class MessageRepository:
    def __init__(self, database=db) -> None:
        self.database = database

    def create(self, sender_id: int, recipient_id: int, content: str) -> int:
        thread_key = self._thread_key(sender_id, recipient_id)
        with self.database.session() as session:
            result = session.execute(
                text(
                    """
                    INSERT INTO messages (thread_key, sender_id, recipient_id, content)
                    VALUES (:thread_key, :sender_id, :recipient_id, :content)
                    """
                ),
                {
                    "thread_key": thread_key,
                    "sender_id": sender_id,
                    "recipient_id": recipient_id,
                    "content": content,
                },
            )
            return int(result.lastrowid)

    def get(self, message_id: int) -> Optional[Dict[str, Any]]:
        with self.database.session() as session:
            row = session.execute(
                text("SELECT * FROM messages WHERE message_id = :mid"),
                {"mid": message_id},
            ).mappings().first()
            return dict(row) if row else None

    def list_conversation(
        self,
        user_id: int,
        other_id: int,
        limit: int = 50,
        before_id: Optional[int] = None,
    ) -> List[Dict[str, Any]]:
        thread_key = self._thread_key(user_id, other_id)
        query = [
            "SELECT * FROM messages",
            "WHERE thread_key = :thread_key",
            "AND (sender_id = :user_id OR recipient_id = :user_id)",
        ]
        params: Dict[str, Any] = {
            "thread_key": thread_key,
            "user_id": user_id,
            "limit": limit,
        }
        if before_id:
            query.append("AND message_id < :before_id")
            params["before_id"] = before_id
        query.append("ORDER BY message_id DESC")
        query.append("LIMIT :limit")
        with self.database.session() as session:
            rows = session.execute(
                text("\n".join(query)),
                params,
            ).mappings().all()
            return [dict(row) for row in rows]

    def mark_read(self, user_id: int, other_id: int) -> None:
        thread_key = self._thread_key(user_id, other_id)
        with self.database.session() as session:
            session.execute(
                text(
                    """
                    UPDATE messages
                    SET is_read = 1
                    WHERE thread_key = :thread_key
                      AND recipient_id = :user_id
                      AND is_read = 0
                    """
                ),
                {"thread_key": thread_key, "user_id": user_id},
            )

    def list_threads(self, user_id: int, limit: int = 20, offset: int = 0) -> List[Dict[str, Any]]:
        with self.database.session() as session:
            rows = session.execute(
                text(
                    """
                    WITH latest AS (
                        SELECT
                            thread_key,
                            MAX(created_at) AS latest_created_at
                        FROM messages
                        WHERE sender_id = :user_id OR recipient_id = :user_id
                        GROUP BY thread_key
                    ),
                    unread AS (
                        SELECT
                            thread_key,
                            SUM(CASE WHEN recipient_id = :user_id AND is_read = 0 THEN 1 ELSE 0 END) AS unread_count
                        FROM messages
                        WHERE sender_id = :user_id OR recipient_id = :user_id
                        GROUP BY thread_key
                    )
                    SELECT
                        m.*,
                        CASE
                            WHEN m.sender_id = :user_id THEN m.recipient_id
                            ELSE m.sender_id
                        END AS other_user_id,
                        COALESCE(unread.unread_count, 0) AS unread_count
                    FROM messages m
                    JOIN latest ON latest.thread_key = m.thread_key AND latest.latest_created_at = m.created_at
                    LEFT JOIN unread ON unread.thread_key = m.thread_key
                    WHERE m.sender_id = :user_id OR m.recipient_id = :user_id
                    ORDER BY m.created_at DESC
                    LIMIT :limit OFFSET :offset
                    """
                ),
                {"user_id": user_id, "limit": limit, "offset": offset},
            ).mappings().all()
            return [dict(row) for row in rows]

    def _thread_key(self, user_a: int, user_b: int) -> str:
        lower = min(user_a, user_b)
        higher = max(user_a, user_b)
        return f"{lower}:{higher}"


message_repository = MessageRepository()


