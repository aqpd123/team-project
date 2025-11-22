# 클래스 다이어그램 설명서

## 1. 개요
이 클래스 다이어그램은 사주 분석 앱의 전체 시스템 구조를 나타냅니다. 프로그램이 실제로 어떻게 동작하는지 청사진을 제공하며, 프로그래머가 시스템을 이해하고 구현할 수 있도록 설계되었습니다.

## 2. 패키지 구조

### 2.1 saju_core 패키지
사주 계산 및 분석의 핵심 기능을 담당하는 패키지입니다.

#### 2.1.1 SajuData (데이터 클래스)
- **역할**: 사주 데이터를 담는 데이터 구조
- **속성**: 
  - `year_gan`, `year_ji`: 연주(年柱) 천간과 지지
  - `month_gan`, `month_ji`: 월주(月柱) 천간과 지지
  - `day_gan`, `day_ji`: 일주(日柱) 천간과 지지
- **메서드**: `pillars()` - 사주 데이터를 리스트로 변환

#### 2.1.2 DataValidator (검증 클래스)
- **역할**: 사용자 입력 및 사주 데이터의 유효성을 검증
- **주요 메서드**:
  - `validate_birth_date()`: 생년월일 유효성 검사 (2000~2010년 범위)
  - `validate_saju_data()`: 사주 데이터 필수 항목 검증
  - `sanitize_user_input()`: 사용자 입력 정제 및 타입 변환

#### 2.1.3 PersonalityAnalyzer (성격 분석 클래스)
- **역할**: 사주 데이터를 기반으로 오행 분석 및 성격 특성 분석
- **주요 메서드**:
  - `analyze_five_elements()`: 오행(목, 화, 토, 금, 수) 분석
  - `calculate_8_traits()`: 8가지 성격 특성 계산 (리더십, 창의성, 열정, 안정, 규율, 소통, 공감, 결단)
  - `generate_personality_report()`: 성격 분석 보고서 생성
  - 참고: 8특성 산출은 원본 hd2에는 없는 확장 설계이며, hd2식 성향은 `SajuCalculator.calculate_personality_flags_hd2()`가 보조 지표로 제공합니다.

#### 2.1.4 CharacterSystem (오행 캐릭터 시스템)
- **역할**: 오행별 캐릭터 정보 관리 및 제공
- **속성**:
  - `_CHAR_INFO`: 오행별 캐릭터 정보 딕셔너리
- **주요 메서드**:
  - `get_character_info()`: 특정 오행의 캐릭터 정보 반환
  - `generate_character_image()`: 캐릭터 이미지 식별자 생성
  - `get_personality_description()`: 성격 특성 기반 설명 생성

#### 2.1.5 SajuCalculator (사주 계산 메인 클래스)
- **역할**: 사주 계산 및 분석의 메인 컨트롤러
- **의존성**: DataValidator, PersonalityAnalyzer, CharacterSystem
- **속성**:
  - `sky_model`, `earth_model`: TensorFlow 모델 (선택적 로딩)
- **주요 메서드**:
  - `get_birth_data()`: 생년월일을 입력받아 사주 데이터 반환
  - `calculate_personal_traits()`: 개인 성격 특성 계산
  - `calculate_compatibility()`: 두 사람의 궁합 점수 계산 (원본 알고리즘 적용)
  - `determine_character_type()`: 오행 캐릭터 타입 결정
  - `_predict_sky()`, `_predict_earth()`: TensorFlow 모델을 통한 예측
  - `_original_calculate()`: 원본 궁합 계산 알고리즘 (복잡한 규칙 적용)
  - `calculate_personality_flags_hd2(saju, gender)`: 원본(hd2) 규칙을 자기-자기 비교로 호출하여 개인의 성향 신호(8개 키워드 플래그)를 추출(궁합용 점수는 사용하지 않음)
  - `analyze_personality(saju, gender)`: 개인 성격 종합 분석(`five` 오행 분포, `traits` 8특성 점수, `flags` hd2식 성향 키워드, `report` 요약 문자열 반환)

### 2.2 community 패키지
커뮤니티 기능을 담당하는 패키지입니다.

#### 2.2.1 User (사용자 엔티티)
- **역할**: 사용자 정보를 담는 엔티티
- **속성**:
  - `user_id`: 사용자 고유 ID
  - `username`: 사용자명
  - `email`: 이메일
  - `character_type`: 오행 캐릭터 타입
  - `saju_data`: 사용자의 사주 데이터
- **메서드**: `get_profile()`, `update_character()`

#### 2.2.2 UserService (사용자 서비스)
- **역할**: 사용자 관리 비즈니스 로직
- **주요 메서드**:
  - `register_user()`: 신규 사용자 등록
  - `login_user()`: 사용자 로그인
  - `get_user_by_id()`: ID로 사용자 조회
  - `update_user_character()`: 사용자 캐릭터 타입 업데이트

