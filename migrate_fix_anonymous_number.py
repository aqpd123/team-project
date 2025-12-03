"""
댓글의 anonymous_number를 글쓴이를 제외하고 재할당하는 마이그레이션 스크립트

사용법:
    python migrate_fix_anonymous_number.py
"""
from sqlalchemy import text, create_engine
from app.config import Config
import os
from dotenv import load_dotenv

load_dotenv()

def migrate():
    # 데이터베이스 URL 가져오기
    db_url = os.getenv("DATABASE_URL", "sqlite:///app.db")
    
    engine = create_engine(db_url)
    
    with engine.connect() as conn:
        # 트랜잭션 시작
        trans = conn.begin()
        try:
            # 모든 게시물 ID 가져오기
            post_ids = conn.execute(text("SELECT DISTINCT post_id FROM comments")).fetchall()
            
            for (post_id,) in post_ids:
                # 게시글의 작성자 확인
                post_author = conn.execute(
                    text("SELECT author_id FROM posts WHERE post_id = :post_id"),
                    {"post_id": post_id}
                ).scalar()
                
                if not post_author:
                    continue
                
                # 해당 게시글의 댓글들을 작성 시간 순으로 가져오기
                comments = conn.execute(
                    text("""
                        SELECT comment_id, author_id 
                        FROM comments 
                        WHERE post_id = :post_id 
                        ORDER BY created_at ASC
                    """),
                    {"post_id": post_id}
                ).fetchall()
                
                current_number = 0
                user_numbers = {}  # 각 사용자의 첫 번째 번호 저장
                
                for comment_id, author_id in comments:
                    # 글쓴이인 경우 NULL로 설정
                    if author_id == post_author:
                        conn.execute(
                            text("UPDATE comments SET anonymous_number = NULL WHERE comment_id = :comment_id"),
                            {"comment_id": comment_id}
                        )
                    else:
                        # 기존에 댓글을 작성한 사용자인지 확인
                        if author_id in user_numbers:
                            # 기존 번호 사용
                            number = user_numbers[author_id]
                        else:
                            # 새로운 번호 할당
                            current_number += 1
                            number = current_number
                            user_numbers[author_id] = number
                        
                        conn.execute(
                            text("UPDATE comments SET anonymous_number = :number WHERE comment_id = :comment_id"),
                            {"number": number, "comment_id": comment_id}
                        )
                
                print(f"✅ 게시물 {post_id}: {len(comments)}개 댓글 처리 완료")
            
            trans.commit()
            print("\n✅ 마이그레이션 완료!")
            
        except Exception as e:
            trans.rollback()
            print(f"❌ 마이그레이션 실패: {e}")
            import traceback
            traceback.print_exc()
            raise

if __name__ == "__main__":
    migrate()

