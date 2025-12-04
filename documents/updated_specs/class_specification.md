# 클래스 명세서 (실제 구현 기반)

## 1. SajuCalculator 클래스

### 1.1 개요
**역할**: 사주 계산 및 분석의 메인 컨트롤러 클래스  
**패키지**: saju_core  
**설명**: 생년월일을 입력받아 사주 데이터를 생성하고, 오행 분석, 성격 특성 분석, 궁합 계산 등의 핵심 기능을 수행합니다.

### 1.2 속성 (Attributes)

| 속성명 | 타입 | 접근제어자 | 설명 |
|--------|------|------------|------|
| validator | DataValidator | private | 데이터 검증을 담당하는 객체 |
| analyzer | PersonalityAnalyzer | private | 성격 분석을 담당하는 객체 |
| characters | CharacterSystem | private | 오행 캐릭터 정보를 관리하는 객체 |
| calendar_client | Optional[CalendarClientProtocol] | private | 음력 변환을 위한 외부 API 클라이언트 (선택적) |
| ganji_calculator | GanjiCalculator | private | 간지 계산을 담당하는 객체 |
| sky_model | Optional[Model] | private | 천간 궁합 예측을 위한 TensorFlow 모델 (선택적, lazy-load) |
| earth_model | Optional[Model] | private | 지지 궁합 예측을 위한 TensorFlow 모델 (선택적, lazy-load) |

### 1.3 메서드 (Methods)

#### 1.3.1 get_birth_data()
**목적**: 생년월일과 시간을 입력받아 사주 데이터를 생성하고 반환합니다.

**시그니처**:  
```python
def get_birth_data(self, year: int, month: int, day: int, hour: int = 12, minute: int = 0) -> Dict[str, Any]
```

**파라미터**:
- `year` (int): 태어난 연도 (2000~2010 범위)
- `month` (int): 태어난 월 (1~12)
- `day` (int): 태어난 일 (1~31)
- `hour` (int): 태어난 시 (기본값: 12)
- `minute` (int): 태어난 분 (기본값: 0)

**반환값**:  
`Dict[str, Any]` - 사주 데이터 딕셔너리
```python
{
    "year_gan": "갑",    # 연주 천간
    "year_ji": "자",     # 연주 지지
    "month_gan": "병",   # 월주 천간
    "month_ji": "인",    # 월주 지지
    "day_gan": "무",     # 일주 천간
    "day_ji": "진",      # 일주 지지
    "lunar": {           # 음력 정보 (선택적, 외부 API 사용 가능 시)
        "year": "2000",
        "month": "01",
        "day": "10",
        "is_leap": false
    }
}
```

**처리 과정**:
1. `validator.validate_birth_date()`로 입력값 검증
2. `ganji_calculator.calculate()`로 간지 계산 (cal.csv 절기 경계 기준)
3. `calendar_client`가 있으면 음력 변환 시도 (실패 시 null)
4. 사주 데이터 딕셔너리 구성하여 반환

**예외 처리**:
- `ValidationError`: 연도가 2000~2010 범위를 벗어나거나 유효하지 않은 날짜인 경우

---

#### 1.3.2 calculate_personal_traits()
**목적**: 사주 데이터를 기반으로 개인의 오행 분포, 8가지 성격 특성, 리포트를 계산합니다.

**시그니처**:  
```python
def calculate_personal_traits(self, saju: Dict[str, str]) -> Dict[str, Any]
```

**파라미터**:
- `saju` (Dict[str, str]): 사주 데이터 딕셔너리

**반환값**:  
`Dict[str, Any]` - 오행, 특성, 리포트를 포함한 딕셔너리
```python
{
    "five": {
        "wood": 0.33,
        "fire": 0.17,
        "earth": 0.17,
        "metal": 0.17,
        "water": 0.17
    },
    "traits": {
        "passion": 0.62,
        "intuition": 0.21,
        "mood_swing": 0.18,
        "courage": 0.14,
        "responsibility": 0.23,
        "conflict": 0.24,
        "charisma": 0.23,
        "independence": 0.21
    },
    "report": "passion:0.62, conflict:0.24, charisma:0.23"
}
```

**처리 과정**:
1. `validator.validate_saju_data()`로 사주 데이터 검증
2. `analyzer.analyze_five_elements()` 호출하여 오행 분포 계산
3. `analyzer.calculate_8_traits()` 호출하여 성격 특성 계산
4. `analyzer.generate_personality_report()` 호출하여 리포트 생성

---

#### 1.3.3 calculate_compatibility()
**목적**: 두 사람의 사주 데이터를 비교하여 궁합 점수를 계산합니다.

**시그니처**:  
```python
def calculate_compatibility(
    self,
    saju1: Dict[str, str],
    saju2: Dict[str, str],
    gender1: int,
    gender2: int,
) -> Dict[str, float]
```