#### 2.2.3 Post (게시글 엔티티)
- **역할**: 게시판 게시글 정보
- **속성**:
  - `post_id`: 게시글 ID
  - `author_id`: 작성자 ID
  - `title`, `content`: 제목 및 내용
  - `board_type`: 게시판 타입 (오행별 게시판, 익명 게시판 등)
  - `created_at`, `updated_at`: 생성/수정 시간
  - `view_count`, `like_count`: 조회수 및 좋아요 수

#### 2.2.4 Comment (댓글 엔티티)
- **역할**: 게시글 댓글 정보
- **속성**: `comment_id`, `post_id`, `author_id`, `content`, `created_at`, `updated_at`

#### 2.2.5 BoardService (게시판 서비스)
- **역할**: 게시판 관련 비즈니스 로직
- **주요 메서드**:
  - `create_post()`: 게시글 작성
  - `get_posts()`: 게시글 목록 조회 (페이지네이션)
  - `get_post_by_id()`: 특정 게시글 조회
  - `update_post()`, `delete_post()`: 게시글 수정/삭제
  - `add_comment()`: 댓글 추가
  - `get_comments()`: 댓글 목록 조회
  - `like_post()`: 게시글 좋아요

#### 2.2.6 CompatibilityRequest (궁합 요청 엔티티)
- **역할**: 사용자 간 궁합 요청 정보
- **속성**:
  - `request_id`: 요청 ID
  - `requester_id`: 요청자 ID
  - `target_id`: 대상자 ID
  - `status`: 요청 상태 (pending, accepted, rejected)
  - `compatibility_result`: 궁합 결과 (수락 후 계산)

#### 2.2.7 CompatibilityService (궁합 서비스)
- **역할**: 사용자 간 궁합 요청 및 계산 관리
- **주요 메서드**:
  - `create_request()`: 궁합 요청 생성
  - `get_requests()`: 사용자의 요청 목록 조회
  - `accept_request()`: 궁합 요청 수락 및 계산
  - `reject_request()`: 궁합 요청 거부
  - `calculate_user_compatibility()`: 사용자 간 궁합 직접 계산
- **의존성**: SajuCalculator를 사용하여 실제 궁합 계산 수행

### 2.3 celebrity 패키지
유명인과의 궁합 기능을 담당하는 패키지입니다.

#### 2.3.1 Celebrity (유명인 엔티티)
- **역할**: 유명인 정보
- **속성**:
  - `celebrity_id`: 유명인 ID
  - `name`: 이름
  - `birth_date`: 생년월일
  - `saju_data`: 사주 데이터
  - `character_type`: 오행 캐릭터 타입
  - `profile_image_url`: 프로필 이미지 URL

#### 2.3.2 CelebrityCompatibilityService (유명인 궁합 서비스)
- **역할**: 유명인과의 궁합 계산 및 제공
- **주요 메서드**:
  - `get_celebrity_list()`: 유명인 목록 조회
  - `get_celebrity_by_id()`: 특정 유명인 조회
  - `calculate_compatibility()`: 사용자와 유명인의 궁합 계산
  - `get_compatibility_description()`: 궁합 결과에 대한 설명 생성
- **의존성**: SajuCalculator를 사용하여 실제 궁합 계산 수행

### 2.4 database 패키지
데이터베이스 접근을 담당하는 패키지입니다.

#### 2.4.1 DatabaseManager (데이터베이스 관리자)
- **역할**: 데이터베이스 연결 및 쿼리 실행
- **주요 메서드**:
  - `get_connection()`: 데이터베이스 연결 가져오기
  - `execute_query()`: SELECT 쿼리 실행
  - `execute_update()`: INSERT/UPDATE/DELETE 쿼리 실행
  - `close_connection()`: 연결 종료

## 3. 클래스 간 관계

### 3.1 구성 관계 (Composition)
- `SajuCalculator`는 `DataValidator`, `PersonalityAnalyzer`, `CharacterSystem`을 포함하여 사용합니다.
- `Post`는 여러 개의 `Comment`를 가질 수 있습니다 (1:N 관계).

### 3.2 의존 관계 (Dependency)
- `CompatibilityService`와 `CelebrityCompatibilityService`는 `SajuCalculator`를 사용하여 궁합을 계산합니다.
- 모든 서비스 클래스는 `DatabaseManager`를 사용하여 데이터를 저장/조회합니다.

### 3.3 연관 관계 (Association)
- `User`는 여러 개의 `Post`를 작성할 수 있습니다 (1:N).
- `User`는 여러 개의 `CompatibilityRequest`를 생성할 수 있습니다 (1:N).

## 4. 구현 가이드

