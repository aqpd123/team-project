#!/usr/bin/env python3
"""
쪽지 API 테스트 스크립트

사용법:
    python test_message_api.py --user-id 1 --token YOUR_JWT_TOKEN

또는 환경 변수로 설정:
    export USER_ID=1
    export JWT_TOKEN=your_token_here
    python test_message_api.py
"""

import argparse
import json
import os
import sys
from pathlib import Path

import requests
from dotenv import load_dotenv

# 프로젝트 루트를 Python 경로에 추가
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

# .env 파일 로드
try:
    load_dotenv(project_root / ".env")
except ImportError:
    pass

# app.config를 사용하여 API URL 가져오기
try:
    from app.config import get_config
    config = get_config()
    API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:5000")
except ImportError:
    API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:5000")


def print_response(title, response):
    """응답을 보기 좋게 출력"""
    print(f"\n{'='*60}")
    print(f"{title}")
    print(f"{'='*60}")
    print(f"Status Code: {response.status_code}")
    print(f"Headers: {dict(response.headers)}")
    try:
        data = response.json()
        print(f"Response Body:")
        print(json.dumps(data, indent=2, ensure_ascii=False))
    except:
        print(f"Response Text: {response.text}")
    print(f"{'='*60}\n")


def test_list_threads(token, user_id=None):
    """GET /messages/threads 테스트"""
    print(f"\n🔍 테스트: GET /messages/threads")
    print(f"사용자 ID: {user_id or 'N/A'}")
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    
    try:
        response = requests.get(
            f"{API_BASE_URL}/messages/threads",
            headers=headers,
            params={"limit": 20, "offset": 0},
        )
        
        print_response("GET /messages/threads 응답", response)
        
        if response.status_code == 200:
            data = response.json()
            items = data.get("items", [])
            count = data.get("count", len(items))
            
            print(f"✅ 성공: {count}개의 스레드 발견")
            print(f"\n📋 스레드 상세 정보:")
            for i, item in enumerate(items, 1):
                print(f"\n  [{i}] 스레드:")
                print(f"    - peer: {item.get('peer', {})}")
                print(f"    - is_anonymous: {item.get('is_anonymous', False)}")
                print(f"    - content: {item.get('content', '')[:50]}...")
                print(f"    - created_at: {item.get('created_at', '')}")
                print(f"    - unread_count: {item.get('unread_count', 0)}")
                
                # peer 정보 상세 확인
                peer = item.get('peer', {})
                if peer:
                    print(f"    - peer.user_id: {peer.get('user_id')}")
                    print(f"    - peer.username: {peer.get('username')}")
                    print(f"    - peer.email: {peer.get('email')}")
                else:
                    print(f"    ⚠️  peer 정보가 없습니다!")
        else:
            print(f"❌ 실패: HTTP {response.status_code}")
            
        return response
    except requests.exceptions.ConnectionError:
        print(f"❌ 연결 실패: {API_BASE_URL}에 연결할 수 없습니다.")
        print("백엔드 서버가 실행 중인지 확인하세요.")
        return None
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return None


def test_list_conversation(token, peer_id, is_anonymous=False):
    """GET /messages/conversations/<peer_id> 테스트"""
    print(f"\n🔍 테스트: GET /messages/conversations/{peer_id}")
    print(f"is_anonymous: {is_anonymous}")
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    
    try:
        response = requests.get(
            f"{API_BASE_URL}/messages/conversations/{peer_id}",
            headers=headers,
            params={"is_anonymous": str(is_anonymous).lower()},
        )
        
        print_response(f"GET /messages/conversations/{peer_id} 응답", response)
        
        if response.status_code == 200:
            data = response.json()
            items = data.get("items", [])
            count = data.get("count", len(items))
            
            print(f"✅ 성공: {count}개의 메시지 발견")
        else:
            print(f"❌ 실패: HTTP {response.status_code}")
            
        return response
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return None


