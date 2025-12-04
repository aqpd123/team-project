# 빠른 시작 가이드 (교수님용)

## ⚠️ 릴리즈 빌드 시 주의사항

**릴리즈 빌드를 휴대폰에 설치할 때:**

1. **백엔드 서버를 외부 접속 허용 모드로 실행:**
   ```powershell
   # 방법 1: 스크립트 사용 (권장)
   .\start_backend.ps1
   
   # 방법 2: 직접 실행
   py -m flask run --host 0.0.0.0 --port 5000
   ```

2. **빌드 시 서버 주소 지정:**
   ```powershell
   cd FrontEnd\lastlast
   # 컴퓨터 IP 주소 확인
   ipconfig
   # 예: 192.168.0.7
   
   # 서버 주소를 지정하여 빌드
   flutter build apk --release --dart-define=API_BASE_URL=http://192.168.0.7:5000
   ```

3. **방화벽 설정:**
   - Windows 방화벽에서 포트 5000 허용

자세한 내용은 `RELEASE_BUILD_INSTRUCTIONS.md` 참고

---

## ⚡ 5분 안에 프로젝트 실행하기

### 1단계: 백엔드 서버 실행

```powershell
# 프로젝트 루트 디렉토리에서 실행

# 1. 가상환경 생성 및 활성화
py -3.11 -m venv .venv311
.\.venv311\Scripts\Activate.ps1

# 2. 패키지 설치
py -m pip install --upgrade pip
py -m pip install -r requirements.txt

# 3. 환경 변수 설정 (이미 .env 파일이 있다면 생략 가능)
Copy-Item env.example .env
# .env 파일을 열어서 GEMINI_API_KEY가 설정되어 있는지 확인

# 4. 백엔드 서버 실행
# 방법 1: 스크립트 사용 (외부 접속 허용, 권장)
.\start_backend.ps1

# 방법 2: 직접 실행 (로컬만)
$env:FLASK_APP = "app.main:create_app"
py -m flask run --port 5000

# 방법 3: 직접 실행 (외부 접속 허용, 릴리즈 빌드용)
$env:FLASK_APP = "app.main:create_app"
py -m flask run --host 0.0.0.0 --port 5000
```

**성공 메시지:**
```
🔗 데이터베이스 연결: sqlite:///app.db
✅ 데이터베이스 초기화 완료
 * Running on http://127.0.0.1:5000
```

### 2단계: Flutter 앱 실행 (또는 빌드)

**새 터미널 창 열기:**

```powershell
# Flutter 프로젝트 디렉토리로 이동
cd FrontEnd\lastlast

# 의존성 설치
flutter pub get

# 앱 실행 (연결된 기기 또는 에뮬레이터에)
flutter run

# 또는 APK 빌드
flutter build apk --release
```

---

## 🔧 문제 해결

### 백엔드 서버가 시작되지 않음

1. **Python 버전 확인**
   ```powershell
   py -3.11 --version
   ```
   Python 3.11이 설치되어 있지 않으면 설치 필요

2. **포트 5000이 이미 사용 중**
   ```powershell
   # 다른 포트 사용
   py -m flask run --port 5001
   ```
   그리고 `api_client.dart`에서 포트 번호도 변경

3. **패키지 설치 오류**
   ```powershell
   # pip 업그레이드 후 재시도
   py -m pip install --upgrade pip setuptools wheel
   py -m pip install -r requirements.txt
   ```

### Flutter 앱이 서버에 연결되지 않음

1. **서버 주소 확인**
   - `FrontEnd\lastlast\lib\services\api_client.dart` 파일 확인
   - `defaultApiBaseUrl`이 올바른지 확인

2. **실제 기기에서 테스트하는 경우**
   - 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결되어 있어야 함
   - 컴퓨터의 IP 주소 확인:
     ```powershell
     ipconfig
     # IPv4 주소 확인 (예: 192.168.0.5)
     ```
   - `api_client.dart`에서 `defaultValue`를 컴퓨터 IP로 변경:
     ```dart
     defaultValue: 'http://192.168.0.5:5000',
     ```

3. **방화벽 확인**
   - Windows 방화벽에서 포트 5000 허용 필요할 수 있음

---

## 📱 APK 빌드 및 설치

### APK 빌드

```powershell
cd FrontEnd\lastlast
flutter build apk --release
```

빌드된 파일:
- `build\app\outputs\flutter-apk\app-release.apk`

### APK 설치

1. **USB 연결**
   ```powershell
   flutter install
   ```

2. **또는 파일 전송**
   - APK 파일을 휴대폰으로 전송
   - 휴대폰에서 파일 관리자로 열기
   - 설치 진행

---

## ✅ 체크리스트

프로젝트 제출 전 확인사항:

- [ ] `.env` 파일이 있고 `GEMINI_API_KEY`가 설정되어 있음
- [ ] `requirements.txt`의 모든 패키지가 설치 가능함
- [ ] 백엔드 서버가 `http://127.0.0.1:5000`에서 정상 실행됨
- [ ] 데이터베이스 파일(`app.db`)이 자동으로 생성됨
- [ ] Flutter 앱이 서버에 연결되어 정상 작동함
- [ ] README.md에 실행 방법이 명시되어 있음

