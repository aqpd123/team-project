"""Flask 앱의 데이터베이스 연결 확인"""
from app.main import create_app
from app.infrastructure.database.db import db
from sqlalchemy import text

app = create_app()

print("=" * 60)
print("Flask 앱 데이터베이스 연결 확인")
print("=" * 60)

# Flask config에서 DATABASE_URL 확인
db_url_from_config = app.config.get("DATABASE_URL")
print(f"Flask config DATABASE_URL: {db_url_from_config}")

# 실제 db 객체의 데이터베이스 URL 확인
print(f"DB 객체의 _database_url: {db._database_url}")

# 실제 연결된 데이터베이스에서 게시글 수 확인
try:
    with db.session() as s:
        result = s.execute(text("SELECT COUNT(*) FROM posts"))
        post_count = result.scalar()
        print(f"연결된 DB의 게시글 수: {post_count}")
        
        if post_count > 0:
            result = s.execute(text("SELECT post_id, title FROM posts LIMIT 3"))
            posts = result.fetchall()
            print("게시글 샘플:")
            for post in posts:
                print(f"  ID: {post[0]}, 제목: {post[1]}")
except Exception as e:
    print(f"❌ 오류: {e}")
    import traceback
    traceback.print_exc()

print("=" * 60)

