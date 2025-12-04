# 쪽지 기능 디버깅 가이드

## 1. 백엔드 API 직접 테스트

### 방법 1: Python 스크립트 사용 (권장)

```bash
# 가상 환경 활성화
.\.venv311\Scripts\Activate.ps1

# 1. 로그인하여 토큰 가져오기
python test_message_api.py --email your_email@example.com --password your_password

# 2. 토큰이 있는 경우 직접 사용
python test_message_api.py --token YOUR_JWT_TOKEN

# 3. 특정 사용자와의 대화 확인
python test_message_api.py --token YOUR_TOKEN --peer-id 2

# 4. 메시지 전송 테스트
python test_message_api.py --token YOUR_TOKEN --recipient-id 2 --content "테스트 메시지"

# 5. 익명 메시지 전송 테스트
python test_message_api.py --token YOUR_TOKEN --recipient-id 2 --content "익명 테스트" --anonymous
```

### 방법 2: curl 사용

```bash
# 1. 로그인하여 토큰 가져오기
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"your_email@example.com\",\"password\":\"your_password\"}"

# 2. 스레드 목록 가져오기 (토큰을 YOUR_TOKEN으로 교체)
curl -X GET http://localhost:5000/messages/threads \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"

# 3. 특정 사용자와의 대화 가져오기
curl -X GET "http://localhost:5000/messages/conversations/2?is_anonymous=false" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"

# 4. 메시지 전송
curl -X POST http://localhost:5000/messages \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"recipient_id\":2,\"content\":\"테스트 메시지\",\"is_anonymous\":false}"
```

### 방법 3: Postman 또는 Insomnia

1. **로그인 요청**
   - Method: POST
   - URL: `http://localhost:5000/auth/login`
   - Body (JSON):
     ```json
     {
       "email": "your_email@example.com",
       "password": "your_password"
     }
     ```
   - 응답에서 `access_token` 복사

2. **스레드 목록 가져오기**
   - Method: GET
   - URL: `http://localhost:5000/messages/threads`
   - Headers:
     - `Authorization: Bearer YOUR_TOKEN`
     - `Content-Type: application/json`

3. **대화 가져오기**
   - Method: GET
   - URL: `http://localhost:5000/messages/conversations/2?is_anonymous=false`
   - Headers: 위와 동일

4. **메시지 전송**
   - Method: POST
   - URL: `http://localhost:5000/messages`
   - Headers: 위와 동일
   - Body (JSON):
     ```json
     {
       "recipient_id": 2,
       "content": "테스트 메시지",
       "is_anonymous": false
     }
     ```

## 2. 백엔드 로그 확인

### Flask 서버 콘솔 로그 확인

백엔드 서버를 실행하면 다음과 같은 로그가 출력됩니다:

```
list_threads: Returning 4 items for user 1
```

다음 항목을 확인하세요:
- API 요청이 도착하는지
- 응답 데이터가 올바른지
- 에러가 발생하는지

### 백엔드 로그에 print 문 추가

`app/api/controllers/message_controller.py`의 `list_threads` 함수에 이미 로그가 있습니다:

```python
@bp.get("/threads")
@require_auth()
def list_threads():
    current_user = get_current_user()
    # ... 코드 ...
    print(f"list_threads: Returning {len(items)} items for user {current_user['user_id']}")
```

## 3. 프론트엔드 로그 확인

### Flutter 앱 콘솔 로그

Flutter 앱을 실행하면 다음과 같은 로그가 출력됩니다:

```
loadThreads: Fetching threads from API...
loadThreads: API response: {items: [...], count: 4}
loadThreads: Found 4 items
loadThreads: Mapping item: {...}
loadThreads: Mapped thread: peerId=2, peerName=user2
loadThreads: Total threads after mapping: 4
```

### 로그 확인 방법

1. **VS Code에서 실행하는 경우**
   - 터미널에서 `flutter run` 실행
   - 콘솔에 로그가 출력됨

2. **Android Studio에서 실행하는 경우**
   - Run 탭에서 로그 확인
   - Logcat에서 필터링: `flutter`

