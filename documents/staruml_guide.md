# StarUML 클래스 다이어그램 작성 가이드

이 문서는 StarUML에서 사주 분석 앱의 클래스 다이어그램을 작성하는 방법을 안내합니다.

## 1. 프로젝트 설정

1. StarUML 실행 후 새 프로젝트 생성
2. Model Explorer에서 우클릭 → `Add Model` → `Model` 선택
3. 모델 이름: "사주분석_앱"

## 2. 패키지 생성

각 패키지를 다음과 같이 생성합니다:

### 2.1 saju_core 패키지 생성
1. Model Explorer에서 모델 우클릭 → `Add Package`
2. 패키지 이름: `saju_core`

### 2.2 community 패키지 생성
1. Model Explorer에서 모델 우클릭 → `Add Package`
2. 패키지 이름: `community`

### 2.3 celebrity 패키지 생성
1. Model Explorer에서 모델 우클릭 → `Add Package`
2. 패키지 이름: `celebrity`

### 2.4 database 패키지 생성
1. Model Explorer에서 모델 우클릭 → `Add Package`
2. 패키지 이름: `database`

## 3. 클래스 생성 및 속성/메서드 추가

각 패키지에 다음 클래스들을 생성합니다.

### 3.1 saju_core 패키지

#### SajuData 클래스
1. `saju_core` 패키지 우클릭 → `Add Class`
2. 클래스 이름: `SajuData`
3. **속성 추가** (Attributes):
   - `+year_gan: str` (public)
   - `+year_ji: str` (public)
   - `+month_gan: str` (public)
   - `+month_ji: str` (public)
   - `+day_gan: str` (public)
   - `+day_ji: str` (public)
4. **메서드 추가** (Operations):
   - `+pillars(): List[Tuple[str, str]]` (public)

#### DataValidator 클래스
1. 클래스 이름: `DataValidator`
2. **메서드**:
   - `+validate_birth_date(year: int, month: int, day: int): void`
   - `+validate_saju_data(saju: Dict[str, str]): void`
   - `+sanitize_user_input(input_data: Dict[str, Any]): Dict[str, Any]`

#### PersonalityAnalyzer 클래스
1. 클래스 이름: `PersonalityAnalyzer`
2. **메서드**:
   - `+analyze_five_elements(saju: Dict[str, str]): Dict[str, float]`
   - `+calculate_8_traits(saju: Dict[str, str]): Dict[str, float]`
   - `+generate_personality_report(traits: Dict[str, float]): str`

#### CharacterSystem 클래스
1. 클래스 이름: `CharacterSystem`
2. **속성**:
   - `-_CHAR_INFO: Dict[str, Dict[str, str]]` (private)
3. **메서드**:
   - `+get_character_info(character_type: str): Dict[str, str]`
   - `+generate_character_image(character_type: str): str`
   - `+get_personality_description(traits: Dict[str, float]): str`

#### SajuCalculator 클래스
1. 클래스 이름: `SajuCalculator`
2. **속성**:
   - `-validator: DataValidator` (private)
   - `-analyzer: PersonalityAnalyzer` (private)
   - `-characters: CharacterSystem` (private)
   - `-sky_model: Optional[Model]` (private)
   - `-earth_model: Optional[Model]` (private)
3. **메서드**:
   - `+get_birth_data(year: int, month: int, day: int): Dict[str, str]`
   - `+calculate_personal_traits(saju: Dict[str, str]): Dict[str, float]`
   - `+calculate_compatibility(saju1: Dict[str, str], saju2: Dict[str, str], gender1: int, gender2: int): Dict[str, float]`
   - `+determine_character_type(saju: Dict[str, str]): str`
   - `-_build_tokens_from_saju(saju: Dict[str, str]): List[int]` (private)
   - `-_predict_sky(i: int, j: int): float` (private)
   - `-_predict_earth(i: int, j: int): float` (private)
   - `-_original_calculate(token0, token1, gender0, gender1, s): Tuple[float, List[float], List[float]]` (private)

