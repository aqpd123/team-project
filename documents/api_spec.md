# REST API 명세서 (v1)

본 문서는 사주 분석 앱의 백엔드(Flask) REST API 명세를 정의합니다. Flutter 클라이언트는 본 명세를 기반으로 통신합니다.

- Base URL: `/api/v1`
- Content-Type: `application/json; charset=utf-8`
- 응답 규약: 모든 성공 응답은 HTTP 2xx, 오류는 4xx/5xx와 함께 `error` 페이로드를 반환합니다.
- 시간 표기: ISO 8601 (`YYYY-MM-DDThh:mm:ssZ`)

## 공통 에러 포맷
```json
{
  "error": {
    "code": "INVALID_INPUT",
    "message": "유효하지 않은 요청입니다.",
    "details": {"field": "year"}
  }
}
```
- 주요 코드: `INVALID_INPUT`, `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND`, `CONFLICT`, `INTERNAL_ERROR`

---

## 인증 / 사용자

### 회원가입
- POST `/auth/register`
- 요청
```json
{ "username": "alice", "email": "alice@example.com", "password": "pw" }
```
- 응답 201
```json
{ "user_id": 1, "username": "alice" }
```

### 로그인
- POST `/auth/login`
- 요청
```json
{ "username": "alice", "password": "pw" }
```
- 응답 200
```json
{ "access_token": "<jwt>", "user_id": 1 }
```

### 인증 상태 확인
- GET `/auth/check`
- 응답 200
```json
{ "authenticated": true, "user_id": 1 }
```

인증이 필요한 엔드포인트는 `Authorization: Bearer <jwt>` 헤더를 요구합니다.

---

## 사주 계산(SajuCore)

### 생년월일로 간지 구성(HD2 기반)
- GET `/saju/birth-data?year=2000&month=1&day=15&hour=12&minute=0`
  - `hour`, `minute`는 선택 파라미터(기본 12:00)이며, hd2의 `cal.csv` 절기 경계를 기준으로 연·월·일 천간/지지를 계산합니다.
- 응답 200
```json
{
  "year_gan": "경",
  "year_ji": "진",
  "month_gan": "병",
  "month_ji": "자",
  "day_gan": "계",
  "day_ji": "유",
  "lunar": { "year": "2000", "month": "01", "day": "10", "is_leap": false }
}
```
- 비고: `lunar`는 공공데이터 음력 API를 호출해 얻은 값이며, 외부 API 오류 시 `null`이 될 수 있습니다.

### 개인 8특성 점수만 계산
- POST `/saju/traits`
- 요청
```json
{ "saju": {"year_gan":"을","year_ji":"유","month_gan":"병","month_ji":"인","day_gan":"무","day_ji":"진"} }
```
- 응답 200
```json
{ "traits": {"leadership":0.62,"creativity":0.21,"passion":0.18,"stability":0.14,"discipline":0.23,"communication":0.24,"empathy":0.23,"decisiveness":0.21} }
```

### 개인 성격 종합 분석(오행·8특성·hd2 플래그)
- POST `/saju/analyze-personality`
- 요청
```json
{ "saju": {"year_gan":"을","year_ji":"유","month_gan":"병","month_ji":"인","day_gan":"무","day_ji":"진"}, "gender": 0 }
```
- 응답 200
```json
{
  "five": {"목":0.33,"화":0.17,"토":0.17,"금":0.17,"수":0.17},
  "traits": {"leadership":0.62, "creativity":0.21, "passion":0.18, "stability":0.14, "discipline":0.23, "communication":0.24, "empathy":0.23, "decisiveness":0.21},
  "flags": ["열정 에너지 예술 중독", "의지 솔직 직설 개성 고집 독립심"],
  "report": "강점 상위: leadership:0.62, ..."
}
```
- 비고: `flags`는 hd2 원본 규칙의 자기-자기 비교로 추출한 경향 신호(보조 지표)이며, 궁합용 점수는 포함되지 않습니다.

### 캐릭터 타입 결정(최빈 오행)
- POST `/saju/character-type`
- 요청: 위 `saju`와 동일
- 응답 200
```json
{ "character_type": "목" }
```

### 궁합 계산
- POST `/saju/compatibility`
- 요청
```json
{
  "saju1": {"year_gan":"갑", "year_ji":"자", "month_gan":"병", "month_ji":"인", "day_gan":"무", "day_ji":"진"},
  "saju2": {"year_gan":"을", "year_ji":"유", "month_gan":"정", "month_ji":"묘", "day_gan":"기", "day_ji":"사"},
  "gender1": 1,
  "gender2": 0
}
```
- 응답 200
```json
{ "original": 84.123, "final": 72.456, "stress": 12.3 }
```

---

## 커뮤니티(게시판/댓글/요청)

### 게시글 작성
- POST `/posts` (auth)
- 요청
```json
{ "title":"제목", "content":"내용", "board_type":"free" }
```
- 응답 201
```json
{ "post_id": 101 }
```

