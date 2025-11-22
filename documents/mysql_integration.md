## MySQL 연동 가이드

Flask + SQLAlchemy 기반 앱을 실제 MySQL 인스턴스에 연결할 때 필요한 준비, 설정, 검증 절차를 단계별로 정리했습니다. 개발·스테이징·운영 환경 모두 동일한 흐름을 따르되, 보안 정보(계정/비밀번호/API 키)는 환경변수나 비밀 관리 도구로 분리하세요.

---

### 1. 사전 준비
- MySQL 8.0 이상 설치 또는 클라우드 인스턴스 생성(예: AWS RDS, Azure Database for MySQL).
- 접속 정보: 호스트, 포트(기본 3306), DB 사용자, 비밀번호, 사용할 스키마(DB 이름).
- Python 의존성:
  ```powershell
  py -m pip install sqlalchemy pymysql
  ```
- 방화벽/보안그룹에서 애플리케이션 서버의 IP가 3306 포트를 사용할 수 있도록 허용.

---

### 2. 환경 변수 설정
- 저장소 루트의 `env.example`를 `.env`로 복사한 뒤 값을 수정합니다.
```
APP_ENV=development
SECRET_KEY=change-me
DATABASE_URL=mysql+pymysql://app_user:Str0ngPass!@db-host:3306/teamproject?charset=utf8mb4
LUNAR_API_KEY=72033766be7ee41338af559f9e99138d77c3f29be234bd231e5b88414aff05ea
```
- `DATABASE_URL` 형식: `mysql+pymysql://<USER>:<PASSWORD>@<HOST>:<PORT>/<DATABASE>?charset=utf8mb4`
- `app/config.py`가 `.env`를 자동 로드하므로 추가 스크립트 설정이 필요 없습니다.
- 운영 환경은 OS-level secret manager(예: Windows 환경변수, GitHub Actions secrets, Docker secrets) 사용 권장.

---

### 3. 데이터베이스/계정 생성
관리자 계정으로 MySQL에 접속해 다음을 실행합니다.
```sql
CREATE DATABASE IF NOT EXISTS teamproject CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'Str0ngPass!';
GRANT ALL PRIVILEGES ON teamproject.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
```
- 운영 환경에서는 최소 권한 원칙에 따라 `SELECT/INSERT/UPDATE/DELETE`만 부여하고, 마이그레이션 전용 계정을 별도로 두세요.

---

### 4. 스키마 적용(마이그레이션)
현재 코드베이스는 SQLAlchemy `Table` 정의(`app/infrastructure/database/models.py`)를 통해 스키마를 생성할 수 있습니다.

#### 4.1 1회 초기화
```powershell
set DATABASE_URL=mysql+pymysql://app_user:Str0ngPass!@db-host:3306/teamproject
python - <<'PY'
from app.infrastructure.database.db import init_engine_and_metadata
init_engine_and_metadata()
PY
```
- 위 스크립트는 메타데이터를 로드하고 `metadata.create_all(engine)`을 호출해 테이블을 생성합니다.

#### 4.2 Alembic(권장)
1) Alembic 설치: `py -m pip install alembic`
2) `alembic init migrations` 후 `env.py`에서 `DATABASE_URL`을 읽어 SQLAlchemy 메타데이터를 연결.
3) `alembic revision --autogenerate -m "init"` → `alembic upgrade head`
4) 스키마 변경 시마다 revision을 갱신해 배포/롤백을 일관되게 관리합니다.

---

### 5. 애플리케이션 연동
1. 환경 변수 설정: `set DATABASE_URL=...`
2. Flask 앱 실행:
   ```powershell
   set FLASK_APP=app.main:create_app
   flask run
   ```
3. 앱 시작 시 `app/main.py` → `init_db(app.config["DATABASE_URL"])`가 호출되어 엔진/세션이 준비됩니다.
4. API 호출 시 SQLAlchemy 세션이 자동으로 MySQL을 사용합니다.

---

### 6. 동작 검증
1. **연결 확인**
   ```powershell
   python - <<'PY'
from app.infrastructure.database.db import get_engine
from app.config import Config
engine = get_engine(Config.DATABASE_URL)
print(engine.execute("SELECT 1").scalar())
PY
   ```
2. **단위 테스트**
   ```powershell
   py -m pytest -q
   ```
   - 테스트 전용 DB를 따로 두거나, 트랜잭션 롤백/fixture를 사용해 상태를 초기화하세요.
3. **플라스크 통합 테스트**
   - `flask shell`에서 간단 CRUD 실행 또는 Postman으로 `/auth/sign-up`, `/posts` 등을 호출해 데이터가 MySQL에 적재되는지 확인.

---

### 7. 운영 체크리스트
- **커넥션 풀**: SQLAlchemy `create_engine()` 옵션으로 `pool_size`, `max_overflow`, `pool_recycle` 설정.
- **트랜잭션 관리**: 서비스 레이어에서 세션 스코프를 명확히 하고, 실패 시 롤백.
- **모니터링**: MySQL slow query log, APM(New Relic 등), SQLAlchemy 로깅(`DB_ECHO=true`)을 상황별로 활용.
- **백업/복구**: 정기적인 mysqldump 또는 스냅샷 전략 수립.
- **보안**: TLS 연결 사용, DB 계정 비밀번호 주기적 교체, 최소 권한 적용.
- **문서화**: 스키마 변경 시 ERD/문서와 동기화하고, `documents/outstanding_features.md`에서 상태를 업데이트.

이 가이드에 따라 환경을 구성하면 로컬/스테이징/운영 환경 모두에서 동일한 방식으로 MySQL을 사용할 수 있습니다. 필요 시 Docker Compose 템플릿이나 CI용 마이그레이션 스크립트를 추가해 자동화하세요.

