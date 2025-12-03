"""게시판 API 테스트 스크립트"""
import requests
import json

BASE_URL = "http://192.168.0.7:5000"

print("=" * 60)
print("게시판 API 테스트")
print("=" * 60)
print(f"서버 주소: {BASE_URL}")
print()

# 1. 게시글 목록 조회 (인증 없이)
print("1️⃣ 게시글 목록 조회 (GET /posts)...")
try:
    response = requests.get(f"{BASE_URL}/posts", timeout=5)
    print(f"   상태 코드: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        items = data.get("items", [])
        print(f"   ✅ 성공! 게시글 수: {len(items)}")
        if items:
            print(f"   첫 번째 게시글: {items[0].get('title', 'N/A')}")
        else:
            print("   ⚠️  게시글이 없습니다.")
    else:
        print(f"   ❌ 실패: {response.status_code}")
        print(f"   응답: {response.text[:200]}")
except requests.exceptions.ConnectionError:
    print("   ❌ 서버에 연결할 수 없습니다!")
    print("   백엔드 서버가 실행 중인지 확인하세요.")
except requests.exceptions.Timeout:
    print("   ❌ 요청 시간 초과")
except Exception as e:
    print(f"   ❌ 오류: {e}")

print()
print("=" * 60)

