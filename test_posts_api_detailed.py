"""게시판 API 상세 테스트"""
import requests
import json

BASE_URL = "http://192.168.0.7:5000"

print("=" * 60)
print("게시판 API 상세 테스트")
print("=" * 60)

# 게시글 목록 조회
print("GET /posts 요청...")
try:
    response = requests.get(
        f"{BASE_URL}/posts",
        params={"page": 1, "page_size": 50},
        timeout=10
    )
    print(f"상태 코드: {response.status_code}")
    print(f"헤더: {dict(response.headers)}")
    print()
    
    if response.status_code == 200:
        data = response.json()
        print(f"응답 데이터 타입: {type(data)}")
        print(f"응답 키: {list(data.keys()) if isinstance(data, dict) else 'N/A'}")
        print()
        
        items = data.get("items", [])
        count = data.get("count", 0)
        page = data.get("page", 0)
        
        print(f"게시글 수 (count): {count}")
        print(f"게시글 수 (items 길이): {len(items)}")
        print(f"페이지: {page}")
        print()
        
        if items:
            print("게시글 목록:")
            for i, item in enumerate(items[:5], 1):
                print(f"  {i}. ID: {item.get('post_id')}, 제목: {item.get('title')}")
        else:
            print("⚠️  게시글이 없습니다.")
            print("전체 응답:")
            print(json.dumps(data, indent=2, ensure_ascii=False))
    else:
        print(f"❌ 실패: {response.status_code}")
        print(f"응답 본문: {response.text}")
        
except requests.exceptions.ConnectionError:
    print("❌ 서버에 연결할 수 없습니다!")
    print("백엔드 서버가 실행 중인지 확인하세요.")
    print("실행 명령: .\\start_backend.ps1")
except Exception as e:
    print(f"❌ 오류: {e}")
    import traceback
    traceback.print_exc()

print("=" * 60)