**파라미터**:
- `saju1` (Dict[str, str]): 첫 번째 사람의 사주 데이터
- `saju2` (Dict[str, str]): 두 번째 사람의 사주 데이터
- `gender1` (int): 첫 번째 사람의 성별 (남자=1, 여자=0)
- `gender2` (int): 두 번째 사람의 성별 (남자=1, 여자=0)

**반환값**:  
`Dict[str, float]` - 궁합 분석 결과
```python
{
    "original": 85.5,    # 원본 점수 (TensorFlow 모델 예측 기반)
    "final": 78.3,       # 최종 점수 (원본 알고리즘 규칙 적용 후)
    "stress": 12.5       # 스트레스 점수
}
```

**처리 과정**:
1. 두 사주 데이터 검증
2. 사주 데이터를 토큰으로 변환 (`_build_tokens_from_saju`)
3. TensorFlow 모델을 사용하여 천간/지지별 예측 점수 계산
   - `_predict_sky()`: 천간 궁합 예측
   - `_predict_earth()`: 지지 궁합 예측
4. 원본 점수 계산: `(0.6 * ys) + (4.5 * ds) + (1.0 * ye) + (1.5 * me) + (4.5 * de)`
5. 원본 알고리즘 규칙 적용 (`_original_calculate`)
   - 성별에 따른 가중치 적용
   - 다양한 상생/상극 규칙 적용
   - 살(煞) 계산
6. 최종 점수 및 스트레스 점수 계산

---

#### 1.3.4 determine_character_type()
**목적**: 사주 데이터를 분석하여 오행 캐릭터 타입을 결정합니다.

**시그니처**:  
```python
def determine_character_type(self, saju: Dict[str, str]) -> str
```

**파라미터**:
- `saju` (Dict[str, str]): 사주 데이터 딕셔너리

**반환값**:  
`str` - 오행 캐릭터 타입 ("wood", "fire", "earth", "metal", "water" 중 하나)

**처리 과정**:
1. 사주 데이터 검증
2. 오행 분석 수행 (`analyzer.analyze_five_elements()`)
3. `characters.determine()` 호출하여 가장 높은 점수를 가진 오행을 캐릭터 타입으로 결정

---

#### 1.3.5 calculate_personality_flags_hd2()
**목적**: 원본(hd2) 규칙을 자기-자기 비교로 호출하여 개인의 성향 신호(8개 키워드 플래그)를 추출합니다.

**시그니처**:  
```python
def calculate_personality_flags_hd2(self, saju: Dict[str, str], gender: int = 0) -> Dict[str, Any]
```

**반환값**:  
```python
{
    "flags": ["열정 에너지 예술 중독", "의지 솔직 직설 개성 고집 독립심"],
    "sal": [8개 숫자]
}
```

**설명/주의**:
- `flags`는 hd2의 `sal` 규칙 트리거를 개인에게 투영한 보조 지표입니다.
- 성격 점수로 해석하지 말고, 경향/주의 신호로 보조 표기하세요.

---

#### 1.3.6 analyze_personality()
**목적**: 개인 성격 종합 분석(오행·8특성·hd2 플래그·요약문)을 한 번에 제공합니다.

**시그니처**:  
```python
def analyze_personality(self, saju: Dict[str, str], gender: int = 0) -> Dict[str, Any]
```

**반환값**:  
```python
{
    "five": {"wood": 0.33, "fire": 0.17, ...},
    "traits": {"passion": 0.62, "intuition": 0.21, ...},
    "flags": ["열정 에너지 예술 중독", ...],
    "report": "passion:0.62, conflict:0.24, charisma:0.23"
}
```

**처리 과정**:
1. `calculate_personal_traits()` 호출하여 오행, 특성, 리포트 획득
2. `calculate_personality_flags_hd2()` 호출하여 hd2식 플래그 추출
3. 결과 통합하여 반환

---

## 2. PersonalityAnalyzer 클래스

### 2.1 개요
**역할**: 사주 데이터를 기반으로 오행 분석 및 성격 특성 분석을 수행  
**패키지**: saju_core  
**설명**: 사주의 천간과 지지를 분석하여 오행(목, 화, 토, 금, 수) 비율을 계산하고, 이를 바탕으로 8가지 성격 특성을 도출합니다.

### 2.2 메서드

#### 2.2.1 analyze_five_elements()
**목적**: 사주 데이터에서 오행(목, 화, 토, 금, 수)의 비율을 분석합니다.

**시그니처**:  
```python
def analyze_five_elements(self, saju: Dict[str, str]) -> Dict[str, float]
```

