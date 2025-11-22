# TeamProject Backend

사주/커뮤니티 서비스 백엔드 코드베이스입니다. Flask + SQLAlchemy + MySQL 조합으로 구성되어 있으며, TensorFlow 기반 `hd2` 모델을 사용해 궁합 점수를 계산합니다.

## 요구 사항

- Python 3.11.x (Windows에서 `py -3.11` 사용 권장)
- MySQL 8.x
- PowerShell 7 이상 (테스트 스크립트 실행 시)

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
   - `SECRET_KEY`: JWT 서명용 시크릿
   - `DATABASE_URL`: 예) `mysql+pymysql://root@127.0.0.1:3306/teamproject?charset=utf8mb4`
   - `LUNAR_API_KEY`: 공공데이터포털 음력 변환 API 키

`app/config.py`가 `.env`를 자동으로 로드하며, `APP_ENV` 값에 따라 개발/테스트/운영 구성이 선택됩니다.

## 데이터베이스

MySQL 초기 구축 및 스키마 적용 절차는 `documents/mysql_integration.md`를 참고하세요. 요약:

1. MySQL에서 `teamproject` 데이터베이스와 사용자 계정을 생성
2. `DATABASE_URL` 환경 변수를 맞춘 뒤 `py -m scripts.db_init` (또는 제공된 SQL)로 테이블 생성
3. 필요한 기본 데이터 삽입 (유저, 게시글 등)

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

## 문서

- API 명세: `documents/api_spec.md`
- 미구현/추가 과제 추적: `documents/outstanding_features.md`
- MySQL 연동 가이드: `documents/mysql_integration.md`

필요 시 `documents` 디렉터리 아래에서 ADR, 클래스 다이어그램 등을 참조하세요.


