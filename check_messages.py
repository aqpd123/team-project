#!/usr/bin/env python3
"""
쪽지 데이터베이스 확인 스크립트

사용법:
    python check_messages.py

또는 특정 사용자 ID로 확인:
    python check_messages.py --user-id 1
"""

import argparse
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path

# 프로젝트 루트를 Python 경로에 추가
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

# app.config를 사용하여 데이터베이스 URL 가져오기
try:
    from app.config import get_config
    config = get_config()
    _default_db_url = config.DATABASE_URL
except ImportError:
    # app.config를 사용할 수 없는 경우 환경 변수에서 직접 읽기
    _default_db_url = os.getenv("DATABASE_URL", "sqlite:///app.db")

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker


def get_database_url():
    """데이터베이스 URL 찾기 (SQLite 또는 MySQL)"""
    # 환경 변수에서 확인
    db_url = os.getenv("DATABASE_URL")
    
    if db_url:
        return db_url
    
    # app.config에서 가져온 기본값 사용
    if _default_db_url:
        return _default_db_url
    
    # SQLite 파일 경로 찾기
    default_paths = [
        "app.db",
        "instance/app.db",
        "data/app.db",
    ]
    
    for path in default_paths:
        if os.path.exists(path):
            return f"sqlite:///{path}"
    
    # 기본값: 현재 디렉토리의 app.db
    return "sqlite:///app.db"


def print_messages(session, user_id=None):
    """쪽지 목록 출력"""
    if user_id:
        query = text("""
            SELECT 
                m.message_id,
                m.thread_key,
                m.sender_id,
                u1.username AS sender_name,
                m.recipient_id,
                u2.username AS recipient_name,
                m.content,
                m.is_read,
                m.created_at
            FROM messages m
            LEFT JOIN users u1 ON m.sender_id = u1.user_id
            LEFT JOIN users u2 ON m.recipient_id = u2.user_id
            WHERE m.sender_id = :user_id OR m.recipient_id = :user_id
            ORDER BY m.created_at DESC
        """)
        result = session.execute(query, {"user_id": user_id})
        print(f"\n=== 사용자 ID {user_id}의 모든 쪽지 ===\n")
    else:
        query = text("""
            SELECT 
                m.message_id,
                m.thread_key,
                m.sender_id,
                u1.username AS sender_name,
                m.recipient_id,
                u2.username AS recipient_name,
                m.content,
                m.is_read,
                m.created_at
            FROM messages m
            LEFT JOIN users u1 ON m.sender_id = u1.user_id
            LEFT JOIN users u2 ON m.recipient_id = u2.user_id
            ORDER BY m.created_at DESC
        """)
        result = session.execute(query)
        print("\n=== 모든 쪽지 ===\n")
    
    messages = result.fetchall()
    
    if not messages:
        print("쪽지가 없습니다.")
        return
    
    for msg in messages:
        msg_id, thread_key, sender_id, sender_name, recipient_id, recipient_name, content, is_read, created_at = msg
        read_status = "✓ 읽음" if is_read else "✗ 안 읽음"
        msg_type = "익명" if thread_key.startswith("anonymous:") else "일반"
        
        print(f"[{msg_id}] {msg_type} 쪽지 - {read_status}")
        print(f"  Thread Key: {thread_key}")
        print(f"  보낸 사람: {sender_name} (ID: {sender_id})")
        print(f"  받은 사람: {recipient_name} (ID: {recipient_id})")
        print(f"  내용: {content[:50]}{'...' if len(content) > 50 else ''}")
        print(f"  시간: {created_at}")
        print()


def print_statistics(session):
    """쪽지 통계 출력"""
    query = text("""
        SELECT 
            COUNT(*) AS total_messages,
            SUM(CASE WHEN is_read = 1 THEN 1 ELSE 0 END) AS read_messages,
            SUM(CASE WHEN is_read = 0 THEN 1 ELSE 0 END) AS unread_messages,
            COUNT(DISTINCT thread_key) AS total_threads,
            SUM(CASE WHEN thread_key LIKE 'anonymous:%' THEN 1 ELSE 0 END) AS anonymous_messages
        FROM messages
    """)
    result = session.execute(query).fetchone()
    
    total, read, unread, threads, anonymous = result
    
    print("\n=== 쪽지 통계 ===\n")
    print(f"전체 쪽지: {total}개")
    print(f"읽은 쪽지: {read}개")
    print(f"안 읽은 쪽지: {unread}개")
    print(f"대화 스레드: {threads}개")
    print(f"익명 쪽지: {anonymous}개")
    print()


