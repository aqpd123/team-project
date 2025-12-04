# 시퀀스 다이어그램 vs 실제 구현 비교 분석

## 개요
본 문서는 `documents/sequence` 폴더의 시퀀스 다이어그램과 실제 백엔드 구현 간의 차이점을 분석한 보고서입니다.

---

## 1. seq_auth_login_refresh.puml (인증_로그인_재발급)

### ❌ 주요 불일치 사항

1. **UserService 클래스 사용**
   - 다이어그램: `UserService.login_user()` 사용
   - 실제 구현: `auth_controller`에서 직접 `user_repository.get_by_email()` 사용
   - **영향**: UserService가 존재하지 않음

2. **로그인 파라미터**
   - 다이어그램: `{username, password}`
   - 실제 구현: `{email, password}` (email 사용)

3. **JWT 토큰 구조**
   - 다이어그램: `{access_token, refresh_token}` (두 개의 토큰)
   - 실제 구현: `{token}` (단일 토큰만 반환, refresh_token 없음)

4. **토큰 재발급 기능**
   - 다이어그램: `POST /api/v1/auth/refresh` 엔드포인트 존재
   - 실제 구현: **refresh 엔드포인트가 존재하지 않음**
   - **영향**: 토큰 재발급 기능이 구현되지 않음

5. **엔드포인트 경로**
   - 다이어그램: `/api/v1/auth/login`
   - 실제 구현: `/auth/login` (api/v1 prefix 없음)

### ✅ 일치하는 부분
- 로그인 실패 시 401 반환
- JWT 토큰 생성 및 반환

---

## 2. seq_board_create_post.puml (게시글_작성)

### ⚠️ 주요 불일치 사항

1. **서비스 클래스 이름**
   - 다이어그램: `BoardService`
   - 실제 구현: `CommunityService`
   - **영향**: 클래스 이름만 다름

2. **메서드 반환값**
   - 다이어그램: `Post` 객체 반환
   - 실제 구현: `post_id` (int) 반환 후, 별도로 `get_post()` 호출하여 전체 Post 반환

3. **엔드포인트 경로**
   - 다이어그램: `/api/v1/posts`
   - 실제 구현: `/posts` (api/v1 prefix 없음)

4. **응답 구조**
   - 다이어그램: `201 Created` (Post 객체)
   - 실제 구현: `201 Created {post: {...}}` (딕셔너리 형태)

### ✅ 일치하는 부분
- POST 메서드 사용
- 인증 필요 (@require_auth())
- 게시글 생성 후 DB 저장

---

## 3. seq_celebrity_compatibility.puml (유명인_궁합보기)

### ⚠️ 주요 불일치 사항

1. **서비스 클래스 이름**
   - 다이어그램: `CelebrityCompatibilityService`
   - 실제 구현: `CelebrityService`

2. **메서드 이름**
   - 다이어그램: `get_celebrity_list(page, limit)`
   - 실제 구현: `list_celebrities(keyword)` (키워드 검색 지원, 페이지네이션 없음)

3. **궁합 계산 메서드**
   - 다이어그램: `calculate_compatibility(user_saju, id)`
   - 실제 구현: `calculate_with_celebrity(user_saju, celebrity_id, user_gender, use_ai)`
   - **영향**: 파라미터가 더 많고, AI 인사이트 생성 기능 포함

4. **엔드포인트 경로**
   - 다이어그램: `/api/v1/celebrities?page=&limit=`
   - 실제 구현: `/celebrities?keyword=` (키워드 검색)

5. **응답 구조**
   - 다이어그램: 단순 궁합 점수만 반환
   - 실제 구현: `{celebrity, scores, description, insights, element_relationship}` (더 많은 정보 포함)

### ✅ 일치하는 부분
- 유명인 목록 조회 후 특정 유명인 선택
- 궁합 계산 로직

---

## 4. seq_compat_accept_request.puml (궁합요청_수락)

### ⚠️ 주요 불일치 사항

1. **메서드 이름**
   - 다이어그램: `accept_request(id, target_id=A)`
   - 실제 구현: `accept_compatibility(request_id, actor_id, accept)`
   - **영향**: 메서드 이름과 파라미터 구조가 다름

2. **엔드포인트 경로**
   - 다이어그램: `POST /api/v1/compatibility/requests/{id}/accept`
   - 실제 구현: `POST /compatibility/requests/{request_id}/response`
   - **영향**: 경로와 메서드 이름이 다름

