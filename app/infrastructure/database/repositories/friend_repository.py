from __future__ import annotations

from typing import Any, Dict, List, Optional

from sqlalchemy import text

from app.infrastructure.database.db import db


class FriendRepository:
    def __init__(self, database=db) -> None:
        self.database = database

    def create_request(self, requester_id: int, addressee_id: int) -> int:
        with self.database.session() as session:
            result = session.execute(
                text(
                    """
                    INSERT INTO friendships (requester_id, addressee_id, status)
                    VALUES (:requester_id, :addressee_id, 'pending')
                    """
                ),
                {"requester_id": requester_id, "addressee_id": addressee_id},
            )
            return int(result.lastrowid)

    def get(self, friendship_id: int) -> Optional[Dict[str, Any]]:
        with self.database.session() as session:
            row = session.execute(
                text("SELECT * FROM friendships WHERE friendship_id = :fid"),
                {"fid": friendship_id},
            ).mappings().first()
            return dict(row) if row else None

    def find_between(self, user_id: int, other_id: int) -> Optional[Dict[str, Any]]:
        with self.database.session() as session:
            row = session.execute(
                text(
                    """
                    SELECT * FROM friendships
                    WHERE (requester_id = :user_id AND addressee_id = :other_id)
                       OR (requester_id = :other_id AND addressee_id = :user_id)
                    LIMIT 1
                    """
                ),
                {"user_id": user_id, "other_id": other_id},
            ).mappings().first()
            return dict(row) if row else None

    def update_status(self, friendship_id: int, status: str) -> None:
        with self.database.session() as session:
            session.execute(
                text(
                    """
                    UPDATE friendships
                    SET status = :status,
                        responded_at = CASE WHEN :status = 'pending' THEN responded_at ELSE CURRENT_TIMESTAMP END
                    WHERE friendship_id = :fid
                    """
                ),
                {"status": status, "fid": friendship_id},
            )

    def delete(self, friendship_id: int) -> None:
        with self.database.session() as session:
            session.execute(
                text("DELETE FROM friendships WHERE friendship_id = :fid"),
                {"fid": friendship_id},
            )

    def list_friends(self, user_id: int) -> List[Dict[str, Any]]:
        with self.database.session() as session:
            rows = session.execute(
                text(
                    """
                    SELECT * FROM friendships
                    WHERE status = 'accepted' AND (requester_id = :user_id OR addressee_id = :user_id)
                    ORDER BY
                        CASE WHEN responded_at IS NULL THEN 1 ELSE 0 END,
                        responded_at DESC,
                        created_at DESC
                    """
                ),
                {"user_id": user_id},
            ).mappings().all()
            return [dict(row) for row in rows]

    def list_pending(self, user_id: int, inbox: bool = True) -> List[Dict[str, Any]]:
        column = "addressee_id" if inbox else "requester_id"
        with self.database.session() as session:
            rows = session.execute(
                text(
                    f"""
                    SELECT * FROM friendships
                    WHERE status = 'pending' AND {column} = :user_id
                    ORDER BY created_at DESC
                    """
                ),
                {"user_id": user_id},
            ).mappings().all()
            return [dict(row) for row in rows]

    def are_friends(self, user_id: int, other_id: int) -> bool:
        with self.database.session() as session:
            row = session.execute(
                text(
                    """
                    SELECT 1 FROM friendships
                    WHERE status = 'accepted'
                      AND (
                        (requester_id = :user_id AND addressee_id = :other_id)
                        OR
                        (requester_id = :other_id AND addressee_id = :user_id)
                      )
                    LIMIT 1
                    """
                ),
                {"user_id": user_id, "other_id": other_id},
            ).first()
            return row is not None


friend_repository = FriendRepository()


