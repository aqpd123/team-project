"""
댓글 테이블에 anonymous_number 컬럼 추가 및 기존 데이터 마이그레이션 스크립트

사용법:
    python migrate_add_anonymous_number.py
"""
from sqlalchemy import text, create_engine
from app.config import Config
import os
from dotenv import load_dotenv

load_dotenv()

def migrate():
    # 데이터베이스 URL 가져오기
    db_url = os.getenv("DATABASE_URL", "sqlite:///app.db")
    
    # SQLite인 경우 별도 처리
    if db_url.startswith("sqlite"):
        print("SQLite 데이터베이스는 ALTER TABLE이 제한적입니다.")
        print("다음 SQL을 직접 실행하거나 데이터베이스를 재생성하세요:")
        print("ALTER TABLE comments ADD COLUMN anonymous_number INTEGER;")
        return
    
    engine = create_engine(db_url)
    
    with engine.connect() as conn:
        # 트랜잭션 시작
        trans = conn.begin()
        try:
            # 1. anonymous_number 컬럼 추가 (이미 있으면 무시)
            try:
                conn.execute(text("ALTER TABLE comments ADD COLUMN anonymous_number INTEGER"))
                print("✅ anonymous_number 컬럼 추가 완료")
            except Exception as e:
                if "Duplicate column name" in str(e) or "already exists" in str(e).lower():
                    print("ℹ️ anonymous_number 컬럼이 이미 존재합니다.")
                else:
                    raise
            
            # 2. 기존 댓글에 anonymous_number 부여
            # 각 게시물별로 댓글을 작성한 순서대로 번호 부여
            # 같은 author_id가 같은 게시물에 여러 댓글을 달았으면 첫 번째 댓글의 번호 사용
            
            # 먼저 모든 게시물 ID 가져오기
            post_ids = conn.execute(text("SELECT DISTINCT post_id FROM comments")).fetchall()
            
            for (post_id,) in post_ids:
                # 해당 게시물의 댓글을 작성 시간 순으로 가져오기
                comments = conn.execute(
                    text("""
                        SELECT comment_id, author_id, created_at
                        FROM comments
                        WHERE post_id = :post_id
                        ORDER BY created_at ASC
                    """),
                    {"post_id": post_id}
                ).fetchall()
                
                # author_id별로 첫 번째 댓글의 번호를 저장
                author_to_number = {}
                current_number = 1
                
                for comment_id, author_id, created_at in comments:
                    # 이미 번호가 부여된 경우 건너뛰기
                    existing = conn.execute(
                        text("SELECT anonymous_number FROM comments WHERE comment_id = :comment_id"),
                        {"comment_id": comment_id}
                    ).scalar()
                    
                    if existing is not None:
                        # 이미 번호가 있으면 author_to_number에 저장하고 계속
                        if author_id not in author_to_number:
                            author_to_number[author_id] = existing
                        continue
                    
                    # 이 author_id가 처음 댓글을 단 경우
                    if author_id not in author_to_number:
                        author_to_number[author_id] = current_number
                        current_number += 1
                    
                    # 댓글에 번호 부여
                    conn.execute(
                        text("""
                            UPDATE comments
                            SET anonymous_number = :anonymous_number
                            WHERE comment_id = :comment_id
                        """),
                        {"anonymous_number": author_to_number[author_id], "comment_id": comment_id}
                    )
                
                print(f"✅ 게시물 {post_id}의 댓글 번호 부여 완료")
            
            trans.commit()
            print("\n✅ 마이그레이션 완료!")
            
        except Exception as e:
            trans.rollback()
            print(f"❌ 마이그레이션 실패: {e}")
            raise

if __name__ == "__main__":
    migrate()

