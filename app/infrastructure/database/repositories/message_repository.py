from __future__ import annotations

from typing import Any, Dict, List, Optional

from sqlalchemy import text

from app.infrastructure.database.db import db


class MessageRepository:
    def __init__(self, database=db) -> None:
        self.database = database

    def create(self, sender_id: int, recipient_id: int, content: str, is_anonymous: bool = False) -> int:
        thread_key = self._thread_key(sender_id, recipient_id, is_anonymous=is_anonymous)
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
        is_anonymous: bool = False,
    ) -> List[Dict[str, Any]]:
        thread_key = self._thread_key(user_id, other_id, is_anonymous=is_anonymous)
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

    def mark_read(self, user_id: int, other_id: int, is_anonymous: bool = False) -> None:
        thread_key = self._thread_key(user_id, other_id, is_anonymous=is_anonymous)
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
                    WITH latest_messages AS (
                        SELECT
                            m.*,
                            ROW_NUMBER() OVER (
                                PARTITION BY m.thread_key 
                                ORDER BY m.created_at DESC, m.message_id DESC
                            ) AS rn
                        FROM messages m
                        WHERE m.sender_id = :user_id OR m.recipient_id = :user_id
                    ),
                    unread AS (
                        SELECT
                            thread_key,
                            CAST(SUM(CASE WHEN recipient_id = :user_id AND is_read = 0 THEN 1 ELSE 0 END) AS UNSIGNED) AS unread_count
                        FROM messages
                        WHERE sender_id = :user_id OR recipient_id = :user_id
                        GROUP BY thread_key
                    )
                    SELECT
                        lm.*,
                        CASE
                            WHEN lm.sender_id = :user_id THEN lm.recipient_id
                            ELSE lm.sender_id
                        END AS other_user_id,
                        CAST(COALESCE(unread.unread_count, 0) AS UNSIGNED) AS unread_count,
                        CASE
                            WHEN lm.thread_key LIKE 'anonymous:%' THEN 1
                            ELSE 0
                        END AS is_anonymous
                    FROM latest_messages lm
                    LEFT JOIN unread ON unread.thread_key = lm.thread_key
                    WHERE lm.rn = 1
                    ORDER BY lm.created_at DESC, lm.message_id DESC
                    LIMIT :limit OFFSET :offset
                    """
                ),
                {"user_id": user_id, "limit": limit, "offset": offset},
            ).mappings().all()
            return [dict(row) for row in rows]

    def _thread_key(self, user_a: int, user_b: int, is_anonymous: bool = False) -> str:
        lower = min(user_a, user_b)
        higher = max(user_a, user_b)
        if is_anonymous:
            return f"anonymous:{lower}:{higher}"
        return f"{lower}:{higher}"


message_repository = MessageRepository()


