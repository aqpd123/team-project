# 수정된 명세서 및 다이어그램

본 폴더에는 실제 구현된 백엔드 코드를 기반으로 수정된 명세서와 다이어그램이 포함되어 있습니다.

## 파일 목록

### 다이어그램 파일
- `class_saju_core.puml`: saju_core 패키지 클래스 다이어그램
- `class_community.puml`: community 패키지 클래스 다이어그램
- `class_celebrity.puml`: celebrity 패키지 클래스 다이어그램
- `DB table.puml`: 데이터베이스 테이블 구조 다이어그램

### 명세서 파일
- `class_specification.md`: 클래스 상세 명세서
- `class_methods_spec.md`: 클래스/메서드 명세서 (CSU 형식)
- `db_table_spec.md`: 데이터베이스 테이블 명세서

## 주요 변경 사항

### 1. saju_core 패키지
- `SajuCalculator.get_birth_data()`: hour, minute 파라미터 추가
- `PersonalityAnalyzer.calculate_8_traits()`: 8가지 특성 이름 및 계산 공식을 실제 구현에 맞게 수정
  - `passion`, `intuition`, `mood_swing`, `courage`, `responsibility`, `conflict`, `charisma`, `independence`
- `CharacterSystem`: `determine()` 메서드만 존재 (다른 메서드 제거)
- `DataValidator.validate_birth_date()`: 연도 범위를 2000~2010으로 수정

### 2. community 패키지
- `UserService` 클래스 제거 (실제로는 auth_controller에서 직접 처리)
- `BoardService` → `CommunityService`로 변경
- `CommunityService`에 추가 메서드 반영:
  - `get_post()`, `list_my_posts()`, `add_comment()`, `toggle_like()`, `update_post()`, `delete_post()`
- `CompatibilityService` 메서드 이름 수정:
  - `create_request()` → `request_compatibility()`
  - `accept_request()` → `accept_compatibility()`
- `FriendService`, `MessageService` 클래스 추가

### 3. celebrity 패키지
- `CelebrityCompatibilityService` → `CelebrityService`로 변경
- 메서드 이름 수정:
  - `get_celebrity_list()` → `list_celebrities()`
  - `get_celebrity_by_id()` → `get_celebrity()`
  - `calculate_compatibility()` → `calculate_with_celebrity()`
- `Celebrity` 모델 구조 수정 (id, name, description, category, gender, saju, thumbnail)

### 4. 데이터베이스 테이블
- `COMMENTS` 테이블에 `anonymous_number` 컬럼 추가
- `POST_LIKES` 테이블 추가
- `FRIENDSHIPS` 테이블 추가
- `MESSAGES` 테이블 추가
- `COMPATIBILITY_REQUESTS` 테이블에 `request_message` 컬럼 추가
- `USERS` 테이블에 `created_at` 컬럼 추가

## 사용 방법

1. PlantUML 다이어그램 파일(.puml)은 PlantUML 도구로 시각화할 수 있습니다.
2. Markdown 명세서 파일(.md)은 일반 텍스트 에디터나 Markdown 뷰어로 확인할 수 있습니다.

## 원본 파일과의 차이점

원본 파일(`documents/` 폴더)과의 주요 차이점은 `documents/IMPLEMENTATION_VS_DIAGRAM_ANALYSIS.md` 파일에서 상세히 확인할 수 있습니다.

## 업데이트 일자

2025-01-XX (실제 구현 코드 기준)

