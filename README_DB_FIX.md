# 데이터베이스 연결 문제 해결 가이드

## 문제 상황
- Flutter 앱에서 생성한 사용자(2nd, 3rd)가 MySQL에 없음
- 게시글이 불러와지지 않음
- 글 작성 시 500 Internal Server Error 발생

## 원인
`.env` 파일이 없어서 기본값인 SQLite(`sqlite:///app.db`)를 사용하고 있었습니다.

## 해결 방법

### 1. .env 파일 확인
`.env` 파일이 생성되었는지 확인:
```powershell
Get-Content .env
```

### 2. MySQL 연결 정보 확인
`.env` 파일의 `DATABASE_URL`이 올바른지 확인:
```
DATABASE_URL=mysql+pymysql://root@127.0.0.1:3306/teamproject?charset=utf8mb4
```

**비밀번호가 필요한 경우:**
```
DATABASE_URL=mysql+pymysql://root:비밀번호@127.0.0.1:3306/teamproject?charset=utf8mb4
```

### 3. MySQL 연결 테스트
```powershell
.\.venv311\Scripts\Activate.ps1
python test_mysql_connection.py
```

### 4. Flask 서버 재시작 (중요!)
`.env` 파일을 수정한 후에는 **반드시 Flask 서버를 재시작**해야 합니다:

1. 현재 실행 중인 Flask 서버 중지 (Ctrl+C)
2. 서버 재시작:
```powershell
.\.venv311\Scripts\Activate.ps1
.\start_backend.ps1
```

또는:
```powershell
.\.venv311\Scripts\Activate.ps1
$env:FLASK_APP = "app.main:create_app"
py -m flask run --host 0.0.0.0 --port 5000
```

### 5. 연결 확인
서버 재시작 후 다음을 확인:
- Flutter 앱에서 로그인 시도
- 게시글 작성 시도
- 서버 로그에서 에러 메시지 확인

## 현재 MySQL 데이터베이스 상태
테스트 결과:
- ✅ MySQL 연결 성공
- ✅ 데이터베이스: teamproject
- ✅ users 테이블 접근 성공
- 현재 사용자 수: 3명
  - ID: 1, 이름: test1
  - ID: 2, 이름: test2
  - ID: 3, 이름: 123

## 추가 확인 사항

### Flutter 앱에서 생성한 사용자가 MySQL에 없는 이유
Flutter 앱에서 회원가입한 사용자는 MySQL에 저장되어야 하지만, 서버가 SQLite를 사용하고 있었다면 SQLite에 저장되었을 수 있습니다.

**확인 방법:**
```powershell
# SQLite 확인
sqlite3 app.db "SELECT user_id, username, email FROM users;"

# MySQL 확인
python test_mysql_connection.py
```

### 데이터 마이그레이션 (필요한 경우)
SQLite에 있는 데이터를 MySQL로 옮기려면 별도의 마이그레이션 스크립트가 필요합니다.

## 문제 해결 체크리스트
- [ ] `.env` 파일이 존재하는지 확인
- [ ] `.env` 파일의 `DATABASE_URL`이 올바른지 확인
- [ ] MySQL 서버가 실행 중인지 확인
- [ ] `test_mysql_connection.py` 실행하여 연결 확인
- [ ] Flask 서버 재시작
- [ ] Flutter 앱에서 다시 테스트