### 3.2 community 패키지

#### User 클래스
1. 클래스 이름: `User`
2. **속성**:
   - `+user_id: int`
   - `+username: str`
   - `+email: str`
   - `+character_type: str`
   - `+saju_data: Dict[str, str]`
3. **메서드**:
   - `+get_profile(): Dict[str, Any]`
   - `+update_character(character_type: str): void`

#### UserService 클래스
1. 클래스 이름: `UserService`
2. **메서드**:
   - `+register_user(username: str, email: str, password: str): User`
   - `+login_user(username: str, password: str): Optional[User]`
   - `+get_user_by_id(user_id: int): Optional[User]`
   - `+update_user_character(user_id: int, character_type: str): void`

#### Post 클래스
1. 클래스 이름: `Post`
2. **속성**:
   - `+post_id: int`
   - `+author_id: int`
   - `+title: str`
   - `+content: str`
   - `+board_type: str`
   - `+created_at: datetime`
   - `+updated_at: datetime`
   - `+view_count: int`
   - `+like_count: int`

#### Comment 클래스
1. 클래스 이름: `Comment`
2. **속성**:
   - `+comment_id: int`
   - `+post_id: int`
   - `+author_id: int`
   - `+content: str`
   - `+created_at: datetime`
   - `+updated_at: datetime`

#### BoardService 클래스
1. 클래스 이름: `BoardService`
2. **메서드**:
   - `+create_post(user_id: int, title: str, content: str, board_type: str): Post`
   - `+get_posts(board_type: str, page: int, limit: int): List[Post]`
   - `+get_post_by_id(post_id: int): Optional[Post]`
   - `+update_post(post_id: int, user_id: int, title: str, content: str): bool`
   - `+delete_post(post_id: int, user_id: int): bool`
   - `+add_comment(post_id: int, user_id: int, content: str): Comment`
   - `+get_comments(post_id: int): List[Comment]`
   - `+like_post(post_id: int, user_id: int): void`

#### CompatibilityRequest 클래스
1. 클래스 이름: `CompatibilityRequest`
2. **속성**:
   - `+request_id: int`
   - `+requester_id: int`
   - `+target_id: int`
   - `+status: str`
   - `+created_at: datetime`
   - `+compatibility_result: Optional[Dict[str, float]]`

#### CompatibilityService 클래스
1. 클래스 이름: `CompatibilityService`
2. **메서드**:
   - `+create_request(requester_id: int, target_id: int): CompatibilityRequest`
   - `+get_requests(user_id: int): List[CompatibilityRequest]`
   - `+accept_request(request_id: int, target_id: int): Optional[Dict[str, float]]`
   - `+reject_request(request_id: int, target_id: int): void`
   - `+calculate_user_compatibility(user1_id: int, user2_id: int): Dict[str, float]`

### 3.3 celebrity 패키지

#### Celebrity 클래스
1. 클래스 이름: `Celebrity`
2. **속성**:
   - `+celebrity_id: int`
   - `+name: str`
   - `+birth_date: datetime`
   - `+saju_data: Dict[str, str]`
   - `+character_type: str`
   - `+profile_image_url: str`

#### CelebrityCompatibilityService 클래스
1. 클래스 이름: `CelebrityCompatibilityService`
2. **메서드**:
   - `+get_celebrity_list(page: int, limit: int): List[Celebrity]`
   - `+get_celebrity_by_id(celebrity_id: int): Optional[Celebrity]`
   - `+calculate_compatibility(user_saju: Dict[str, str], celebrity_id: int): Dict[str, float]`
   - `+get_compatibility_description(compatibility: Dict[str, float]): str`

### 3.4 database 패키지

#### DatabaseManager 클래스
1. 클래스 이름: `DatabaseManager`
2. **메서드**:
   - `+get_connection(): Connection`
   - `+execute_query(query: str, params: tuple): List[Dict]`
   - `+execute_update(query: str, params: tuple): int`
   - `+close_connection(): void`

## 4. 관계 설정