**반환값**:  
```python
{
    "wood": 0.25,   # 목 오행 비율
    "fire": 0.30,   # 화 오행 비율
    "earth": 0.20,  # 토 오행 비율
    "metal": 0.15,  # 금 오행 비율
    "water": 0.10   # 수 오행 비율
}
# 총합 = 1.0 (정규화됨)
```

**알고리즘**:
- 연주, 월주, 일주 각각의 천간과 지지에서 오행 카운트
- 총 6개의 요소(천간 3 + 지지 3)에서 오행 빈도 계산
- 정규화하여 합이 1.0이 되도록 변환

---

#### 2.2.2 calculate_8_traits()
**목적**: 오행 분석 결과를 기반으로 8가지 성격 특성을 계산합니다.

**시그니처**:  
```python
def calculate_8_traits(self, saju: Dict[str, str]) -> Dict[str, float]
```

**반환값**: 8가지 성격 특성 점수 딕셔너리 (각 0.0~1.0 범위)

**계산 공식 (실제 구현)**:
- `passion` = clamp01(0.7 × fire + 0.3 × wood)
- `intuition` = clamp01(0.6 × water + 0.4 × wood)
- `mood_swing` = clamp01(0.5 × water + 0.5 × fire)
- `courage` = clamp01(0.6 × fire + 0.4 × metal)
- `responsibility` = clamp01(0.6 × earth + 0.4 × metal)
- `conflict` = clamp01(0.6 × metal + 0.4 × wood)
- `charisma` = clamp01(0.7 × fire + 0.3 × earth)
- `independence` = clamp01(0.6 × metal + 0.4 × water)

**참고**: `clamp01()` 함수는 값을 0.0~1.0 범위로 제한합니다.

---

#### 2.2.3 generate_personality_report()
**목적**: 성격 특성 분석 결과를 읽기 쉬운 리포트 문자열로 생성합니다.

**시그니처**:  
```python
def generate_personality_report(self, traits: Dict[str, float]) -> str
```

**반환값**: 리포트 문자열 예시
```
"passion:0.62, conflict:0.24, charisma:0.23"
```

**알고리즘**:
- 특성 점수를 내림차순으로 정렬
- 상위 3개를 선택하여 "특성명:점수" 형식으로 연결

---

## 3. CharacterSystem 클래스

### 3.1 개요
**역할**: 오행별 캐릭터 타입 결정  
**패키지**: saju_core  
**설명**: 오행 점수 딕셔너리에서 최댓값을 가진 오행을 캐릭터 타입으로 결정합니다.

### 3.2 메서드

#### 3.3.1 determine()
**목적**: 오행 점수 딕셔너리에서 최댓값을 가진 오행을 반환합니다.

**시그니처**:  
```python
def determine(self, five_elements_scores: Dict[str, float]) -> str
```

**파라미터**:
- `five_elements_scores` (Dict[str, float]): 오행별 점수 딕셔너리

**반환값**: 오행 타입 문자열 ("wood", "fire", "earth", "metal", "water" 중 하나)

**처리 과정**:
- 딕셔너리가 비어있으면 "unknown" 반환
- 최댓값을 가진 키를 반환

---

## 4. DataValidator 클래스

### 4.1 개요
**역할**: 사용자 입력 및 사주 데이터의 유효성 검증  
**패키지**: saju_core  
**설명**: 모든 사용자 입력과 내부 데이터의 유효성을 검증하여 시스템의 안정성을 보장합니다.

### 4.2 메서드

#### 4.2.1 validate_birth_date()
**목적**: 생년월일의 유효성을 검증합니다.

**시그니처**:  
```python
def validate_birth_date(self, year: int, month: int, day: int) -> None
```

**검증 규칙**:
- 연도: 2000~2010 범위
- 월: 1~12 범위
- 일: 1~31 범위 및 실제 존재하는 날짜인지 확인

**예외**: `ValidationError` - 유효하지 않은 날짜인 경우

---

#### 4.2.2 validate_saju_data()
**목적**: 사주 데이터 딕셔너리의 필수 항목을 검증합니다.

**시그니처**:  
```python
def validate_saju_data(self, saju: Dict[str, str]) -> None
```

**검증 항목**:
- 필수 키 존재 여부: year_gan, year_ji, month_gan, month_ji, day_gan, day_ji
- 각 값이 문자열이고 비어있지 않은지 확인
- 천간 값이 유효한 천간 목록에 포함되는지 확인
- 지지 값이 유효한 지지 목록에 포함되는지 확인

**예외**: `ValidationError` - 필수 데이터가 누락되거나 형식이 잘못된 경우

---

## 5. CommunityService 클래스

### 5.1 개요
**역할**: 게시판 관련 비즈니스 로직 처리  
**패키지**: community  
**설명**: 게시글 작성, 조회, 수정, 삭제 및 댓글 관리 기능을 제공합니다.

### 5.2 주요 메서드

