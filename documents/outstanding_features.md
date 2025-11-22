## 구현되지 않은 기능 요약

현재 소스 기준으로 아직 설계만 되어 있거나 TODO 상태인 주요 기능을 영역별로 정리했습니다.

### 1. API 계층
- `auth_controller.py`, `user_controller.py`, `post_controller.py`, `compatibility_controller.py`, `friend_controller.py` 구현 완료.
- DTO 검증은 Marshmallow 기반 공통 스키마(`common/schemas.py`)를 통해 적용 완료. 추가 과제: 인증 미들웨어 고도화, 통합 테스트 작성.

### 2. 도메인/서비스 계층
- `community_service.py`, `compatibility_service.py` 구현 완료(게시글/댓글, 궁합 요청·응답·알림 흐름 포함)하고 API 계층과 연동 완료.
- `friend_service.py` 확장: 친구 요청/응답/목록 + 취소/삭제/알림 제공, `CompatibilityService`는 친구 관계를 필수로 검증합니다. 추후 차단/친구 취소 히스토리, 친구 추천 등의 고도화가 필요합니다.
- 추가 과제: 커뮤니티/궁합 서비스 단위 테스트 확대(에러 케이스 포함), 캐싱·트랜잭션 전략 설계.
- `SajuCalculator.get_birth_data()`가 `GanjiCalculator`(cal.csv 기반)와 60갑자 일주 계산까지 포함하도록 보강되었습니다. 운영 환경에서의 정확도 검증, 윤달/절기 보정, API 응답 포맷 문서화가 후속 과제로 남아 있습니다.

### 3. 인프라/DB 계층
- 향후 실제 DBMS(MySQL/PostgreSQL) 연동 또는 마이그레이션 도구 연계 필요.
- 리포지토리 고도화(복잡 쿼리, 트랜잭션, 캐시 전략 등)는 아직 남아 있습니다.
- `friendships` 테이블이 추가되었으며, 중복/상태 관리 규칙 및 삭제 정책을 마이그레이션/ERD 문서에 반영해야 합니다.

### 4. 공통 모듈
- `common/security/auth.py`: PyJWT 기반 발급/검증 및 `@require_auth` 데코레이터 구현 완료. 향후 Refresh 토큰, 역할 기반 권한, 글로벌 에러 핸들러 연계가 필요합니다.
- `common/schemas.py`, `common/utils.py`, `common/typing.py`: 공통 스키마/유틸 정의가 비어 있습니다.
- `common/exceptions.py`에는 ValidationError 등만 존재하며, API 오류 응답 포맷/핸들러 연계 필요.

### 5. 설정 및 실행
- `config.py`가 `.env`를 자동 로드하고 `APP_ENV/FLASK_ENV`에 따라 개발·테스트·운영 설정을 선택하도록 정비 완료.
- 루트에 `env.example`, `requirements.txt`, 갱신된 `README.md`가 추가되어 환경 세팅 절차를 표준화했습니다.
- 잔여 과제: Flask CLI/wsgi 엔트리 작성, 배포 스크립트(예: Dockerfile, CI) 마련, 모델 경로·외부 API 키 관리 자동화.
- MySQL 연동 절차는 `documents/mysql_integration.md`에 정리되어 있으며, 실제 환경에서는 `DATABASE_URL=mysql+pymysql://user:pass@host:3306/dbname?charset=utf8mb4` 형태로 지정하고 보안 설정을 완료해야 합니다.

### 6. 테스트
- `tests/domain/community/*`에 기본 단위 테스트는 추가되었으나, 다양한 실패 케이스·리포지토리 모킹·API 통합 테스트가 더 필요합니다.
- API 통합 테스트, 리포지토리/DB 테스트, 인증 테스트가 필요합니다.

### 7. 외부 연계/데이터
- DB 스키마 문서와 실제 ORM 모델·마이그레이션 스크립트의 동기화 작업이 없습니다.
- 공공데이터 API(음력 변환)은 `LunarCalendarClient`로 호출 가능하지만, 운영 환경 키 관리·재시도·캐싱 및 TensorFlow 모델(.h5) 배포/로드 전략이 추가로 필요합니다.

이 문서는 현재 미구현 항목을 빠르게 파악하고 우선순위를 정하기 위한 용도로 작성되었습니다.

