# 대화 내용 요약 및 프로젝트 현황

## 프로젝트 개요

**프로젝트명**: 사주 분석 및 커뮤니티 앱 (Saju App)
- **백엔드**: Python Flask + SQLAlchemy + MySQL
- **프론트엔드**: Flutter (Dart)
- **주요 기능**: 사주 분석, 유명인 궁합, 커뮤니티 게시판, 친구 관리, 메시징

## 프로젝트 구조

```
TeamProject/
├── app/                    # Flask 백엔드
│   ├── api/controllers/    # API 엔드포인트
│   ├── domain/             # 비즈니스 로직
│   │   ├── saju_core/      # 사주 계산 로직
│   │   ├── community/      # 커뮤니티 서비스
│   │   └── celebrity/      # 유명인 서비스
│   └── infrastructure/     # 데이터베이스 레이어
├── FrontEnd/lastlast/      # Flutter 프론트엔드
│   ├── lib/
│   │   ├── controllers/    # 상태 관리 (ChangeNotifier)
│   │   ├── models/         # 데이터 모델
│   │   ├── pages/          # UI 페이지
│   │   └── services/      # API 클라이언트
└── documents/             # 문서 및 API 명세
```

## 최근 수정 사항 (이번 세션)

### 1. 유명인 궁합 무한 로딩 문제 해결 ✅

**문제**: 유명인 궁합 기능에서 무한 로딩이 발생

**원인**: 
- `CelebrityResultPage`에서 사용자 사주 데이터를 `AuthUser`에서만 가져오려고 시도
- 사용자가 사주 분석을 하지 않았거나, 사주 데이터가 저장되지 않은 경우

**해결 방법**:
- `SharedPreferences`에 마지막 사주 분석 결과를 저장하도록 수정
- `SajuInputPage`에서 사주 분석 완료 시 결과를 `SharedPreferences`에 저장
- `CelebrityResultPage`에서 `SharedPreferences`와 `AuthUser` 모두에서 사주 데이터 확인
- 사주 데이터가 없을 경우 에러 메시지와 함께 "사주 분석하러 가기" 버튼 표시

**수정된 파일**:
- `FrontEnd/lastlast/lib/pages/saju/celebrity_result_page.dart`
- `FrontEnd/lastlast/lib/pages/saju/input_page.dart`

### 2. 오행 게시판 필터링 문제 해결 ✅

**문제**: 
- 오행 게시판에 글을 작성하면 속성 선택 페이지(오행 게시판 메인)에도 게시글이 보임
- 예: 화속성 게시판에 글을 작성하면 오행 선택 페이지와 화속성 게시판 모두에 표시됨

**원인**: 
- `BoardPage`의 오행 게시판 탭에서 모든 오행 게시글을 표시하고 있었음

**해결 방법**:
- `BoardPage`의 `_filterPosts` 메서드에서 오행 게시판 탭일 때 게시글을 숨기도록 수정
- 오행 게시판 탭에서는 오행 선택 링크만 표시
- 각 오행 상세 페이지(`OhangDetailPage`)에서는 해당 오행의 게시글만 필터링하여 표시 (기존 로직 유지)

**수정된 파일**:
- `FrontEnd/lastlast/lib/pages/community/board_page.dart`

## 주요 기능 및 아키텍처

### 프론트엔드 아키텍처

**상태 관리**: `InheritedNotifier` + `ChangeNotifier` 패턴
- `AuthScope` - 인증 상태
- `CommunityScope` - 커뮤니티 게시글
- `FriendScope` - 친구 관리
- `MessageScope` - 메시징
- `SajuScope` - 사주 분석
- `CelebrityScope` - 유명인 데이터

**라우팅**: `GoRouter` 사용
- 경로: `/saju/input`, `/saju/compatibility`, `/celebrity-saju`, `/board`, `/ohang/fire`, etc.

**API 통신**: `ApiClient` 클래스
- JWT 토큰 자동 관리
- 에러 처리 (`ApiException`)

### 백엔드 아키텍처

**레이어 구조**:
- `controllers/` - Flask Blueprint (API 엔드포인트)
- `services/` - 비즈니스 로직
- `repositories/` - 데이터베이스 접근
- `models/` - SQLAlchemy 모델

**주요 API 엔드포인트**:
- `/saju/traits/birth` - 생년월일 기반 사주 분석
- `/saju/compatibility/birth` - 생년월일 기반 궁합 계산
- `/celebrities` - 유명인 목록
- `/celebrities/:id/compatibility` - 유명인 궁합 계산
- `/posts` - 게시글 목록 (board_type 필터링 지원)
- `/messages` - 메시지 관련

