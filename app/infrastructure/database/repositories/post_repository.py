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
                text(
                    """
                    SELECT p.*, 
                           u.username as author_name,
                           u.character_type as author_character_type,
                           COALESCE(COUNT(DISTINCT c.comment_id), 0) as comment_count
                    FROM posts p
                    LEFT JOIN users u ON p.author_id = u.user_id
                    LEFT JOIN comments c ON p.post_id = c.post_id
                    WHERE p.post_id = :post_id
                    GROUP BY p.post_id, u.username, u.character_type
                    """
                ),
                {"post_id": post_id},
            ).mappings().first()
            return dict(row) if row else None

    def list(self, page: int = 1, page_size: int = 20) -> List[Dict[str, Any]]:
        offset = max(page - 1, 0) * page_size
        with self.database.session() as session:
            rows = session.execute(
                text(
                    """
                    SELECT p.*, 
                           u.username as author_name,
                           u.character_type as author_character_type,
                           COALESCE(COUNT(DISTINCT c.comment_id), 0) as comment_count
                    FROM posts p
                    LEFT JOIN users u ON p.author_id = u.user_id
                    LEFT JOIN comments c ON p.post_id = c.post_id
                    GROUP BY p.post_id, u.username, u.character_type
                    ORDER BY p.created_at DESC
                    LIMIT :limit OFFSET :offset
                    """
                ),
                {"limit": page_size, "offset": offset},
            ).mappings().all()
            return [dict(row) for row in rows]
    
    def toggle_like(self, post_id: int, user_id: int) -> tuple[bool, int]:
        """
        좋아요 토글: 좋아요가 있으면 제거, 없으면 추가
        Returns: (is_liked: bool, new_like_count: int)
        """
        with self.database.session() as session:
            # 기존 좋아요 확인
            existing = session.execute(
                text(
                    """
                    SELECT like_id FROM post_likes
                    WHERE post_id = :post_id AND user_id = :user_id
                    """
                ),
                {"post_id": post_id, "user_id": user_id},
            ).fetchone()
            
            if existing:
                # 좋아요 제거
                session.execute(
                    text(
                        """
                        DELETE FROM post_likes
                        WHERE post_id = :post_id AND user_id = :user_id
                        """
                    ),
                    {"post_id": post_id, "user_id": user_id},
                )
                session.execute(
                    text(
                        """
                        UPDATE posts
                        SET like_count = GREATEST(like_count - 1, 0)
                        WHERE post_id = :post_id
                        """
                    ),
                    {"post_id": post_id},
                )
                is_liked = False
            else:
                # 좋아요 추가
                session.execute(
                    text(
                        """
                        INSERT INTO post_likes (post_id, user_id)
                        VALUES (:post_id, :user_id)
                        """
                    ),
                    {"post_id": post_id, "user_id": user_id},
                )
                session.execute(
                    text(
                        """
                        UPDATE posts
                        SET like_count = like_count + 1
                        WHERE post_id = :post_id
                        """
                    ),
                    {"post_id": post_id},
                )
                is_liked = True
            
            # 새로운 좋아요 개수 가져오기
            new_count = session.execute(
                text("SELECT like_count FROM posts WHERE post_id = :post_id"),
                {"post_id": post_id},
            ).scalar()
            
            return (is_liked, new_count or 0)
    
    def is_liked_by_user(self, post_id: int, user_id: int) -> bool:
        """사용자가 게시글에 좋아요를 눌렀는지 확인"""
        with self.database.session() as session:
            result = session.execute(
                text(
                    """
                    SELECT 1 FROM post_likes
                    WHERE post_id = :post_id AND user_id = :user_id
                    LIMIT 1
                    """
                ),
                {"post_id": post_id, "user_id": user_id},
            ).fetchone()
            return result is not None

    def list_by_author(self, author_id: int, page: int = 1, page_size: int = 20) -> List[Dict[str, Any]]:
        offset = max(page - 1, 0) * page_size
        with self.database.session() as session:
            rows = session.execute(
                text(
                    """
                    SELECT p.*, 
                           u.username as author_name,
                           u.character_type as author_character_type,
                           COALESCE(COUNT(DISTINCT c.comment_id), 0) as comment_count
                    FROM posts p
                    LEFT JOIN users u ON p.author_id = u.user_id
                    LEFT JOIN comments c ON p.post_id = c.post_id
                    WHERE p.author_id = :author_id
                    GROUP BY p.post_id, u.username, u.character_type
                    ORDER BY p.created_at DESC
                    LIMIT :limit OFFSET :offset
                    """
                ),
                {"author_id": author_id, "limit": page_size, "offset": offset},
            ).mappings().all()
            return [dict(row) for row in rows]


post_repository = PostRepository()
