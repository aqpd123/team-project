from typing import List, Dict, Any

import json
from sqlalchemy import text

from app.infrastructure.database.db import db


class NotificationRepository:
    def __init__(self, database=db) -> None:
        self.database = database

    def create(self, user_id: int, notification_type: str, payload: Dict[str, Any]) -> int:
        with self.database.session() as session:
            result = session.execute(
                text(
                    """
                    INSERT INTO notifications (user_id, type, payload)
                    VALUES (:user_id, :type, :payload)
                    """
                ),
                {"user_id": user_id, "type": notification_type, "payload": json.dumps(payload, ensure_ascii=False)},
            )
            return int(result.lastrowid)

    def list_unread(self, user_id: int) -> List[Dict[str, Any]]:
        with self.database.session() as session:
            rows = session.execute(
                text(
                    """
                    SELECT * FROM notifications
                    WHERE user_id = :user_id AND is_read = 0
                    ORDER BY created_at DESC
                    """
                ),
                {"user_id": user_id},
            ).mappings().all()
            return [dict(row) for row in rows]

    def mark_as_read(self, notification_id: int) -> None:
        with self.database.session() as session:
            session.execute(
                text(
                    "UPDATE notifications SET is_read = 1 WHERE notification_id = :notification_id"
                ),
                {"notification_id": notification_id},
            )


notification_repository = NotificationRepository()