### 4.1 데이터베이스 스키마
각 엔티티 클래스는 데이터베이스 테이블과 매핑됩니다:
- `users` 테이블: User 엔티티
- `posts` 테이블: Post 엔티티
- `comments` 테이블: Comment 엔티티
- `compatibility_requests` 테이블: CompatibilityRequest 엔티티
- `celebrities` 테이블: Celebrity 엔티티

### 4.2 비즈니스 로직 흐름
1. **사주 계산 흐름**:
   - 사용자 입력 → `DataValidator.validate_birth_date()`
   - `SajuCalculator.get_birth_data()` → 사주 데이터 생성
   - `PersonalityAnalyzer.analyze_five_elements()` → 오행 분석
   - `CharacterSystem.get_character_info()` → 캐릭터 타입 결정

2. **궁합 계산 흐름**:
   - 두 사용자의 사주 데이터 → `SajuCalculator.calculate_compatibility()`
   - TensorFlow 모델 예측 → 원본 알고리즘 적용 → 결과 반환

3. **커뮤니티 흐름**:
   - 사용자 게시글 작성 → `BoardService.create_post()`
   - 궁합 요청 → `CompatibilityService.create_request()`
   - 수락 시 → `CompatibilityService.accept_request()` → 궁합 계산

4. **유명인 궁합 흐름**:
   - 유명인 선택 → `CelebrityCompatibilityService.calculate_compatibility()`
   - 사용자 사주와 유명인 사주 비교 → 결과 반환

5. **개인 성격 분석 흐름**:
   - 사용자 사주 준비 → `SajuCalculator.analyze_personality()` 호출
   - `analyze_five_elements()`로 오행 분포 산출 → `calculate_8_traits()`로 8특성 점수 계산
   - `calculate_personality_flags_hd2()`로 hd2식 자기-자기 규칙 기반 성향 키워드(flags) 추출
   - `report`에 상·하위 특성 요약 제공 → 결과(five, traits, flags, report) 반환

### 4.3 탐색/검색 구조 선정
본 앱의 각 기능에서 사용할 자료구조/탐색 알고리즘을 다음과 같이 선정합니다. 실제 구현과 데이터 특성을 반영하여 선택했으며, 성능과 복잡도의 균형을 고려했습니다.

- 사용자/게시글/유명인 단건 조회(ID 기반)
  - 애플리케이션: 해싱(`dict`/`set`) 사용 — 평균 O(1)
  - 데이터베이스: 기본 키 인덱스(B-Tree)

- 게시글 목록 정렬·페이지네이션(최신순/인기순)
  - 데이터베이스: B-Tree 인덱스(`created_at`, `like_count`) 사용 — O(log n) 탐색
  - 메모리 Top-K 유지 필요 시: 힙(`heapq`)으로 상위 K 유지 — 삽입 O(log K)

- 게시글/댓글 키워드 검색
  - 텍스트 전용 역색인 채택: SQLite FTS5(내장) 우선, 규모 확장 시 ElasticSearch 고려
  - 단순 포함 검색만 필요하고 데이터가 매우 작을 때만 순차 탐색 허용

- 이름 오토컴플릿(사용자/유명인 접두사 검색)
  - 소규모: 정렬 리스트 + 이진 탐색(`bisect`)으로 접두사 구간 조회 — O(log n)
  - 대규모/다국어: Trie 또는 검색엔진(FTS)로 승격

- 실시간 인기글 Top-K 유지(슬라이딩 창)
  - 크기 K의 min-heap — 새 점수 유입 시 O(log K), 항상 상위 K 유지
  - 삽입/삭제가 빈번하며 전체 순위를 유지해야 하면 `sortedcontainers` 사용(내부 균형 트리)

- 시간/점수 기반 정렬 집합 유지(랜덤 삽입/삭제+순위 조회)
  - 원칙적으로 레드-블랙 트리류가 적합하나, Python 표준 부재 → DB 인덱스 또는 `sortedcontainers`로 대체

- 소규모 도메인 매핑(오행/간지 테이블)
  - 요소 수가 5~12개 수준이므로 `dict` 해시 또는 간단한 순차 탐색으로 충분

선정 근거 요약
- 순차 탐색: 데이터가 상수 크기일 때 단순·직관
- 이진 탐색: 정렬 리스트 기반 접두사 구간 탐색에 효율적
- 해싱: ID·토큰·캐시 조회의 기본 구조(평균 O(1))
- 균형 트리(대체 포함): 동적 정렬 집합 유지를 위해 DB 인덱스/라이브러리 활용
- 역색인(FTS): 텍스트 검색 품질과 성능을 동시에 확보
- 힙: Top-K 유지에 특화

부록: 예시 코드

