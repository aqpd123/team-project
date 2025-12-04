# 수정된 시퀀스 다이어그램

본 폴더에는 실제 구현된 백엔드 코드를 기반으로 수정된 시퀀스 다이어그램이 포함되어 있습니다.

## 파일 목록

1. **seq_auth_login.puml** - 인증 및 로그인 시퀀스 (refresh 토큰 기능 제거)
2. **seq_board_create_post.puml** - 게시글 작성 시퀀스 (CommunityService 사용)
3. **seq_celebrity_compatibility.puml** - 유명인 궁합 보기 시퀀스 (CelebrityService 사용)
4. **seq_compat_accept_request.puml** - 궁합 요청 수락 시퀀스 (accept_compatibility 메서드)
5. **seq_compat_create_request.puml** - 궁합 요청 생성 시퀀스 (request_compatibility 메서드, 친구 관계 검증 포함)
6. **seq_saju_analyze_personality.puml** - 개인 성격 분석 시퀀스 (엔드포인트 경로 수정)

## 주요 변경 사항

### 1. seq_auth_login.puml
- **UserService 제거**: auth_controller에서 직접 UserRepository 사용
- **로그인 파라미터**: username → email로 변경
- **JWT 토큰**: access_token, refresh_token → token (단일 토큰)로 변경
- **refresh 토큰 기능 제거**: 실제 구현에 없으므로 제거
- **엔드포인트**: `/api/v1/auth/login` → `/auth/login`으로 변경

### 2. seq_board_create_post.puml
- **서비스 클래스**: BoardService → CommunityService
- **Repository 패턴**: DatabaseManager → PostRepository로 변경
- **반환값**: Post 객체 → post_id 후 get_post() 호출로 변경
- **알림 생성**: 추가됨
- **엔드포인트**: `/api/v1/posts` → `/posts`로 변경

### 3. seq_celebrity_compatibility.puml
- **서비스 클래스**: CelebrityCompatibilityService → CelebrityService
- **메서드 이름**: 
  - `get_celebrity_list()` → `list_celebrities()`
  - `calculate_compatibility()` → `calculate_with_celebrity()`
- **파라미터**: user_gender, use_ai 추가
- **응답 구조**: AI 인사이트, 오행 관계 설명 추가
- **엔드포인트**: `/api/v1/celebrities` → `/celebrities`로 변경
- **쿼리 파라미터**: page, limit → keyword로 변경

### 4. seq_compat_accept_request.puml
- **메서드 이름**: `accept_request()` → `accept_compatibility()`
- **파라미터**: `(id, target_id)` → `(request_id, actor_id, accept)`
- **엔드포인트**: `/api/v1/compatibility/requests/{id}/accept` → `/compatibility/requests/{request_id}/response`
- **요청 본문**: `{accept: true/false}` 추가
- **사주 조회**: 단일 쿼리 → 각 사용자별로 조회
- **알림 생성**: 추가됨

### 5. seq_compat_create_request.puml
- **메서드 이름**: `create_request()` → `request_compatibility()`
- **파라미터**: `post_id` → `message`로 변경
- **친구 관계 검증**: 추가됨 (친구가 아니면 요청 불가)
- **알림 생성**: 추가됨
- **엔드포인트**: `/api/v1/compatibility/requests` → `/compatibility/requests`로 변경

### 6. seq_saju_analyze_personality.puml
- **엔드포인트**: `/api/v1/saju/analyze-personality` → `/saju/traits`로 변경
- **응답 구조**: `character`, `saju` 필드 추가
- **CharacterSystem**: `determine()` 메서드 호출 추가

## 사용 방법

PlantUML 도구를 사용하여 시각화할 수 있습니다:
- 온라인: http://www.plantuml.com/plantuml/
- VS Code 확장: PlantUML
- IntelliJ IDEA 플러그인: PlantUML integration

## 원본 파일과의 차이점

원본 파일(`documents/sequence/` 폴더)과의 주요 차이점은 `SEQUENCE_DIAGRAM_ANALYSIS.md` 파일에서 상세히 확인할 수 있습니다.

## 업데이트 일자

2025-01-XX (실제 구현 코드 기준)