3. **명령줄에서 실행하는 경우**
   ```bash
   cd FrontEnd/lastlast
   flutter run
   ```

### 확인해야 할 로그

1. **API 호출 전**
   ```
   loadThreads: Fetching threads from API...
   ```

2. **API 응답**
   ```
   loadThreads: API response: {...}
   loadThreads: Found X items
   ```

3. **매핑 과정**
   ```
   loadThreads: Mapping item: {...}
   _mapThread: Input json: {...}
   _mapThread: peerId=X, peerName=Y, isAnonymous=Z
   ```

4. **최종 결과**
   ```
   loadThreads: Total threads after mapping: X
   ```

5. **에러 발생 시**
   ```
   Error mapping thread: ...
   Error loading threads (ApiException): ...
   ```

## 4. 데이터베이스 직접 확인

```bash
# 가상 환경 활성화
.\.venv311\Scripts\Activate.ps1

# 쪽지 통계 확인
python check_messages.py --stats

# 모든 쪽지 확인
python check_messages.py

# 특정 사용자의 쪽지 확인
python check_messages.py --user-id 1

# 대화 스레드 확인
python check_messages.py --threads
```

## 5. 일반적인 문제 진단

### 문제 1: API 응답은 오지만 프론트엔드에 표시되지 않음

**확인 사항:**
1. API 응답 형식이 올바른지 확인
   - `items` 배열이 있는지
   - 각 항목에 `peer` 객체가 있는지
   - `is_anonymous` 필드가 있는지

2. 프론트엔드 매핑 로직 확인
   - `_mapThread` 함수에서 `peer`가 null인지 확인
   - `peer.user_id`가 올바른지 확인

3. Flutter 콘솔에서 에러 로그 확인
   ```
   Error mapping thread: ...
   ```

### 문제 2: API가 빈 배열을 반환함

**확인 사항:**
1. 데이터베이스에 실제로 쪽지가 있는지
   ```bash
   python check_messages.py --stats
   ```

2. 사용자 ID가 올바른지
   - JWT 토큰에서 사용자 ID 확인
   - 데이터베이스에서 해당 사용자의 쪽지 확인

3. 백엔드 로그 확인
   ```
   list_threads: Returning 0 items for user X
   ```

### 문제 3: 익명 쪽지가 표시되지 않음

**확인 사항:**
1. `thread_key`가 `anonymous:`로 시작하는지
   ```bash
   python check_messages.py | grep anonymous
   ```

2. API 응답에 `is_anonymous: true`가 포함되는지

3. 프론트엔드에서 `is_anonymous` 필드를 올바르게 파싱하는지

### 문제 4: peer 정보가 null임

**확인 사항:**
1. 백엔드 `list_threads`에서 `peer` 정보를 올바르게 설정하는지
   - `app/domain/community/services/message_service.py`의 `list_threads` 확인

2. 사용자가 존재하는지
   - 데이터베이스에서 `users` 테이블 확인

3. `other_user_id`가 올바른지

## 6. 단계별 디버깅 체크리스트

- [ ] 백엔드 서버가 실행 중인가?
- [ ] 데이터베이스에 쪽지가 있는가? (`python check_messages.py --stats`)
- [ ] API가 올바른 응답을 반환하는가? (`python test_message_api.py`)
- [ ] JWT 토큰이 유효한가?
- [ ] 프론트엔드에서 API 호출이 성공하는가? (Flutter 콘솔 로그 확인)
- [ ] API 응답 형식이 예상과 일치하는가?
- [ ] 프론트엔드 매핑 로직이 올바른가?
- [ ] `peer` 정보가 null이 아닌가?
- [ ] `is_anonymous` 필드가 올바르게 처리되는가?

## 7. 문제 해결 후 확인

문제를 해결한 후 다음을 확인하세요:

1. **백엔드 API 테스트**
   ```bash
   python test_message_api.py --email your_email --password your_password
   ```

2. **데이터베이스 확인**
   ```bash
   python check_messages.py
   ```

3. **Flutter 앱에서 확인**
   - 쪽지함 페이지 열기
   - 콘솔 로그 확인
   - UI에 쪽지가 표시되는지 확인

