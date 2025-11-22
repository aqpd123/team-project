# 클래스 명세서

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
| sky_model | Optional[Model] | private | 천간 궁합 예측을 위한 TensorFlow 모델 (선택적) |
| earth_model | Optional[Model] | private | 지지 궁합 예측을 위한 TensorFlow 모델 (선택적) |

### 1.3 메서드 (Methods)

#### 1.3.1 get_birth_data()
**목적**: 생년월일을 입력받아 사주 데이터를 생성하고 반환합니다.

**시그니처**:  
```python
def get_birth_data(self, year: int, month: int, day: int) -> Dict[str, str]
```

**파라미터**:
- `year` (int): 태어난 연도 (2000~2010 범위)
- `month` (int): 태어난 월 (1~12)
- `day` (int): 태어난 일 (1~31)

**반환값**:  
`Dict[str, str]` - 사주 데이터 딕셔너리
```python
{
    "year_gan": "갑",    # 연주 천간
    "year_ji": "자",     # 연주 지지
    "month_gan": "병",   # 월주 천간
    "month_ji": "인",    # 월주 지지
    "day_gan": "무",     # 일주 천간
    "day_ji": "진"      # 일주 지지
}
```

**처리 과정**:
1. `validator.validate_birth_date()`로 입력값 검증
2. 양력 날짜를 음력으로 변환 (fallback_lunar_convert 사용)
3. 음력 기준으로 연주, 월주, 일주 계산
4. 사주 데이터 딕셔너리 구성하여 반환

**예외 처리**:
- `ValueError`: 연도가 2000~2010 범위를 벗어나거나 유효하지 않은 날짜인 경우

**사용 예시**:
```python
calculator = SajuCalculator()
saju = calculator.get_birth_data(2005, 3, 15)
print(saju)  # {'year_gan': '을', 'year_ji': '유', ...}
```

---

#### 1.3.2 calculate_personal_traits()
**목적**: 사주 데이터를 기반으로 개인의 8가지 성격 특성을 계산합니다.

**시그니처**:  
```python
def calculate_personal_traits(self, saju: Dict[str, str]) -> Dict[str, float]
```

**파라미터**:
- `saju` (Dict[str, str]): 사주 데이터 딕셔너리

**반환값**:  
`Dict[str, float]` - 8가지 성격 특성 점수 딕셔너리
```python
{
    "leadership": 0.75,    # 리더십
    "creativity": 0.82,     # 창의성
    "passion": 0.65,       # 열정
    "stability": 0.70,     # 안정
    "discipline": 0.68,    # 규율
    "communication": 0.73, # 소통
    "empathy": 0.78,       # 공감
    "decisiveness": 0.71   # 결단
}
```

**처리 과정**:
1. `validator.validate_saju_data()`로 사주 데이터 검증
2. `analyzer.calculate_8_traits()` 호출하여 성격 특성 계산
3. 각 특성은 오행 분석 결과를 가중합으로 계산

**사용 예시**:
```python
traits = calculator.calculate_personal_traits(saju)
print(f"강점: 리더십 {traits['leadership']:.2f}")
```

---

#### 1.3.3 calculate_compatibility()
**목적**: 두 사람의 사주 데이터를 비교하여 궁합 점수를 계산합니다.

