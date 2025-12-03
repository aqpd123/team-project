"""
MySQL 연결 테스트 스크립트
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# .env 파일 로드
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

database_url = os.getenv("DATABASE_URL", "sqlite:///app.db")

print("=" * 60)
print("MySQL 연결 테스트")
print("=" * 60)
print(f"DATABASE_URL: {database_url}")
print()

if not database_url.startswith("mysql"):
    print("❌ MySQL 연결 URL이 아닙니다.")
    print("   .env 파일의 DATABASE_URL을 MySQL 형식으로 수정하세요.")
    print("   예: mysql+pymysql://root:password@127.0.0.1:3306/teamproject?charset=utf8mb4")
    exit(1)

try:
    from sqlalchemy import create_engine, text
    
    print("MySQL 연결 시도 중...")
    engine = create_engine(database_url, pool_pre_ping=True)
    
    with engine.connect() as conn:
        # 연결 테스트
        result = conn.execute(text("SELECT 1"))
        print("✅ MySQL 연결 성공!")
        print()
        
        # 데이터베이스 이름 확인
        result = conn.execute(text("SELECT DATABASE()"))
        db_name = result.scalar()
        print(f"현재 데이터베이스: {db_name}")
        print()
        
        # 사용자 테이블 확인
        try:
            result = conn.execute(text("SELECT COUNT(*) FROM users"))
            user_count = result.scalar()
            print(f"✅ users 테이블 접근 성공")
            print(f"   사용자 수: {user_count}")
            print()
            
            # 사용자 목록 확인
            if user_count > 0:
                result = conn.execute(text("SELECT user_id, username, email FROM users LIMIT 10"))
                users = result.fetchall()
                print("사용자 목록:")
                for user in users:
                    print(f"   ID: {user[0]}, 이름: {user[1]}, 이메일: {user[2]}")
        except Exception as e:
            print(f"❌ users 테이블 접근 실패: {e}")
            print("   테이블이 존재하지 않을 수 있습니다.")
            print("   스키마를 생성해야 합니다.")
        
except ImportError:
    print("❌ 필요한 패키지가 설치되지 않았습니다.")
    print("   다음 명령어로 설치하세요:")
    print("   .\\.venv311\\Scripts\\Activate.ps1")
    print("   pip install sqlalchemy pymysql python-dotenv")
except Exception as e:
    print(f"❌ MySQL 연결 실패: {e}")
    print()
    print("확인 사항:")
    print("1. MySQL 서버가 실행 중인지 확인")
    print("2. .env 파일의 DATABASE_URL이 올바른지 확인")
    print("3. MySQL 사용자명과 비밀번호가 올바른지 확인")
    print("4. teamproject 데이터베이스가 생성되었는지 확인")

print()
print("=" * 60)