3. **요청 파라미터**
   - 다이어그램: 경로 파라미터만 사용
   - 실제 구현: `{accept: true/false}` (본문에 accept 여부 포함)

4. **사주 데이터 조회 방식**
   - 다이어그램: 단일 쿼리로 두 사용자의 사주를 한 번에 조회
   - 실제 구현: `_require_user()`를 두 번 호출하여 각각 조회

### ✅ 일치하는 부분
- 궁합 계산 후 결과를 DB에 저장
- 상태를 'accepted'로 변경

---

## 5. seq_compat_create_request.puml (궁합요청_생성)

### ⚠️ 주요 불일치 사항

1. **메서드 이름**
   - 다이어그램: `create_request(requester_id, target_id, post_id)`
   - 실제 구현: `request_compatibility(requester_id, target_id, message)`
   - **영향**: 메서드 이름과 파라미터가 다름 (post_id → message)

2. **엔드포인트 경로**
   - 다이어그램: `POST /api/v1/compatibility/requests {target_id, post_id}`
   - 실제 구현: `POST /compatibility/requests {target_id, message}`

3. **중복 확인 로직**
   - 다이어그램: 단순히 pending 상태의 요청만 확인
   - 실제 구현: 친구 관계 확인 후 요청 생성 (친구가 아니면 요청 불가)

4. **알림 생성**
   - 다이어그램: 알림 생성 로직 없음
   - 실제 구현: 요청 생성 시 알림 생성

### ✅ 일치하는 부분
- 중복 요청 확인
- status='pending'으로 초기화

---

## 6. seq_saju_analyze_personality.puml (개인성격분석_요청)

### ⚠️ 주요 불일치 사항

1. **엔드포인트 경로**
   - 다이어그램: `POST /api/v1/saju/analyze-personality`
   - 실제 구현: `POST /saju/traits`
   - **영향**: 엔드포인트 경로가 다름

2. **응답 구조**
   - 다이어그램: `{five, traits, flags, report}`
   - 실제 구현: `{five, traits, flags, report, character, saju}` (character와 saju 추가)

### ✅ 일치하는 부분
- SajuCalculator.analyze_personality() 호출
- PersonalityAnalyzer 메서드 호출 순서
- 반환 데이터 구조 (five, traits, flags, report)

---

## 종합 분석 및 권장사항

### 심각한 불일치 (즉시 수정 권장)

1. **UserService 클래스 사용**
   - 모든 시퀀스 다이어그램에서 UserService를 참조하지만 실제로는 존재하지 않음
   - **권장**: UserService 참조를 제거하고 auth_controller에서 직접 처리하는 것으로 수정

2. **토큰 재발급 기능**
   - seq_auth_login_refresh.puml에 refresh 토큰 기능이 있지만 실제로는 구현되지 않음
   - **권장**: refresh 토큰 기능을 구현하거나, 다이어그램에서 제거

### 중간 수준 불일치 (문서 업데이트 권장)

1. **클래스/메서드 이름 차이**
   - BoardService → CommunityService
   - CelebrityCompatibilityService → CelebrityService
   - create_request → request_compatibility
   - accept_request → accept_compatibility
   - **권장**: 시퀀스 다이어그램을 실제 구현에 맞게 수정

2. **엔드포인트 경로 차이**
   - `/api/v1/...` → `/...` (api/v1 prefix 없음)
   - **권장**: 실제 엔드포인트 경로에 맞게 수정

3. **파라미터 및 응답 구조 차이**
   - 실제 구현이 더 많은 파라미터와 정보를 포함
   - **권장**: 실제 구현에 맞게 업데이트

### 경미한 불일치 (선택적 수정)

1. **응답 구조 세부사항**
   - 실제 구현이 더 많은 정보를 포함 (예: AI 인사이트, 오행 관계 등)
   - **권장**: 실제 구현에 맞게 업데이트하거나, 추가 기능으로 표시

---

## 결론

전반적으로 시퀀스 다이어그램은 실제 구현의 핵심 플로우를 잘 반영하고 있지만, 클래스 이름, 메서드 이름, 엔드포인트 경로 등에서 차이가 있습니다. 

특히 UserService가 존재하지 않는다는 점과 refresh 토큰 기능이 구현되지 않았다는 점은 중요한 불일치이므로, 우선순위에 따라 수정하거나 문서를 업데이트하는 것을 권장합니다.

