"""
데이터베이스 연결 확인 스크립트
현재 어떤 데이터베이스에 연결되어 있는지 확인
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# .env 파일 로드
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

# 데이터베이스 URL 확인
database_url = os.getenv("DATABASE_URL") or "sqlite:///app.db"

print("=" * 60)
print("데이터베이스 연결 정보 확인")
print("=" * 60)
print(f"현재 DATABASE_URL: {database_url}")
print()

# 데이터베이스 타입 확인
if database_url.startswith("sqlite"):
    print("⚠️  현재 SQLite를 사용하고 있습니다.")
    print("   MySQL에 연결하려면 .env 파일에 DATABASE_URL을 설정해야 합니다.")
    db_file = database_url.replace("sqlite:///", "")
    if Path(db_file).exists():
        print(f"   SQLite 파일 위치: {db_file}")
    else:
        print(f"   SQLite 파일이 존재하지 않습니다: {db_file}")
elif database_url.startswith("mysql"):
    print("✅ MySQL 연결 설정이 되어 있습니다.")
    # 비밀번호는 마스킹
    masked_url = database_url
    if "@" in masked_url and ":" in masked_url.split("@")[0]:
        parts = masked_url.split("@")
        user_pass = parts[0].split("://")[1]
        if ":" in user_pass:
            user = user_pass.split(":")[0]
            masked_url = masked_url.replace(user_pass, f"{user}:***")
    print(f"   연결 정보: {masked_url}")
else:
    print(f"⚠️  알 수 없는 데이터베이스 타입: {database_url}")

print()
print("=" * 60)
print("해결 방법:")
print("=" * 60)
print("1. env.example 파일을 .env로 복사")
print("2. .env 파일에서 DATABASE_URL을 MySQL 연결 정보로 수정")
print("   예: DATABASE_URL=mysql+pymysql://user:password@localhost:3306/teamproject?charset=utf8mb4")
print("3. Flask 서버 재시작")
print("=" * 60)

