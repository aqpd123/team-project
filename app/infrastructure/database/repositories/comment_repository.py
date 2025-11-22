from typing import Dict, Any, List

from sqlalchemy import text

from app.infrastructure.database.db import db


class CommentRepository:
    def __init__(self, database=db) -> None:
        self.database = database

    def add(self, post_id: int, author_id: int, content: str) -> int:
        with self.database.session() as session:
            result = session.execute(
                text(
                    """
                    INSERT INTO comments (post_id, author_id, content)
                    VALUES (:post_id, :author_id, :content)
                    """
                ),
                {"post_id": post_id, "author_id": author_id, "content": content},
            )
            return int(result.lastrowid)

    def list_by_post(self, post_id: int) -> List[Dict[str, Any]]:
        with self.database.session() as session:
            rows = session.execute(
                text(
                    """
                    SELECT * FROM comments
                    WHERE post_id = :post_id
                    ORDER BY created_at ASC
                    """
                ),
                {"post_id": post_id},
            ).mappings().all()
            return [dict(row) for row in rows]


comment_repository = CommentRepository()
