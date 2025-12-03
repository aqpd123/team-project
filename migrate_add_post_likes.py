"""
post_likes 테이블 생성 스크립트

사용법:
    python migrate_add_post_likes.py
"""
from sqlalchemy import text, create_engine
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
        print("""
CREATE TABLE IF NOT EXISTS post_likes (
    like_id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(post_id, user_id)
);
        """)
        return
    
    engine = create_engine(db_url)
    
    with engine.connect() as conn:
        # 트랜잭션 시작
        trans = conn.begin()
        try:
            # post_likes 테이블 생성
            conn.execute(text("""
                CREATE TABLE IF NOT EXISTS post_likes (
                    like_id INTEGER PRIMARY KEY AUTO_INCREMENT,
                    post_id INTEGER NOT NULL,
                    user_id INTEGER NOT NULL,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(post_id, user_id),
                    FOREIGN KEY (post_id) REFERENCES posts(post_id),
                    FOREIGN KEY (user_id) REFERENCES users(user_id)
                )
            """))
            print("✅ post_likes 테이블 생성 완료")
            
            trans.commit()
            print("\n✅ 마이그레이션 완료!")
            
        except Exception as e:
            trans.rollback()
            print(f"❌ 마이그레이션 실패: {e}")
            raise

if __name__ == "__main__":
    migrate()

