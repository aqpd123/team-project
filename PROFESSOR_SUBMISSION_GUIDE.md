# 교수님 제출용 가이드

## 📦 제출 파일 목록

다음 파일들을 함께 제출하세요:

### 필수 파일
1. **전체 소스코드** (GitHub 저장소 또는 ZIP 파일)
2. **README.md** - 프로젝트 개요 및 기본 실행 방법
3. **QUICK_START.md** - 5분 안에 실행하기
4. **SETUP_GUIDE.md** - 상세 설정 가이드
5. **BUILD_GUIDE.md** - Flutter 앱 빌드 가이드
6. **requirements.txt** - Python 패키지 목록
7. **env.example** - 환경 변수 예시

### 선택 파일
8. **.env** - 실제 환경 변수 (GEMINI_API_KEY 포함)
   - ⚠️ 보안 주의: 실제 프로덕션에서는 `.env`를 제출하지 마세요
   - 교수님 환경에서는 `.env` 파일을 제공하면 바로 실행 가능

---

## 🚀 교수님 환경에서 실행하기

### 1단계: 백엔드 서버 실행 (약 3분)

```powershell
# 1. 가상환경 생성 및 활성화
py -3.11 -m venv .venv311
.\.venv311\Scripts\Activate.ps1

# 2. 패키지 설치
py -m pip install --upgrade pip
py -m pip install -r requirements.txt

# 3. 환경 변수 설정
Copy-Item env.example .env
# .env 파일을 열어서 GEMINI_API_KEY 확인 (제공된 .env 파일이 있다면 생략)

# 4. 백엔드 서버 실행
$env:FLASK_APP = "app.main:create_app"
py -m flask run --port 5000
```

**성공 확인:**
- 터미널에 `* Running on http://127.0.0.1:5000` 메시지가 표시됨
- 브라우저에서 `http://127.0.0.1:5000` 접속 시 Flask 앱이 실행됨

### 2단계: Flutter 앱 실행 (약 2분)

**새 터미널 창 열기:**

```powershell
# Flutter 프로젝트 디렉토리로 이동
cd FrontEnd\lastlast

# 의존성 설치
flutter pub get

# 앱 실행 (연결된 기기 또는 에뮬레이터에)
flutter run
```

**또는 APK 빌드:**

```powershell
# 릴리즈 APK 빌드
flutter build apk --release

# 빌드된 파일 위치
# build\app\outputs\flutter-apk\app-release.apk
```

---

## ✅ 체크리스트

제출 전 확인사항:

### 백엔드
- [ ] `.env` 파일이 있고 `GEMINI_API_KEY`가 설정되어 있음
- [ ] `requirements.txt`의 모든 패키지가 설치 가능함
- [ ] 백엔드 서버가 `http://127.0.0.1:5000`에서 정상 실행됨
- [ ] 데이터베이스 파일(`app.db`)이 자동으로 생성됨
- [ ] API 엔드포인트가 정상 작동함

### 프론트엔드
- [ ] `flutter pub get` 실행 시 오류 없음
- [ ] `flutter build apk --release` 빌드 성공
- [ ] 앱이 서버에 연결되어 정상 작동함

### 문서
- [ ] README.md에 실행 방법이 명시되어 있음
- [ ] QUICK_START.md가 포함되어 있음
- [ ] SETUP_GUIDE.md가 포함되어 있음

---

## 🔧 문제 해결

### 백엔드 서버가 시작되지 않음

1. **Python 버전 확인**
   ```powershell
   py -3.11 --version
   ```
   Python 3.11이 없으면 설치 필요

2. **포트 충돌**
   ```powershell
   # 다른 포트 사용
   py -m flask run --port 5001
   ```

3. **패키지 설치 오류**
   ```powershell
   py -m pip install --upgrade pip setuptools wheel
   py -m pip install -r requirements.txt
   ```

### Flutter 앱이 서버에 연결되지 않음

1. **서버 주소 확인**
   - `FrontEnd\lastlast\lib\services\api_client.dart` 파일 확인
   - `defaultApiBaseUrl`이 올바른지 확인

2. **실제 기기에서 테스트**
   - 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결
   - 컴퓨터 IP 주소 확인: `ipconfig`
   - `api_client.dart`에서 IP 주소 수정

---

## 📝 추가 정보

### 데이터베이스

- **SQLite 사용** (기본값)
  - 별도 설치 없이 작동
  - 프로젝트 루트에 `app.db` 파일 자동 생성
  - 테이블은 자동으로 생성됨

### API 서버

- 기본 포트: `5000`
- 로컬 주소: `http://127.0.0.1:5000`
- 네트워크 주소: `http://<컴퓨터-IP>:5000`

### Flutter 앱

- 개발 모드: `flutter run`
- 디버그 APK: `flutter build apk --debug`
- 릴리즈 APK: `flutter build apk --release`

---

## 💡 팁

1. **첫 실행 시**: 데이터베이스가 자동으로 생성되므로 초기화 작업이 필요 없습니다
2. **에러 발생 시**: `QUICK_START.md`의 "문제 해결" 섹션 참고
3. **빠른 테스트**: 백엔드 서버만 실행하고 브라우저에서 API 테스트 가능

