# TeamProject Backend

사주/커뮤니티 서비스 백엔드 코드베이스입니다. Flask + SQLAlchemy + MySQL 조합으로 구성되어 있으며, TensorFlow 기반 `hd2` 모델을 사용해 궁합 점수를 계산합니다.

## 요구 사항

- Python 3.11.x (Windows에서 `py -3.11` 사용 권장)
- SQLite (Python에 기본 포함) 또는 MySQL 8.x (선택사항)
- PowerShell 7 이상 (테스트 스크립트 실행 시)
- Flutter SDK (프론트엔드 실행/빌드 시)

## 설치

```powershell
git clone <repo-url>
cd TeamProject
py -3.11 -m venv .venv311
.\.venv311\Scripts\Activate.ps1
py -m pip install --upgrade pip
py -m pip install -r requirements.txt
```

## 환경 변수

1. `env.example`를 `.env` 이름으로 복사한 뒤 값 변경
   ```powershell
   Copy-Item env.example .env
   ```
2. 필드 설명
   - `APP_ENV` / `FLASK_ENV`: `development`, `testing`, `production` 중 선택
   - `SECRET_KEY`: JWT 서명용 시크릿 (기본값: "change-me")
   - `DATABASE_URL`: 
     - **SQLite (기본값, 권장)**: `sqlite:///app.db` - 별도 설치 없이 작동
     - MySQL: `mysql+pymysql://root@127.0.0.1:3306/teamproject?charset=utf8mb4`
   - `LUNAR_API_KEY`: 공공데이터포털 음력 변환 API 키 (기본값 제공됨)
   - `GEMINI_API_KEY`: Google Gemini API 키 (AI 기능용, 필수)

`app/config.py`가 `.env`를 자동으로 로드하며, `APP_ENV` 값에 따라 개발/테스트/운영 구성이 선택됩니다.

**중요**: SQLite를 사용하면 별도의 데이터베이스 서버 설치 없이 바로 실행 가능합니다.

## 데이터베이스

### SQLite 사용 (기본, 권장)

SQLite는 Python에 기본 포함되어 있어 별도 설치가 필요 없습니다.

1. `.env` 파일에서 `DATABASE_URL=sqlite:///app.db` 설정 (기본값)
2. 백엔드 서버 실행 시 자동으로 `app.db` 파일이 생성되고 테이블이 생성됩니다
3. 별도의 초기화 작업이 필요 없습니다

### MySQL 사용 (선택사항)

MySQL을 사용하려면:

1. MySQL 8.x 설치
2. `teamproject` 데이터베이스와 사용자 계정 생성
3. `.env` 파일에서 `DATABASE_URL`을 MySQL 연결 문자열로 변경
4. `documents/mysql_integration.md` 참고

**권장**: 교수님 환경에서는 SQLite 사용을 권장합니다 (설정이 간단함)

## 실행

```powershell
.\.venv311\Scripts\Activate.ps1
$env:FLASK_APP = "app.main:create_app"
py -m flask run --port 5000
```

TensorFlow 모델(`source/sky3000.h5`, `source/earth3000.h5`)이 자동 로드되며, `/saju/compatibility` 등에서 사용됩니다.

## 테스트

```powershell
py -m pytest
```

개별 테스트는 `tests/domain/...` 구조를 참고하세요. API 수동 검증 스크립트는 PowerShell `Invoke-RestMethod` 예제들을 기반으로 실행합니다.

## 빠른 시작

**교수님 환경에서 실행하기:**
1. `QUICK_START.md` 파일 참고 (5분 안에 실행 가능)
2. 또는 `SETUP_GUIDE.md` 파일 참고 (상세 가이드)

**Flutter 앱 빌드:**
- `BUILD_GUIDE.md` 파일 참고

## 문서

- **빠른 시작**: `QUICK_START.md` - 5분 안에 프로젝트 실행
- **상세 설정 가이드**: `SETUP_GUIDE.md` - 교수님 환경 설정 가이드
- **앱 빌드 가이드**: `BUILD_GUIDE.md` - Flutter 앱 빌드 방법
- API 명세: `documents/api_spec.md`
- 미구현/추가 과제 추적: `documents/outstanding_features.md`
- MySQL 연동 가이드: `documents/mysql_integration.md`

필요 시 `documents` 디렉터리 아래에서 ADR, 클래스 다이어그램 등을 참조하세요.