### 4.1 Composition 관계 (강한 포함)

1. `SajuCalculator`에서 `DataValidator`로:
   - `SajuCalculator` 클래스 선택 → 우클릭 → `Add` → `Aggregation` (실제로는 Composition)
   - 연결선 종점을 `DataValidator`로 설정
   - 관계 속성에서 Aggregation을 "Composition"으로 변경 (다이아몬드 채우기)

2. 같은 방식으로:
   - `SajuCalculator` → `PersonalityAnalyzer` (Composition)
   - `SajuCalculator` → `CharacterSystem` (Composition)
   - `Post` → `Comment` (Composition, 1:N - Multiplicity 설정 필요)

### 4.2 Dependency 관계 (의존성)

1. `CompatibilityService`에서 `SajuCalculator`로:
   - `CompatibilityService` 클래스 선택 → 우클릭 → `Add` → `Dependency`
   - 연결선 종점을 `SajuCalculator`로 설정
   - 점선 화살표 표시

2. 같은 방식으로:
   - `CelebrityCompatibilityService` → `SajuCalculator` (Dependency)
   - `PersonalityAnalyzer` → `SajuData` (Dependency)
   - 모든 Service 클래스들 → `DatabaseManager` (Dependency)

### 4.3 Association 관계 (연관)

1. `UserService`에서 `User`로:
   - `UserService` 클래스 선택 → 우클릭 → `Add` → `Association`
   - 연결선 종점을 `User`로 설정
   - 화살표 방향: `UserService` → `User`

2. 같은 방식으로:
   - `BoardService` → `Post` (Association)
   - `BoardService` → `Comment` (Association)
   - `BoardService` → `User` (Association)
   - `CompatibilityService` → `CompatibilityRequest` (Association)
   - `CompatibilityService` → `User` (Association)
   - `CelebrityCompatibilityService` → `Celebrity` (Association)

### 4.4 Multiplicity 설정

1. `User`와 `Post` 관계:
   - User 1개는 여러 개의 Post를 가질 수 있음
   - 연결선에서 Multiplicity 설정: `User` 쪽 `1`, `Post` 쪽 `*` (0..*)

2. `User`와 `CompatibilityRequest` 관계:
   - User 1개는 여러 개의 CompatibilityRequest를 생성할 수 있음
   - Multiplicity: `User` 쪽 `1`, `CompatibilityRequest` 쪽 `*`

3. `Post`와 `Comment` 관계:
   - Post 1개는 여러 개의 Comment를 가질 수 있음
   - Multiplicity: `Post` 쪽 `1`, `Comment` 쪽 `*`

## 5. 다이어그램 생성

1. Model Explorer에서 모델 우클릭 → `Add Diagram` → `Class Diagram`
2. 다이어그램 이름: "사주분석_앱_클래스_다이어그램"
3. Model Explorer에서 각 클래스를 드래그하여 다이어그램에 추가
4. 관계선 연결 (위의 관계 설정 참고)
5. 레이아웃 정리 (자동 정렬 기능 사용 또는 수동 조정)

## 6. 팁

- **속성/메서드 가시성**: `+` (public), `-` (private), `#` (protected)
- **속성 추가**: 클래스 우클릭 → `Add` → `Attribute`
- **메서드 추가**: 클래스 우클릭 → `Add` → `Operation`
- **타입 지정**: 속성/메서드 선택 후 Properties 패널에서 타입 설정
- **관계 라벨**: 관계선 선택 후 Properties 패널에서 이름 설정

## 7. 참고사항

- StarUML에서 Python 타입 표기법 (예: `Dict[str, str]`, `Optional[User]`)을 직접 지원하지 않을 수 있으므로, 필요시 주석으로 추가하거나 타입을 간단히 표기합니다.
- 관계의 Multiplicity는 관계선을 더블클릭하여 속성에서 설정할 수 있습니다.
- 다이어그램이 복잡해지면 여러 개의 다이어그램으로 나누어 작성하는 것을 권장합니다.