### 게시글 목록 조회
- GET `/posts?board_type=free&page=1&limit=20`
- 응답 200
```json
{ "items": [ {"post_id":101,"title":"제목","author_id":1,"created_at":"2025-11-01T12:00:00Z","like_count":3} ], "page":1, "limit":20, "total": 123 }
```

### 게시글 단건 조회
- GET `/posts/{post_id}`
- 응답 200
```json
{ "post_id":101,"title":"제목","content":"내용","author_id":1,"created_at":"...","updated_at":"...","like_count":3 }
```

### 게시글 수정
- PUT `/posts/{post_id}` (auth, 작성자만)
- 요청: `{ "title":"수정제목", "content":"수정내용" }`
- 응답 200: `{ "ok": true }`

### 게시글 삭제
- DELETE `/posts/{post_id}` (auth, 작성자만)
- 응답 204: 본문 없음

### 댓글 작성
- POST `/posts/{post_id}/comments` (auth)
- 요청: `{ "content":"댓글" }`
- 응답 201: `{ "comment_id": 2001 }`

### 댓글 목록 조회
- GET `/posts/{post_id}/comments`
- 응답 200: `{ "items": [ {"comment_id":2001, "content":"댓글", "author_id":1, "created_at":"..."} ] }`

### 좋아요
- POST `/posts/{post_id}/like` (auth)
- 응답 200: `{ "like_count": 4 }`

### 궁합 요청 생성
- POST `/compatibility/requests` (auth)
- 요청: `{ "target_id": 2 }`
- 응답 201: `{ "request_id": 5001, "status": "pending" }`
- 비고: 서버에서 `friends` 관계를 검증하며, 친구가 아닌 사용자에게는 400을 반환합니다.

### 나의 궁합 요청 목록
- GET `/compatibility/requests` (auth)
- 응답 200: `{ "items": [ {"request_id":5001, "target_id":2, "status":"pending", "created_at":"..."} ] }`

### 궁합 요청 수락
- POST `/compatibility/requests/{request_id}/accept` (auth; 대상자만)
- 응답 200
```json
{ "compatibility_result": { "original": 84.123, "final": 72.456, "stress": 12.3 }, "status": "accepted" }
```

### 친구 요청 생성
- POST `/friends/requests` (auth)
- 요청: `{ "target_id": 2 }`
- 응답 201: `{ "friendship_id": 7001, "status": "pending" }`

### 친구 요청 목록
- GET `/friends/requests?box=inbox|outbox` (auth)
- 응답 200
```json
{ "box":"inbox", "items":[{"friendship_id":7001,"requester_id":1,"addressee_id":2,"status":"pending"}], "count":1 }
```

### 친구 요청 응답
- POST `/friends/requests/{friendship_id}/response` (auth; 수신자만)
- 요청: `{ "accept": true }`
- 응답 200: `{ "friendship_id":7001,"status":"accepted","requester_id":1,"addressee_id":2 }`

### 친구 목록 조회
- GET `/friends` (auth)
- 응답 200: `{ "items":[{"friendship_id":7001,"requester_id":1,"addressee_id":2,"status":"accepted"}], "count":1 }`

### 친구 요청 취소
- DELETE `/friends/requests/{friendship_id}` (auth; 요청자만)
- 응답 200: `{ "friendship_id":7001, "status":"cancelled" }`

### 친구 삭제
- DELETE `/friends/{friendship_id}` (auth; 양측 모두 가능)
- 응답 200: `{ "friendship_id":7001, "status":"deleted" }`

---

## 유명인

### 유명인 목록
- GET `/celebrities?page=1&limit=20`
- 응답 200: `{ "items": [ {"celebrity_id":1,"name":"홍길동"} ], "page":1, "limit":20, "total": 50 }`

### 유명인 상세
- GET `/celebrities/{id}`
- 응답 200: `{ "celebrity_id":1, "name":"홍길동", "character_type":"목" }`

### 유명인과의 궁합 계산
- POST `/celebrities/{id}/compatibility` (auth)
- 요청: `{ "user_saju": { ... } }` 또는 서버가 사용자 사주를 보유한 경우 본문 없이 처리
- 응답 200: `{ "original": 84.123, "final": 72.456, "stress": 12.3 }`

---

## 보안/개인정보 가이드
- 클라이언트로 다른 사용자의 `birth_date`나 원본 사주를 직접 전달하지 않습니다.
- 서버는 `users` 테이블에 `saju_data`(간지 6개) 또는 `birth_date`를 저장하고, 계산은 서버 내부에서 수행합니다.
- 민감 데이터는 최소한으로 수집/보관하고, 필요 시 익명화/암호화 적용을 권장합니다.

## 페이징 규약
- 쿼리: `page`(기본 1), `limit`(기본 20, 최대 100)
- 응답: `{ "items": [...], "page": 1, "limit": 20, "total": 123 }`

## 버전/호환성
- 본 문서는 v1 기준입니다. 파괴적 변경은 `/api/v2` 등 새 버전으로 분기합니다.


