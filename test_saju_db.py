"""
사주 데이터베이스 테스트 스크립트
사용자별 사주 데이터가 데이터베이스에 정상적으로 저장되었는지 확인
"""

import sqlite3
import json
from pathlib import Path

# 데이터베이스 파일 경로
DB_PATH = Path(__file__).parent / "app.db"

def test_saju_data():
    """사주 데이터베이스 테스트"""
    if not DB_PATH.exists():
        print(f"❌ 데이터베이스 파일을 찾을 수 없습니다: {DB_PATH}")
        return
    
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row  # 딕셔너리 형태로 결과 반환
    cursor = conn.cursor()
    
    print("=" * 60)
    print("사주 데이터베이스 테스트")
    print("=" * 60)
    print()
    
    # 1. 전체 사용자 수 및 사주 데이터 통계
    print("1️⃣ 전체 사용자 및 사주 데이터 통계")
    print("-" * 60)
    cursor.execute("""
        SELECT 
            COUNT(*) AS total_users,
            COUNT(CASE WHEN saju_data IS NOT NULL AND saju_data != '' THEN 1 END) AS users_with_saju,
            COUNT(CASE WHEN saju_data IS NULL OR saju_data = '' THEN 1 END) AS users_without_saju
        FROM users
    """)
    stats = cursor.fetchone()
    print(f"   전체 사용자 수: {stats['total_users']}")
    print(f"   사주 데이터 있는 사용자: {stats['users_with_saju']}")
    print(f"   사주 데이터 없는 사용자: {stats['users_without_saju']}")
    if stats['total_users'] > 0:
        percentage = (stats['users_with_saju'] / stats['total_users']) * 100
        print(f"   사주 데이터 보유율: {percentage:.2f}%")
    print()
    
    # 2. 사주 데이터가 있는 사용자 목록
    print("2️⃣ 사주 데이터가 있는 사용자 목록")
    print("-" * 60)
    cursor.execute("""
        SELECT 
            user_id,
            username,
            email,
            character_type,
            LENGTH(saju_data) AS saju_length,
            created_at
        FROM users
        WHERE saju_data IS NOT NULL 
          AND saju_data != ''
        ORDER BY user_id
    """)
    users_with_saju = cursor.fetchall()
    if users_with_saju:
        for user in users_with_saju:
            print(f"   사용자 ID: {user['user_id']}")
            print(f"   이름: {user['username']}")
            print(f"   이메일: {user['email']}")
            print(f"   캐릭터 타입: {user['character_type'] or '없음'}")
            print(f"   사주 데이터 크기: {user['saju_length']} bytes")
            print(f"   가입일: {user['created_at']}")
            print()
    else:
        print("   ❌ 사주 데이터가 있는 사용자가 없습니다.")
        print()
    
    # 3. 사주 데이터가 없는 사용자 목록
    print("3️⃣ 사주 데이터가 없는 사용자 목록")
    print("-" * 60)
    cursor.execute("""
        SELECT 
            user_id,
            username,
            email,
            created_at
        FROM users
        WHERE saju_data IS NULL 
           OR saju_data = ''
        ORDER BY user_id
    """)
    users_without_saju = cursor.fetchall()
    if users_without_saju:
        for user in users_without_saju:
            print(f"   사용자 ID: {user['user_id']}, 이름: {user['username']}, 이메일: {user['email']}")
    else:
        print("   ✅ 모든 사용자가 사주 데이터를 가지고 있습니다.")
    print()
    
    # 4. 각 사용자의 사주 데이터 상세 내용 (JSON 파싱)
    print("4️⃣ 사주 데이터 상세 내용 (JSON 파싱)")
    print("-" * 60)
    cursor.execute("""
        SELECT 
            user_id,
            username,
            email,
            saju_data
        FROM users
        WHERE saju_data IS NOT NULL 
          AND saju_data != ''
        ORDER BY user_id
    """)
    users = cursor.fetchall()
    for user in users:
        print(f"   사용자 ID: {user['user_id']} ({user['username']})")
        try:
            saju_json = json.loads(user['saju_data'])
            print(f"   ✅ JSON 파싱 성공")
            print(f"   사주 데이터 내용:")
            for key, value in saju_json.items():
                print(f"      {key}: {value}")
        except json.JSONDecodeError as e:
            print(f"   ❌ JSON 파싱 실패: {e}")
            print(f"   원본 데이터 (처음 100자): {user['saju_data'][:100]}")
        print()
    
    # 5. 최근 가입한 사용자 (상위 5명)
    print("5️⃣ 최근 가입한 사용자 (상위 5명)")
    print("-" * 60)
    cursor.execute("""
        SELECT 
            user_id,
            username,
            email,
            CASE 
                WHEN saju_data IS NOT NULL AND saju_data != '' THEN '✅ 있음'
                ELSE '❌ 없음'
            END AS has_saju,
            created_at
        FROM users
        ORDER BY created_at DESC
        LIMIT 5
    """)
    recent_users = cursor.fetchall()
    for user in recent_users:
        print(f"   {user['has_saju']} | ID: {user['user_id']} | {user['username']} ({user['email']}) | {user['created_at']}")
    print()
    
    conn.close()
    print("=" * 60)
    print("테스트 완료")
    print("=" * 60)

if __name__ == "__main__":
    test_saju_data()