def test_send_message(token, recipient_id, content, is_anonymous=False):
    """POST /messages 테스트"""
    print(f"\n🔍 테스트: POST /messages")
    print(f"recipient_id: {recipient_id}")
    print(f"content: {content}")
    print(f"is_anonymous: {is_anonymous}")
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    
    payload = {
        "recipient_id": recipient_id,
        "content": content,
        "is_anonymous": is_anonymous,
    }
    
    try:
        response = requests.post(
            f"{API_BASE_URL}/messages",
            headers=headers,
            json=payload,
        )
        
        print_response("POST /messages 응답", response)
        
        if response.status_code == 201:
            print(f"✅ 성공: 메시지 전송 완료")
        else:
            print(f"❌ 실패: HTTP {response.status_code}")
            
        return response
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return None


def get_user_token(email, password):
    """로그인하여 JWT 토큰 가져오기"""
    print(f"\n🔐 로그인 시도: {email}")
    
    try:
        response = requests.post(
            f"{API_BASE_URL}/auth/login",
            json={"email": email, "password": password},
        )
        
        if response.status_code == 200:
            data = response.json()
            # API는 "token"을 반환하지만, "access_token"도 확인
            token = data.get("token") or data.get("access_token")
            user_id = data.get("user", {}).get("user_id")
            print(f"✅ 로그인 성공: user_id={user_id}, token={'있음' if token else '없음'}")
            if not token:
                print(f"⚠️  응답 데이터: {data}")
            return token, user_id
        else:
            print(f"❌ 로그인 실패: HTTP {response.status_code}")
            print(f"응답: {response.text}")
            return None, None
    except Exception as e:
        print(f"❌ 로그인 오류: {e}")
        return None, None


def main():
    global API_BASE_URL
    
    parser = argparse.ArgumentParser(description="쪽지 API 테스트")
    parser.add_argument("--token", help="JWT 토큰 (없으면 로그인 시도)")
    parser.add_argument("--user-id", type=int, help="사용자 ID")
    parser.add_argument("--email", help="로그인 이메일")
    parser.add_argument("--password", help="로그인 비밀번호")
    parser.add_argument("--peer-id", type=int, help="대화 상대 ID (conversation 테스트용)")
    parser.add_argument("--recipient-id", type=int, help="받는 사람 ID (send 테스트용)")
    parser.add_argument("--content", default="테스트 메시지", help="메시지 내용")
    parser.add_argument("--anonymous", action="store_true", help="익명 메시지로 전송")
    parser.add_argument("--api-url", default=API_BASE_URL, help="API 기본 URL")
    
    args = parser.parse_args()
    
    API_BASE_URL = args.api_url
    
    # 토큰 가져오기
    token = args.token
    user_id = args.user_id
    
    if not token:
        if args.email and args.password:
            token, user_id = get_user_token(args.email, args.password)
        else:
            print("❌ 오류: --token 또는 --email/--password를 제공해야 합니다.")
            print("\n사용법:")
            print("  python test_message_api.py --token YOUR_TOKEN")
            print("  python test_message_api.py --email user@example.com --password pass123")
            sys.exit(1)
    
    if not token:
        print("❌ 토큰을 가져올 수 없습니다.")
        sys.exit(1)
    
    # 기본 테스트: list_threads
    print("\n" + "="*60)
    print("📨 쪽지 API 테스트 시작")
    print("="*60)
    
    response = test_list_threads(token, user_id)
    
    # 추가 테스트
    if args.peer_id:
        test_list_conversation(token, args.peer_id, args.anonymous)
    
    if args.recipient_id:
        test_send_message(token, args.recipient_id, args.content, args.anonymous)
        # 전송 후 스레드 목록 다시 확인
        print("\n📋 전송 후 스레드 목록 재확인:")
        test_list_threads(token, user_id)
    
    print("\n" + "="*60)
    print("✅ 테스트 완료")
    print("="*60)


if __name__ == "__main__":
    main()