def print_recent_messages(session, hours=24, is_mysql=False):
    """최근 쪽지 출력"""
    if is_mysql:
        # MySQL용 쿼리
        query = text("""
            SELECT 
                m.message_id,
                m.thread_key,
                m.sender_id,
                u1.username AS sender_name,
                m.recipient_id,
                u2.username AS recipient_name,
                m.content,
                m.is_read,
                m.created_at
            FROM messages m
            LEFT JOIN users u1 ON m.sender_id = u1.user_id
            LEFT JOIN users u2 ON m.recipient_id = u2.user_id
            WHERE m.created_at >= DATE_SUB(NOW(), INTERVAL :hours HOUR)
            ORDER BY m.created_at DESC
        """)
    else:
        # SQLite용 쿼리
        query = text("""
            SELECT 
                m.message_id,
                m.thread_key,
                m.sender_id,
                u1.username AS sender_name,
                m.recipient_id,
                u2.username AS recipient_name,
                m.content,
                m.is_read,
                m.created_at
            FROM messages m
            LEFT JOIN users u1 ON m.sender_id = u1.user_id
            LEFT JOIN users u2 ON m.recipient_id = u2.user_id
            WHERE m.created_at >= datetime('now', '-' || :hours || ' hours')
            ORDER BY m.created_at DESC
        """)
    result = session.execute(query, {"hours": hours})
    
    print(f"\n=== 최근 {hours}시간 내 쪽지 ===\n")
    
    messages = result.fetchall()
    
    if not messages:
        print(f"최근 {hours}시간 내 쪽지가 없습니다.")
        return
    
    for msg in messages:
        msg_id, thread_key, sender_id, sender_name, recipient_id, recipient_name, content, is_read, created_at = msg
        read_status = "✓ 읽음" if is_read else "✗ 안 읽음"
        msg_type = "익명" if thread_key.startswith("anonymous:") else "일반"
        
        print(f"[{msg_id}] {msg_type} 쪽지 - {read_status}")
        print(f"  보낸 사람: {sender_name} (ID: {sender_id})")
        print(f"  받은 사람: {recipient_name} (ID: {recipient_id})")
        print(f"  내용: {content[:50]}{'...' if len(content) > 50 else ''}")
        print(f"  시간: {created_at}")
        print()


def print_threads(session):
    """대화 스레드 목록 출력"""
    query = text("""
        SELECT 
            m.thread_key,
            COUNT(*) AS message_count,
            MAX(m.created_at) AS last_message_time,
            MIN(m.created_at) AS first_message_time
        FROM messages m
        GROUP BY m.thread_key
        ORDER BY last_message_time DESC
    """)
    result = session.execute(query)
    
    print("\n=== 대화 스레드 목록 ===\n")
    
    threads = result.fetchall()
    
    if not threads:
        print("대화 스레드가 없습니다.")
        return
    
    for thread in threads:
        thread_key, count, last_time, first_time = thread
        msg_type = "익명" if thread_key.startswith("anonymous:") else "일반"
        
        print(f"[{msg_type}] {thread_key}")
        print(f"  메시지 수: {count}개")
        print(f"  첫 메시지: {first_time}")
        print(f"  마지막 메시지: {last_time}")
        print()


def main():
    parser = argparse.ArgumentParser(description="쪽지 데이터베이스 확인")
    parser.add_argument("--user-id", type=int, help="특정 사용자 ID의 쪽지만 확인")
    parser.add_argument("--stats", action="store_true", help="통계만 출력")
    parser.add_argument("--recent", type=int, default=24, help="최근 N시간 내 쪽지 확인 (기본: 24)")
    parser.add_argument("--threads", action="store_true", help="대화 스레드 목록만 출력")
    parser.add_argument("--db-url", help="데이터베이스 URL (기본: .env의 DATABASE_URL 또는 자동 탐지)")
    
    args = parser.parse_args()
    
    # 데이터베이스 URL 확인
    db_url = args.db_url or get_database_url()
    
    # SQLite인지 MySQL인지 확인
    is_mysql = db_url.startswith("mysql")
    is_sqlite = db_url.startswith("sqlite")
    
    if is_sqlite:
        # SQLite 파일 경로 추출
        db_path = db_url.replace("sqlite:///", "")
        if not os.path.exists(db_path):
            print(f"오류: 데이터베이스 파일을 찾을 수 없습니다: {db_path}")
            print("\n다음 경로를 확인해보세요:")
            print("  - app.db")
            print("  - instance/app.db")
            print("  - data/app.db")
            print("\n또는 --db-url 옵션으로 직접 URL을 지정하세요.")
            print("예: --db-url sqlite:///app.db")
            sys.exit(1)
        print(f"데이터베이스: SQLite - {db_path}\n")
    elif is_mysql:
        print(f"데이터베이스: MySQL\n")
        print(f"연결 URL: {db_url.split('@')[1] if '@' in db_url else db_url}\n")
    else:
        print(f"데이터베이스: {db_url}\n")
    
    # 데이터베이스 연결
    try:
        engine = create_engine(db_url, pool_pre_ping=True, echo=False)
        Session = sessionmaker(bind=engine)
        session = Session()
        
        # 연결 테스트
        session.execute(text("SELECT 1"))
        print("✅ 데이터베이스 연결 성공\n")
    except Exception as e:
        print(f"❌ 데이터베이스 연결 실패: {e}\n")
        print("다음을 확인해주세요:")
        if is_mysql:
            print("  - MySQL 서버가 실행 중인지")
            print("  - DATABASE_URL이 올바른지")
            print("  - 데이터베이스가 존재하는지")
        else:
            print("  - 데이터베이스 파일 경로가 올바른지")
        sys.exit(1)
    
    try:
        if args.stats:
            print_statistics(session)
        elif args.threads:
            print_threads(session)
        else:
            print_statistics(session)
            print_threads(session)
            print_recent_messages(session, args.recent, is_mysql=is_mysql)
            if args.user_id:
                print_messages(session, args.user_id)
            else:
                print_messages(session)
    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
    finally:
        session.close()


if __name__ == "__main__":
    main()


