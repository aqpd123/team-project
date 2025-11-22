from typing import Optional, Dict, Any

from sqlalchemy import text

from app.infrastructure.database.db import db


class CompatibilityRepository:
    def __init__(self, database=db) -> None:
        self.database = database

    def create(self, requester_id: int, target_id: int, message: str | None = None) -> int:
        with self.database.session() as session:
            result = session.execute(
                text(
                    """
                    INSERT INTO compatibility_requests (requester_id, target_id, request_message)
                    VALUES (:requester_id, :target_id, :message)
                    """
                ),
                {"requester_id": requester_id, "target_id": target_id, "message": message},
            )
            return int(result.lastrowid)

    def set_response(
        self,
        request_id: int,
        accept: bool,
        scores: Optional[Dict[str, float]] = None,
        description: str | None = None,
    ) -> None:
        status = "accepted" if accept else "rejected"
        scores = scores or {}
        with self.database.session() as session:
            session.execute(
                text(
                    """
                    UPDATE compatibility_requests
                    SET status = :status,
                        responded_at = NOW(),
                        result_original = :result_original,
                        result_final = :result_final,
                        stress = :stress,
                        compatibility_result = :description
                    WHERE request_id = :request_id
                    """
                ),
                {
                    "status": status,
                    "result_original": scores.get("original"),
                    "result_final": scores.get("final"),
                    "stress": scores.get("stress"),
                    "description": description,
                    "request_id": request_id,
                },
            )

    def get(self, request_id: int) -> Optional[Dict[str, Any]]:
        with self.database.session() as session:
            row = session.execute(
                text("SELECT * FROM compatibility_requests WHERE request_id = :request_id"),
                {"request_id": request_id},
            ).mappings().first()
            return dict(row) if row else None


compatibility_repository = CompatibilityRepository()
