import json

from flask import Blueprint, jsonify, request

from app.common.security.auth import require_auth
from app.infrastructure.database.repositories.user_repository import user_repository

bp = Blueprint("users", __name__, url_prefix="/users")


def _serialize_user(row):
    if not row:
        return None
    data = dict(row)
    data.pop("password_hash", None)
    
    user_id = data.get("user_id")
    print(f"📥 사용자 {user_id} 데이터 직렬화 시작")
    
    # birth_date를 문자열로 변환 (DateTime 객체일 수 있음)
    if "birth_date" in data and data["birth_date"] is not None:
        from datetime import datetime
        if isinstance(data["birth_date"], datetime):
            data["birth_date"] = data["birth_date"].strftime("%Y-%m-%d")
        elif not isinstance(data["birth_date"], str):
            data["birth_date"] = str(data["birth_date"])
        print(f"📥 사용자 {user_id} birth_date: {data['birth_date']}")
    
    saju_data = data.pop("saju_data", None)
    print(f"📥 사용자 {user_id} saju_data 존재 여부: {saju_data is not None}")
    if saju_data:
        print(f"📥 사용자 {user_id} saju_data 타입: {type(saju_data)}")
        print(f"📥 사용자 {user_id} saju_data 길이: {len(str(saju_data)) if saju_data else 0}")
        print(f"📥 사용자 {user_id} saju_data 처음 200자: {str(saju_data)[:200] if saju_data else None}")
        
        try:
            # saju_data는 전체 사주 분석 결과를 포함하는 JSON
            saju_result = json.loads(saju_data)
            print(f"✅ 사용자 {user_id} saju_data JSON 파싱 성공")
            print(f"📥 사용자 {user_id} saju_result 타입: {type(saju_result)}")
            
            # 기존 호환성을 위해 saju 필드도 유지
            if isinstance(saju_result, dict):
                print(f"📥 사용자 {user_id} saju_result 키: {list(saju_result.keys())}")
                data["saju_analysis"] = saju_result  # 전체 분석 결과
                data["saju"] = saju_result.get("saju")  # 사주 팔자만 (기존 호환성)
                print(f"✅ 사용자 {user_id} saju_analysis 필드 추가 완료")
            else:
                print(f"⚠️ 사용자 {user_id} saju_result가 dict가 아님: {type(saju_result)}")
                data["saju"] = saju_result
                data["saju_analysis"] = None
        except json.JSONDecodeError as e:
            print(f"❌ 사용자 {user_id} saju_data JSON 파싱 실패: {e}")
            print(f"❌ 사용자 {user_id} saju_data 내용: {str(saju_data)[:500] if saju_data else None}")  # 처음 500자
            import traceback
            traceback.print_exc()
            data["saju"] = None
            data["saju_analysis"] = None
    else:
        print(f"⚠️ 사용자 {user_id} saju_data가 None이거나 비어있음")
        data["saju"] = None
        data["saju_analysis"] = None
    
    print(f"📤 사용자 {user_id} 직렬화 완료, saju_analysis 존재: {'saju_analysis' in data and data['saju_analysis'] is not None}")
    return data


@bp.get("")
@require_auth()
def list_users():
    page = int(request.args.get("page", 1))
    page_size = int(request.args.get("page_size", 20))
    rows = user_repository.list(page=page, page_size=page_size)
    return jsonify(
        {
            "items": [_serialize_user(row) for row in rows],
            "count": len(rows),
            "page": page,
        }
    )


@bp.get("/<int:user_id>")
@require_auth()
def get_user(user_id: int):
    print(f"🔍 GET /users/{user_id} 요청 받음")
    user = user_repository.get_by_id(user_id)
    if not user:
        print(f"❌ 사용자 {user_id}를 찾을 수 없음")
        return jsonify({"error": "사용자를 찾을 수 없습니다."}), 404
    
    serialized = _serialize_user(user)
    print(f"📤 사용자 {user_id} 직렬화된 데이터 반환")
    if serialized:
        print(f"📤 saju_analysis 필드 존재: {'saju_analysis' in serialized}")
        if 'saju_analysis' in serialized and serialized['saju_analysis']:
            print(f"📤 saju_analysis 타입: {type(serialized['saju_analysis'])}")
            if isinstance(serialized['saju_analysis'], dict):
                print(f"📤 saju_analysis 키: {list(serialized['saju_analysis'].keys())}")
    return jsonify(serialized)


@bp.patch("/<int:user_id>")
@require_auth()
def update_user(user_id: int):
    """사용자 정보 업데이트 (닉네임, 비밀번호 등)"""
    from app.common.security.auth import get_current_user
    from werkzeug.security import generate_password_hash, check_password_hash
    
    current_user = get_current_user()
    if current_user.get("user_id") != user_id:
        return jsonify({"error": "본인의 정보만 수정할 수 있습니다."}), 403
    
    data = request.get_json() or {}
    username = data.get("username")
    new_password = data.get("new_password")
    current_password = data.get("current_password")
    
    # 업데이트할 항목이 없으면 오류
    if username is None and new_password is None:
        return jsonify({"error": "업데이트할 정보가 없습니다."}), 400
    
    # 비밀번호 변경 시 현재 비밀번호 확인 필요
    if new_password is not None:
        if not current_password:
            return jsonify({"error": "현재 비밀번호를 입력해주세요."}), 400
        
        # 현재 비밀번호 확인
        user = user_repository.get_by_id(user_id)
        if not user:
            return jsonify({"error": "사용자를 찾을 수 없습니다."}), 404
        
        if not check_password_hash(user["password_hash"], current_password):
            return jsonify({"error": "현재 비밀번호가 일치하지 않습니다."}), 400
        
        # 새 비밀번호 유효성 검사
        if len(new_password) < 6:
            return jsonify({"error": "비밀번호는 6자 이상이어야 합니다."}), 400
    
    # 닉네임 유효성 검사
    if username is not None:
        if not isinstance(username, str) or len(username.strip()) < 2:
            return jsonify({"error": "닉네임은 2자 이상이어야 합니다."}), 400
    
    try:
        # 비밀번호 해시 생성
        password_hash = None
        if new_password is not None:
            password_hash = generate_password_hash(new_password)
        
        # 사용자 정보 업데이트
        user_repository.update_user_info(
            user_id=user_id,
            username=username.strip() if username else None,
            password_hash=password_hash,
        )
        
        # 업데이트된 사용자 정보 반환
        updated_user = user_repository.get_by_id(user_id)
        if not updated_user:
            return jsonify({"error": "사용자를 찾을 수 없습니다."}), 404
        
        serialized = _serialize_user(updated_user)
        return jsonify(serialized)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


