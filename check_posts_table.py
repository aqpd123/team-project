"""posts 테이블 확인 스크립트"""
import os
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

from app.infrastructure.database.db import db
from sqlalchemy import text

print("=" * 60)
print("posts 테이블 확인")
print("=" * 60)

try:
    with db.session() as s:
        # 테이블 존재 확인
        result = s.execute(text("SHOW TABLES LIKE 'posts'"))
        table_exists = result.fetchone() is not None
        print(f"posts 테이블 존재: {table_exists}")
        
        if table_exists:
            # 게시글 수 확인
            result = s.execute(text("SELECT COUNT(*) FROM posts"))
            post_count = result.scalar()
            print(f"게시글 수: {post_count}")
            
            if post_count > 0:
                # 최근 게시글 5개 확인
                result = s.execute(text("""
                    SELECT post_id, title, author_id, created_at 
                    FROM posts 
                    ORDER BY created_at DESC 
                    LIMIT 5
                """))
                posts = result.fetchall()
                print("\n최근 게시글:")
                for post in posts:
                    print(f"  ID: {post[0]}, 제목: {post[1]}, 작성자: {post[2]}, 작성일: {post[3]}")
            else:
                print("⚠️  게시글이 없습니다.")
        else:
            print("❌ posts 테이블이 존재하지 않습니다!")
            print("   데이터베이스 스키마를 생성해야 합니다.")
            
except Exception as e:
    print(f"❌ 오류 발생: {e}")
    import traceback
    traceback.print_exc()

print("=" * 60)