#### 5.2.1 create_post()
**목적**: 새로운 게시글을 작성합니다.

**시그니처**:  
```python
def create_post(self, author_id: int, title: str, content: str, board_type: str | None = None) -> int
```

**파라미터**:
- `author_id` (int): 작성자 ID
- `title` (str): 게시글 제목
- `content` (str): 게시글 내용
- `board_type` (str | None): 게시판 타입 (선택적)

**반환값**: 생성된 게시글의 post_id

**처리 과정**:
1. 입력 데이터 검증
2. 데이터베이스에 게시글 저장
3. 알림 생성 (선택적)
4. post_id 반환

---

#### 5.2.2 get_post()
**목적**: 게시글 단건을 조회합니다.

**시그니처**:  
```python
def get_post(self, post_id: int, user_id: int | None = None) -> Dict[str, Any]
```

**반환값**: 게시글 정보, 댓글 목록, 좋아요 여부를 포함한 딕셔너리

---

#### 5.2.3 list_posts()
**목적**: 게시글 목록을 페이지네이션하여 조회합니다.

**시그니처**:  
```python
def list_posts(self, page: int = 1, page_size: int = 20) -> List[Dict[str, Any]]
```

**정렬 기준**: 최신순 (created_at DESC)

---

## 6. CompatibilityService 클래스

### 6.1 개요
**역할**: 사용자 간 궁합 요청 및 계산 관리  
**패키지**: community  
**설명**: 커뮤니티 내에서 사용자들이 서로 궁합을 확인할 수 있도록 요청 시스템을 제공합니다.

### 6.2 주요 메서드

#### 6.2.1 request_compatibility()
**목적**: 다른 사용자에게 궁합 확인 요청을 생성합니다.

**시그니처**:  
```python
def request_compatibility(self, requester_id: int, target_id: int, message: str | None = None) -> int
```

**처리 과정**:
1. 요청자와 대상자 존재 확인
2. 친구 관계 확인 (친구가 아니면 요청 불가)
3. CompatibilityRequest 객체 생성 (status = "pending")
4. 데이터베이스에 저장
5. 알림 생성

---

#### 6.2.2 accept_compatibility()
**목적**: 궁합 요청을 수락하고 궁합을 계산합니다.

**시그니처**:  
```python
def accept_compatibility(self, request_id: int, actor_id: int, accept: bool) -> Optional[Dict[str, Any]]
```

**처리 과정**:
1. 요청 존재 및 권한 확인
2. accept가 True인 경우:
   - 두 사용자의 사주 데이터 조회
   - `SajuCalculator.calculate_compatibility()` 호출하여 궁합 계산
   - 결과를 CompatibilityRequest에 저장
3. 요청 상태를 "accepted" 또는 "rejected"로 변경
4. 궁합 결과 반환

---

## 7. CelebrityService 클래스

### 7.1 개요
**역할**: 유명인과의 궁합 계산 및 제공  
**패키지**: celebrity  
**설명**: 사용자가 유명인과의 궁합을 확인할 수 있는 기능을 제공합니다.

### 7.2 주요 메서드

#### 7.2.1 calculate_with_celebrity()
**목적**: 사용자와 유명인의 궁합을 계산합니다.

**시그니처**:  
```python
def calculate_with_celebrity(
    self,
    user_saju: Dict[str, str],
    celebrity_id: int,
    user_gender: int = 0,
    use_ai: bool = True,
) -> Dict[str, Any]
```

**처리 과정**:
1. 유명인 정보 조회
2. 유명인의 사주 데이터 확인
3. `SajuCalculator.calculate_compatibility()` 호출
4. AI 기반 인사이트 생성 (use_ai가 True인 경우)
5. 궁합 결과 및 인사이트 반환

**반환값**: 궁합 결과 딕셔너리 (scores, description, insights, element_relationship 포함)

---

## 8. 참고사항

### 8.1 UserService 클래스
- 실제 구현에서는 `UserService` 클래스가 존재하지 않습니다.
- 인증 관련 로직은 `auth_controller`에서 직접 `user_repository`를 사용하여 처리합니다.

### 8.2 데이터베이스 연동
- 모든 서비스는 Repository 패턴을 사용하여 데이터베이스와 상호작용합니다.
- Repository는 SQLAlchemy를 사용하여 구현되었습니다.

### 8.3 예외 처리
- 모든 검증 오류는 `ValidationError` 예외로 처리됩니다.
- 리소스를 찾을 수 없는 경우 `NotFoundError` 예외가 발생합니다.
- 권한이 없는 경우 `AuthorizationError` 예외가 발생합니다.

---

이 명세서를 통해 프로그래머는 각 클래스의 역할, 메서드의 사용법, 처리 과정을 명확히 이해하고 구현할 수 있습니다.

