from typing import Dict, Any, List

from sqlalchemy import text

from app.common.exceptions import NotFoundError
from app.infrastructure.database.db import db


class CommentRepository:
    def __init__(self, database=db) -> None:
        self.database = database

    def add(self, post_id: int, author_id: int, content: str, anonymous_number: int | None = None) -> int:
        with self.database.session() as session:
            # 게시글의 작성자 확인
            post_row = session.execute(
                text("SELECT author_id FROM posts WHERE post_id = :post_id"),
                {"post_id": post_id},
            ).fetchone()
            
            if not post_row:
                raise NotFoundError(f"게시글(ID: {post_id})을 찾을 수 없습니다.")
            
            post_author_id = post_row[0]
            
            # anonymous_number가 제공되지 않으면 자동으로 계산
            if anonymous_number is None:
                # 글쓴이인 경우 anonymous_number를 NULL로 설정
                if author_id == post_author_id:
                    anonymous_number = None
                else:
                    # 기존 댓글에서 해당 사용자의 첫 번째 댓글 번호 확인
                    existing_comment = session.execute(
                        text(
                            """
                            SELECT anonymous_number FROM comments
                            WHERE post_id = :post_id AND author_id = :author_id
                            ORDER BY created_at ASC
                            LIMIT 1
                            """
                        ),
                        {"post_id": post_id, "author_id": author_id},
                    ).fetchone()
                    
                    if existing_comment and existing_comment[0] is not None:
                        # 이미 댓글을 작성한 사용자는 기존 번호 사용
                        anonymous_number = existing_comment[0]
                    else:
                        # 새로운 사용자: 글쓴이를 제외한 댓글의 최대 번호 + 1
                        max_number = session.execute(
                            text(
                                """
                                SELECT MAX(anonymous_number) FROM comments
                                WHERE post_id = :post_id AND anonymous_number IS NOT NULL
                                """
                            ),
                            {"post_id": post_id},
                        ).scalar()
                        anonymous_number = (max_number or 0) + 1
            
            result = session.execute(
                text(
                    """
                    INSERT INTO comments (post_id, author_id, content, anonymous_number)
                    VALUES (:post_id, :author_id, :content, :anonymous_number)
                    """
                ),
                {"post_id": post_id, "author_id": author_id, "content": content, "anonymous_number": anonymous_number},
            )
            return int(result.lastrowid)

    def list_by_post(self, post_id: int) -> List[Dict[str, Any]]:
        with self.database.session() as session:
            rows = session.execute(
                text(
                    """
                    SELECT c.*, u.username as author_name
                    FROM comments c
                    LEFT JOIN users u ON c.author_id = u.user_id
                    WHERE c.post_id = :post_id
                    ORDER BY c.created_at ASC
                    """
                ),
                {"post_id": post_id},
            ).mappings().all()
            return [dict(row) for row in rows]


comment_repository = CommentRepository()