**시그니처**:  
```python
def calculate_compatibility(
    self,
    saju1: Dict[str, str],
    saju2: Dict[str, str],
    gender1: int = 0,
    gender2: int = 0
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

**알고리즘 세부사항**:
- 원본 알고리즘은 8가지 그룹의 규칙을 적용
- 각 규칙은 특정 지지 조합에 대해 점수를 차감
- 성별에 따라 다른 가중치 적용 (여성이 더 높은 패널티)

**사용 예시**:
```python
compatibility = calculator.calculate_compatibility(
    saju1, saju2, gender1=1, gender2=0
)
print(f"궁합 점수: {compatibility['final']:.1f}점")
```

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
`str` - 오행 캐릭터 타입 ("목", "화", "토", "금", "수" 중 하나)

**처리 과정**:
1. 사주 데이터 검증
2. 오행 분석 수행 (`analyzer.analyze_five_elements()`)
3. 가장 높은 점수를 가진 오행을 캐릭터 타입으로 결정

**사용 예시**:
```python
character_type = calculator.determine_character_type(saju)
print(f"당신의 오행: {character_type}")
```

---

#### 1.3.5 calculate_personality_flags_hd2()
**목적**: 원본(hd2) 규칙을 자기-자기 비교로 호출하여 개인의 성향 신호(8개 키워드 플래그)를 추출합니다. 궁합용 점수(org/final/stress)는 사용하지 않습니다.

**시그니처**:  
```python
def calculate_personality_flags_hd2(self, saju: Dict[str, str], gender: int = 0) -> Dict[str, Any]
```

**반환값**:  
```python
{ "flags": ["열정 에너지 예술 중독", ...], "sal": [8개 숫자] }
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
  "five": {"목":0.33, ...},
  "traits": {"leadership":0.62, ...},
  "flags": ["열정 에너지 예술 중독", ...],
  "report": "강점 상위: ..."
}
```

**처리 과정**:
1. `analyzer.analyze_five_elements()`로 오행 분포 산출
2. `analyzer.calculate_8_traits()`로 8특성 점수 계산
3. `calculate_personality_flags_hd2()`로 hd2식 플래그 추출
4. `analyzer.generate_personality_report()`로 요약 리포트 생성

---

#### 1.3.7 내부 메서드들

**\_build_tokens_from_saju()**: 사주 데이터를 숫자 토큰 리스트로 변환  
**\_predict_sky()**: 천간 궁합 예측 (TensorFlow 모델 사용 또는 폴백값 반환)  
**\_predict_earth()**: 지지 궁합 예측 (TensorFlow 모델 사용 또는 폴백값 반환)  
**\_original_calculate()**: 원본 궁합 계산 알고리즘 적용 (복잡한 규칙 기반)

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
    "목": 0.25,  # 목 오행 비율
    "화": 0.30,  # 화 오행 비율
    "토": 0.20,  # 토 오행 비율
    "금": 0.15,  # 금 오행 비율
    "수": 0.10   # 수 오행 비율
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

**계산 공식**:
- `leadership` = 목 × 0.6 + 화 × 0.4
- `creativity` = 목
- `passion` = 화
- `stability` = 토
- `discipline` = 금
- `communication` = 수
- `empathy` = 수 × 0.5 + 목 × 0.5
- `decisiveness` = 금 × 0.5 + 화 × 0.5

---

#### 2.2.3 generate_personality_report()
**목적**: 성격 특성 분석 결과를 읽기 쉬운 리포트 문자열로 생성합니다.

**시그니처**:  
```python
def generate_personality_report(self, traits: Dict[str, float]) -> str
```

**반환값**: 리포트 문자열 예시
```
"강점 상위: leadership:0.75, creativity:0.82, empathy:0.78. 
약점 하위: discipline:0.68, passion:0.65. 
균형 잡힌 성장을 위해 낮은 특성을 보완해 보세요."
```

---

## 3. CharacterSystem 클래스

### 3.1 개요
**역할**: 오행별 캐릭터 정보 관리 및 제공  
**패키지**: saju_core  
**설명**: 5가지 오행(목, 화, 토, 금, 수)에 대한 캐릭터 정보를 저장하고 조회하는 시스템입니다.

### 3.2 속성

| 속성명 | 타입 | 접근제어자 | 설명 |
|--------|------|------------|------|
| _CHAR_INFO | Dict[str, Dict[str, str]] | private | 오행별 캐릭터 정보 저장 딕셔너리 |

**데이터 구조 예시**:
```python
{
    "목": {
        "name": "푸른 바람",
        "desc": "성장과 창의, 시작을 상징. 리더십과 유연함이 강점."
    },
    "화": {
        "name": "불꽃 열정",
        "desc": "열정과 추진, 낙관을 상징. 에너지와 결단이 강점."
    },
    # ... (토, 금, 수 동일)
}
```

### 3.3 메서드

#### 3.3.1 get_character_info()
**목적**: 특정 오행 타입의 캐릭터 정보를 반환합니다.

**시그니처**:  
```python
def get_character_info(self, character_type: str) -> Dict[str, str]
```

**반환값**:
```python
{
    "name": "푸른 바람",
    "desc": "성장과 창의, 시작을 상징. 리더십과 유연함이 강점."
}
```

**예외 처리**: 알 수 없는 오행 타입인 경우 기본값 반환

---

#### 3.3.2 generate_character_image()
**목적**: 캐릭터 타입에 해당하는 이미지 식별자를 생성합니다.

**시그니처**:  
```python
def generate_character_image(self, character_type: str) -> str
```

**반환값**: 이미지 식별자 문자열 (예: "icon_목")

**참고**: 실제 이미지 파일은 프론트엔드에서 관리하는 것을 권장

---

#### 3.3.3 get_personality_description()
**목적**: 성격 특성 분석 결과를 바탕으로 캐릭터 설명을 생성합니다.

**시그니처**:  
```python
def get_personality_description(self, traits: Dict[str, float]) -> str
```

**반환값**: 설명 문자열 (예: "당신은 'leadership' 특성이 두드러집니다. 강점을 살려보세요.")

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

**예외**: `ValueError` - 유효하지 않은 날짜인 경우

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

**예외**: `ValueError` - 필수 데이터가 누락되거나 형식이 잘못된 경우

---

#### 4.2.3 sanitize_user_input()
**목적**: 사용자 입력을 정제하고 타입을 변환합니다.

**시그니처**:  
```python
def sanitize_user_input(self, input_data: Dict[str, Any]) -> Dict[str, Any]
```

**처리 과정**:
- 문자열 값의 앞뒤 공백 제거
- year, month, day 필드는 정수로 변환 시도

---

## 5. User 클래스

### 5.1 개요
**역할**: 사용자 정보를 담는 엔티티 클래스  
**패키지**: community  
**설명**: 커뮤니티 시스템에서 사용되는 사용자 정보를 관리합니다.

### 5.2 속성

| 속성명 | 타입 | 접근제어자 | 설명 |
|--------|------|------------|------|
| user_id | int | public | 사용자 고유 식별자 (Primary Key) |
| username | str | public | 사용자명 (로그인 ID) |
| email | str | public | 이메일 주소 |
| character_type | str | public | 오행 캐릭터 타입 ("목", "화", "토", "금", "수") |
| saju_data | Dict[str, str] | public | 사용자의 사주 데이터 |

### 5.3 메서드

#### 5.3.1 get_profile()
**목적**: 사용자 프로필 정보를 딕셔너리 형태로 반환합니다.

**시그니처**:  
```python
def get_profile(self) -> Dict[str, Any]
```

**반환값**:
```python
{
    "user_id": 1,
    "username": "test_user",
    "email": "test@example.com",
    "character_type": "목",
    "character_name": "푸른 바람",
    "character_desc": "성장과 창의, 시작을 상징..."
}
```

---

#### 5.3.2 update_character()
**목적**: 사용자의 오행 캐릭터 타입을 업데이트합니다.

**시그니처**:  
```python
def update_character(self, character_type: str) -> None
```

**파라미터**:
- `character_type` (str): 새로운 캐릭터 타입

**처리 과정**:
- character_type 속성 업데이트
- 데이터베이스에도 반영 필요 (UserService를 통해 수행)

---

## 6. BoardService 클래스

### 6.1 개요
**역할**: 게시판 관련 비즈니스 로직 처리  
**패키지**: community  
**설명**: 게시글 작성, 조회, 수정, 삭제 및 댓글 관리 기능을 제공합니다.

### 6.2 주요 메서드

#### 6.2.1 create_post()
**목적**: 새로운 게시글을 작성합니다.

**시그니처**:  
```python
def create_post(
    self, 
    user_id: int, 
    title: str, 
    content: str, 
    board_type: str
) -> Post
```

**파라미터**:
- `user_id` (int): 작성자 ID
- `title` (str): 게시글 제목
- `content` (str): 게시글 내용
- `board_type` (str): 게시판 타입 ("목", "화", "토", "금", "수", "익명", "전체" 등)

**반환값**: 생성된 Post 객체

**처리 과정**:
1. 입력 데이터 검증
2. 데이터베이스에 게시글 저장
3. Post 객체 생성 및 반환

---

#### 6.2.2 get_posts()
**목적**: 게시판 타입에 따른 게시글 목록을 페이지네이션하여 조회합니다.

**시그니처**:  
```python
def get_posts(
    self, 
    board_type: str, 
    page: int, 
    limit: int
) -> List[Post]
```

**파라미터**:
- `board_type` (str): 게시판 타입
- `page` (int): 페이지 번호 (1부터 시작)
- `limit` (int): 한 페이지에 표시할 게시글 수

**반환값**: Post 객체 리스트

**정렬 기준**: 최신순 (created_at DESC)

---

#### 6.2.3 add_comment()
**목적**: 게시글에 댓글을 추가합니다.

**시그니처**:  
```python
def add_comment(
    self, 
    post_id: int, 
    user_id: int, 
    content: str
) -> Comment
```

**처리 과정**:
1. 게시글이 존재하는지 확인
2. 댓글 데이터 검증
3. 데이터베이스에 댓글 저장
4. Comment 객체 생성 및 반환

---

## 7. CompatibilityService 클래스

### 7.1 개요
**역할**: 사용자 간 궁합 요청 및 계산 관리  
**패키지**: community  
**설명**: 커뮤니티 내에서 사용자들이 서로 궁합을 확인할 수 있도록 요청 시스템을 제공합니다.

### 7.2 주요 메서드

#### 7.2.1 create_request()
**목적**: 다른 사용자에게 궁합 확인 요청을 생성합니다.

**시그니처**:  
```python
def create_request(
    self, 
    requester_id: int, 
    target_id: int
) -> CompatibilityRequest
```

**처리 과정**:
1. 요청자와 대상자 존재 확인
2. 중복 요청 확인
3. CompatibilityRequest 객체 생성 (status = "pending")
4. 데이터베이스에 저장

---

#### 7.2.2 accept_request()
**목적**: 궁합 요청을 수락하고 궁합을 계산합니다.

**시그니처**:  
```python
def accept_request(
    self, 
    request_id: int, 
    target_id: int
) -> Optional[Dict[str, float]]
```

**처리 과정**:
1. 요청 존재 및 권한 확인
2. 두 사용자의 사주 데이터 조회
3. `SajuCalculator.calculate_compatibility()` 호출하여 궁합 계산
4. 결과를 CompatibilityRequest에 저장
5. 요청 상태를 "accepted"로 변경
6. 궁합 결과 반환

**반환값**: 궁합 결과 딕셔너리 또는 None (오류 시)

---

## 8. CelebrityCompatibilityService 클래스

### 8.1 개요
**역할**: 유명인과의 궁합 계산 및 제공  
**패키지**: celebrity  
**설명**: 사용자가 유명인과의 궁합을 확인할 수 있는 기능을 제공합니다.

### 8.2 주요 메서드

#### 8.2.1 calculate_compatibility()
**목적**: 사용자와 유명인의 궁합을 계산합니다.

**시그니처**:  
```python
def calculate_compatibility(
    self, 
    user_saju: Dict[str, str], 
    celebrity_id: int
) -> Dict[str, float]
```

**처리 과정**:
1. 유명인 정보 조회
2. 유명인의 사주 데이터 확인
3. `SajuCalculator.calculate_compatibility()` 호출
4. 궁합 결과 반환

**반환값**: 궁합 결과 딕셔너리 (original, final, stress 점수)

---

#### 8.2.2 get_compatibility_description()
**목적**: 궁합 점수를 바탕으로 설명 문자열을 생성합니다.

**시그니처**:  
```python
def get_compatibility_description(
    self, 
    compatibility: Dict[str, float]
) -> str
```

**반환값 예시**:
```
"궁합 점수 85.3점으로 매우 좋은 궁합입니다! 
서로를 보완해주는 관계로 장기적인 관계에 유리합니다."
```

---

## 9. 데이터베이스 연동

### 9.1 DatabaseManager 클래스

**역할**: 데이터베이스 연결 및 쿼리 실행을 관리  
**패키지**: database

**주요 메서드**:
- `get_connection()`: 데이터베이스 연결 가져오기
- `execute_query()`: SELECT 쿼리 실행 (결과 반환)
- `execute_update()`: INSERT/UPDATE/DELETE 쿼리 실행 (영향받은 행 수 반환)
- `close_connection()`: 연결 종료

**사용 패턴**:
```python
db = DatabaseManager()
connection = db.get_connection()
results = db.execute_query("SELECT * FROM users WHERE user_id = ?", (user_id,))
db.close_connection()
```

---

## 10. 클래스 간 상호작용 플로우

### 10.1 사주 분석 플로우
```
사용자 입력 → DataValidator.validate_birth_date()
         → SajuCalculator.get_birth_data()
         → PersonalityAnalyzer.analyze_five_elements()
         → CharacterSystem.get_character_info()
         → 결과 반환
```

### 10.2 궁합 계산 플로우
```
사주 데이터 두 개 → SajuCalculator.calculate_compatibility()
                  → TensorFlow 모델 예측 (또는 폴백)
                  → 원본 알고리즘 규칙 적용
                  → 최종 점수 계산
```

### 10.3 커뮤니티 게시글 작성 플로우
```
사용자 입력 → BoardService.create_post()
         → DatabaseManager.execute_update()
         → Post 객체 반환
```

이 명세서를 통해 프로그래머는 각 클래스의 역할, 메서드의 사용법, 처리 과정을 명확히 이해하고 구현할 수 있습니다.