### 사주 계산 로직

**지원 범위**: 2000년 ~ 2010년 출생자만 지원 (원본 소스코드 제약)

**주요 컴포넌트**:
- `calendar_converter.py` - 양력→음력 변환 및 간지 계산
- `saju_calculator.py` - 사주 계산 (년주, 월주, 일주, 시주)
- `personality_analyzer.py` - 성격 분석
- `character_system.py` - 오행별 캐릭터 타입 결정

**데이터 구조**:
```python
saju = {
    'year_gan': '갑', 'year_ji': '자',
    'month_gan': '을', 'month_ji': '축',
    'day_gan': '병', 'day_ji': '인',
    'time_gan': '정', 'time_ji': '묘'
}
```

## 현재 발생 중인 문제

### Git Worktree 오류

**오류 메시지**:
```
Failed to apply worktree to current branch: Unable to read file 
'c:\Users\user\.cursor\worktrees\TeamProject\fpd\saju_core\saju_calculator.py' 
(Error: Unable to resolve nonexistent file)
```

**원인**:
- Cursor worktree 메타데이터에 잘못된 경로가 저장됨
- 실제 파일 경로: `app/domain/saju_core/saju_calculator.py`
- 오류에서 찾는 경로: `saju_core/saju_calculator.py` (잘못된 경로)

**상태**:
- 파일은 실제로 존재함 (`app/domain/saju_core/saju_calculator.py`)
- Git 인덱스에는 올바르게 등록되어 있음
- Worktree가 detached HEAD 상태

**해결 방법** (시도 중):
1. Cursor 완전 종료 후 재시작
2. Git worktree 제거 후 재생성
3. 또는 Git 명령어로 직접 커밋

## 주요 파일 위치

### 프론트엔드
- 메인 진입점: `FrontEnd/lastlast/lib/main.dart`
- 라우팅: `FrontEnd/lastlast/lib/app_router.dart`
- 사주 분석 입력: `FrontEnd/lastlast/lib/pages/saju/input_page.dart`
- 사주 분석 결과: `FrontEnd/lastlast/lib/pages/saju/components/saju_analysis.dart`
- 유명인 궁합: `FrontEnd/lastlast/lib/pages/saju/celebrity_result_page.dart`
- 게시판: `FrontEnd/lastlast/lib/pages/community/board_page.dart`
- 오행 상세 페이지: `FrontEnd/lastlast/lib/pages/ohang/ohang_detail_page.dart`

### 백엔드
- 메인 앱: `app/main.py`
- 사주 API: `app/api/controllers/saju_controller.py`
- 사주 계산: `app/domain/saju_core/saju_calculator.py`
- 간지 계산: `app/domain/saju_core/calendar_converter.py`
- 유명인 서비스: `app/domain/celebrity/services/celebrity_service.py`
- 게시글 API: `app/api/controllers/post_controller.py`

## 개발 환경

- **Python**: 3.11.x
- **Flutter**: 최신 버전
- **데이터베이스**: MySQL 8.x
- **OS**: Windows 10/11

## 실행 방법

### 백엔드
```powershell
cd C:\Users\user\Documents\TeamProject
.\.venv311\Scripts\Activate.ps1
$env:FLASK_APP = "app.main:create_app"
py -m flask run --port 5000
```

### 프론트엔드
```powershell
cd C:\Users\user\Documents\TeamProject\FrontEnd\lastlast
flutter run
```

## 참고 사항

1. **사주 계산 제한**: 2000년~2010년 출생자만 지원
2. **유명인 데이터**: IVE, aespa, BLACKPINK 등 2000년대 출생 아이돌 포함
3. **게시판 분류**: 
   - 익명 게시판: `board_type = null` 또는 `'general'`
   - 오행 게시판: `board_type = 'fire'`, `'water'`, `'wood'`, `'metal'`, `'earth'`
4. **인증**: JWT 토큰 기반, `SharedPreferences`에 저장
5. **사주 데이터 저장**: `SharedPreferences`의 `'last_saju_analysis'` 키에 JSON 형태로 저장

## 다음 단계 (선택 사항)

1. Git worktree 문제 해결
2. 통합 테스트 자동화
3. 추가 기능 개발

---

**마지막 업데이트**: 2024년 (현재 세션)
**상태**: 주요 기능 정상 작동, Git worktree 문제 발생 중




