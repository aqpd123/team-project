from typing import Optional, Dict, Any, List

from sqlalchemy import text

from app.infrastructure.database.db import db


class PostRepository:
    def __init__(self, database=db) -> None:
        self.database = database

    def create(self, author_id: int, title: str, content: str, board_type: str | None = None) -> int:
        with self.database.session() as session:
            result = session.execute(
                text(
                    """
                    INSERT INTO posts (author_id, title, content, board_type, updated_at)
                    VALUES (:author_id, :title, :content, :board_type, NOW())
                    """
                ),
                {
                    "author_id": author_id,
                    "title": title,
                    "content": content,
                    "board_type": board_type,
                },
            )
            return int(result.lastrowid)

    def get(self, post_id: int) -> Optional[Dict[str, Any]]:
        with self.database.session() as session:
            row = session.execute(
                text("SELECT * FROM posts WHERE post_id = :post_id"),
                {"post_id": post_id},
            ).mappings().first()
            return dict(row) if row else None

    def list(self, page: int = 1, page_size: int = 20) -> List[Dict[str, Any]]:
        offset = max(page - 1, 0) * page_size
        with self.database.session() as session:
            rows = session.execute(
                text(
                    """
                    SELECT * FROM posts
                    ORDER BY created_at DESC
                    LIMIT :limit OFFSET :offset
                    """
                ),
                {"limit": page_size, "offset": offset},
            ).mappings().all()
            return [dict(row) for row in rows]


post_repository = PostRepository()