접두사 범위 탐색(이진 탐색)
```python
import bisect

names = sorted(["아이유", "아이린", "안유진", "유재석", "윤아"])
prefix = "아이"
lo = bisect.bisect_left(names, prefix)
hi = bisect.bisect_right(names, prefix + "\uffff")  # prefix로 시작하는 구간
candidates = names[lo:hi]
```

실시간 Top-K 유지(힙)
```python
import heapq

top_k = []  # (score, post_id)
K = 10

def push_post(score, post_id):
    if len(top_k) < K:
        heapq.heappush(top_k, (score, post_id))
    elif score > top_k[0][0]:
        heapq.heapreplace(top_k, (score, post_id))
```

#### 4.3.1 유저 탐색 알고리즘 선정 (Pugh 방법)
유저(정확 일치 조회·식별자 기반)의 평균 데이터 규모와 호출 빈도를 고려하여, 다음 후보를 비교했습니다.

- 후보: 순차 탐색, 이진 탐색(정렬 리스트), 해싱(앱 캐시), 레드-블랙 트리(정렬 맵)
- 평가 기준: 속도, 구현 가능성(6주 내), 코드 크기, 오류 가능성
- 기준안(Baseline): 해싱(앱 계층), DB는 기본 키 인덱스(B-Tree)

Pugh 비교표(해싱을 기준 S로, 상대 비교 +/0/-)

| 기준 | 순차 탐색 | 이진 탐색 | 해싱(S) | 레드-블랙 트리 |
|---|---|---|---|---|
| 속도 | -1 | 0 | S | 0 | 
| 구현 가능성 | +1 | 0 | 0 | -1 |
| 코드 크기 | +1 | 0 | 0 | -1 |
| 오류 가능성 | +1 | 0 | 0 | 0 |

결론: 사용자 단건 조회·권한 확인·캐시 키 조회는 해싱(평균 O(1))을 사용하고, 영속 계층은 DB 기본 키/B-Tree 인덱스를 사용합니다. 이름 접두사 오토컴플릿은 소규모에서는 정렬 리스트+이진 탐색, 규모 확대 시 Trie/검색엔진으로 승격합니다.

#### 4.3.2 게시물 검색 알고리즘 선정 (Pugh 방법)
게시물 본문/제목 키워드 검색과 정렬·페이지네이션 요구를 고려하여 다음을 비교했습니다.

- 후보: 순차 포함 검색, LIKE+일반 인덱스, FTS(내장: SQLite FTS5 / PG tsvector / MySQL FULLTEXT), ElasticSearch(전용 검색엔진)
- 평가 기준: 속도, 구현 가능성(6주 내), 확장성, 오류 가능성
- 기준안(Baseline): FTS(내장 엔진) — 초기 릴리스에서 구현/운영 복잡도 대비 효과가 큼

Pugh 비교표(FTS를 기준 S로, 상대 비교 +/0/-)

| 기준 | 순차 포함 | LIKE+인덱스 | FTS(S) | ElasticSearch |
|---|---|---|---|---|
| 속도 | -1 | 0 | S | +1 |
| 구현 가능성 | +1 | 0 | 0 | -1 |
| 확장성 | -1 | -1 | 0 | +1 |
| 오류 가능성 | 0 | 0 | 0 | -1 |

결론: 초기 버전은 DB 내장 FTS로 구현하고(하이라이트/랭킹/형태소 옵션 활용), 트래픽·데이터가 커지면 ElasticSearch로 승격합니다. 정렬과 페이지네이션은 `created_at`, `like_count` B-Tree 인덱스로 지원합니다.

## 5. 주요 설계 원칙

### 5.1 단일 책임 원칙
각 클래스는 하나의 명확한 책임을 가집니다:
- `DataValidator`: 검증만 담당
- `PersonalityAnalyzer`: 성격 분석만 담당
- `CharacterSystem`: 캐릭터 정보 관리만 담당

### 5.2 의존성 역전 원칙
서비스 클래스들은 구체적인 구현이 아닌 인터페이스에 의존합니다.

### 5.3 관심사의 분리
- 비즈니스 로직 (Service 클래스들)
- 데이터 접근 (DatabaseManager)
- 도메인 모델 (Entity 클래스들)

### 5.4 해석 가이드(개인 성격 분석)
- 오행 기반 8특성 점수는 개인의 일반적 성향을 정량화하는 핵심 지표입니다.
- `calculate_personality_flags_hd2()`에서 제공하는 8개 키워드 플래그는 원본(hd2) 궁합 규칙의 ‘살’ 트리거를 자기-자기 비교로 추출한 경향 신호로, 보조 지표로만 사용합니다. 궁합용 점수(org/final/stress)나 성별 가중은 개인 성격 해석에 적용하지 않습니다.

이 클래스 다이어그램을 통해 프로그래머는 시스템의 전체 구조를 이해하고, 각 클래스의 역할과 관계를 파악하여 프로그램을 구현할 수 있습니다.

