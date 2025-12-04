# 프로젝트 설정 및 실행 가이드

교수님 환경에서 프로젝트를 정상적으로 실행하기 위한 상세 가이드입니다.

## 📋 목차

1. [백엔드 설정 (교수님 환경)](#1-백엔드-설정-교수님-환경)
2. [Flutter 앱 빌드 방법](#2-flutter-앱-빌드-방법)
3. [앱에서 데이터베이스 설정](#3-앱에서-데이터베이스-설정)

---

## 1. 백엔드 설정 (교수님 환경)

### 1.1 환경 변수 설정

1. 프로젝트 루트 디렉토리에서 `.env` 파일 생성:
   ```powershell
   # Windows PowerShell
   Copy-Item env.example .env
   ```

2. `.env` 파일 편집 (텍스트 에디터로 열기):
   ```env
   APP_ENV=development
   FLASK_ENV=development
   SECRET_KEY=change-me-to-random-string
   DATABASE_URL=sqlite:///app.db
   LUNAR_API_KEY=72033766be7ee41338af559f9e99138d77c3f29be234bd231e5b88414aff05ea
   GEMINI_API_KEY=AIzaSyDhxTgWzBh3cXxT5Fr3WWpHSwb4ZqsTkt0
   ```

   **중요**: 
   - `DATABASE_URL=sqlite:///app.db`는 프로젝트 루트에 `app.db` 파일을 생성합니다
   - SQLite는 별도 설치 없이 작동합니다
   - 데이터베이스 파일은 자동으로 생성됩니다

### 1.2 Python 가상환경 설정

```powershell
# Python 3.11 가상환경 생성
py -3.11 -m venv .venv311

# 가상환경 활성화 (Windows)
.\.venv311\Scripts\Activate.ps1

# 패키지 설치
py -m pip install --upgrade pip
py -m pip install -r requirements.txt
```

### 1.3 데이터베이스 초기화

데이터베이스는 자동으로 생성되지만, 테이블 스키마를 생성하려면:

```powershell
# Flask 앱 실행 시 자동으로 테이블이 생성됩니다
# 또는 직접 실행:
py -c "from app.main import create_app; app = create_app(); print('✅ 데이터베이스 초기화 완료')"
```

### 1.4 백엔드 서버 실행

```powershell
# 가상환경 활성화 (아직 안 했다면)
.\.venv311\Scripts\Activate.ps1

# Flask 앱 실행
$env:FLASK_APP = "app.main:create_app"
py -m flask run --port 5000
```

서버가 정상적으로 실행되면:
```
 * Running on http://127.0.0.1:5000
```

### 1.5 문제 해결

**문제**: 데이터베이스 파일이 생성되지 않음
- **해결**: 프로젝트 루트 디렉토리에서 실행했는지 확인
- **해결**: `.env` 파일의 `DATABASE_URL`이 `sqlite:///app.db`인지 확인

**문제**: 패키지 설치 오류
- **해결**: Python 3.11이 설치되어 있는지 확인 (`py -3.11 --version`)
- **해결**: 인터넷 연결 확인

**문제**: 포트 5000이 이미 사용 중
- **해결**: 다른 포트 사용 (`py -m flask run --port 5001`)

---

## 2. Flutter 앱 빌드 방법

### 2.1 개발용 APK 빌드 (디버그 모드)

```powershell
# Flutter 프로젝트 디렉토리로 이동
cd FrontEnd\lastlast

# 의존성 설치
flutter pub get

# 디버그 APK 빌드
flutter build apk --debug
```

빌드된 APK 위치:
- `FrontEnd\lastlast\build\app\outputs\flutter-apk\app-debug.apk`

### 2.2 배포용 APK 빌드 (릴리즈 모드)

```powershell
# 릴리즈 APK 빌드
flutter build apk --release
```

빌드된 APK 위치:
- `FrontEnd\lastlast\build\app\outputs\flutter-apk\app-release.apk`

### 2.3 Android App Bundle (AAB) 빌드 (Google Play 배포용)

```powershell
# AAB 빌드
flutter build appbundle --release
```

빌드된 AAB 위치:
- `FrontEnd\lastlast\build\app\outputs\bundle\release\app-release.aab`

### 2.4 빌드 전 확인사항

1. **API 서버 주소 확인**
   - `FrontEnd\lastlast\lib\services\api_client.dart` 파일 확인
   - 로컬 테스트: `http://localhost:5000` 또는 `http://10.0.2.2:5000` (에뮬레이터)
   - 실제 기기: `http://<컴퓨터-IP-주소>:5000`

2. **인터넷 권한 확인**
   - `FrontEnd\lastlast\android\app\src\main\AndroidManifest.xml`에 인터넷 권한이 있는지 확인

3. **서명 키 설정** (릴리즈 빌드 시)
   - `FrontEnd\lastlast\android\app\key.properties` 파일 생성 (선택사항)

### 2.5 APK 설치 방법

**방법 1: USB 연결**
```powershell
# USB로 연결된 기기에 설치
flutter install
```

**방법 2: APK 파일 직접 설치**
1. 빌드된 APK 파일을 휴대폰으로 전송
2. 휴대폰에서 파일 관리자로 APK 파일 열기
3. "알 수 없는 출처" 설치 허용 (필요시)
4. 설치 진행

---

## 3. 앱에서 데이터베이스 설정

### 3.1 현재 구조

- **백엔드**: SQLite 데이터베이스 (`app.db`) 사용
- **프론트엔드**: HTTP API를 통해 백엔드와 통신
- **앱 빌드 시**: 백엔드 서버 주소만 설정하면 됨

### 3.2 앱에서 백엔드 서버 연결 설정

#### 방법 1: API 클라이언트에서 서버 주소 설정

`FrontEnd\lastlast\lib\services\api_client.dart` 파일 확인:

```dart
class ApiClient {
  // 로컬 개발 환경
  static const String baseUrl = 'http://localhost:5000';
  
  // 실제 기기 테스트 (컴퓨터 IP 주소로 변경)
  // static const String baseUrl = 'http://192.168.0.5:5000';
}
```

**실제 기기에서 테스트할 때:**
1. 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결되어 있어야 함
2. 컴퓨터의 IP 주소 확인:
   ```powershell
   # Windows
   ipconfig
   # IPv4 주소 확인 (예: 192.168.0.5)
   ```
3. `api_client.dart`에서 `baseUrl`을 컴퓨터 IP로 변경:
   ```dart
   static const String baseUrl = 'http://192.168.0.5:5000';
   ```
4. 앱 재빌드

#### 방법 2: 환경 변수로 설정 (권장)

더 나은 방법은 빌드 시 서버 주소를 설정하는 것입니다:

1. `FrontEnd\lastlast\lib\services\api_client.dart` 수정:
   ```dart
   class ApiClient {
     static String get baseUrl {
       // 환경 변수에서 가져오거나 기본값 사용
       const String? envUrl = String.fromEnvironment('API_BASE_URL');
       return envUrl ?? 'http://localhost:5000';
     }
   }
   ```

2. 빌드 시 서버 주소 지정:
   ```powershell
   flutter build apk --release --dart-define=API_BASE_URL=http://192.168.0.5:5000
   ```

### 3.3 데이터베이스 초기 데이터 (선택사항)

앱이 처음 실행될 때 필요한 초기 데이터가 있다면:

1. **백엔드에 초기화 스크립트 추가**
   - `scripts/init_db.py` 같은 파일 생성
   - 기본 유저, 게시글 등 추가

2. **또는 SQLite 데이터베이스 파일 제공**
   - 초기 데이터가 포함된 `app.db` 파일을 프로젝트에 포함
   - 교수님이 실행 시 자동으로 사용

### 3.4 앱 배포 시 고려사항

**현재 구조의 한계:**
- 앱이 백엔드 서버에 의존함
- 서버가 실행 중이어야 앱이 작동함

**해결 방안:**

1. **클라우드 서버 사용** (권장)
   - AWS, Google Cloud, Heroku 등에 백엔드 배포
   - 앱에서 클라우드 서버 주소로 연결

2. **로컬 서버 + 앱 패키징**
   - 백엔드 서버를 앱과 함께 패키징 (복잡함)
   - 또는 서버 실행 가이드 제공

---

## 📝 교수님께 전달할 파일 목록

다음 파일들을 함께 제공하세요:

1. **프로젝트 소스코드** (전체)
2. **README.md** (이 파일 참고)
3. **SETUP_GUIDE.md** (이 파일)
4. **requirements.txt** (Python 패키지 목록)
5. **env.example** (환경 변수 예시)
6. **.env** (실제 환경 변수 - GEMINI_API_KEY 포함)

---

## 🚀 빠른 시작 가이드 (교수님용)

```powershell
# 1. 가상환경 생성 및 활성화
py -3.11 -m venv .venv311
.\.venv311\Scripts\Activate.ps1

# 2. 패키지 설치
py -m pip install --upgrade pip
py -m pip install -r requirements.txt

# 3. 환경 변수 설정
Copy-Item env.example .env
# .env 파일을 열어서 GEMINI_API_KEY 확인

# 4. 백엔드 서버 실행
$env:FLASK_APP = "app.main:create_app"
py -m flask run --port 5000

# 5. 다른 터미널에서 Flutter 앱 실행 (또는 빌드)
cd FrontEnd\lastlast
flutter pub get
flutter run
```

---

## ❓ 자주 묻는 질문

**Q: 데이터베이스 파일이 어디에 생성되나요?**
A: 프로젝트 루트 디렉토리에 `app.db` 파일이 생성됩니다.

**Q: 앱을 다른 기기에 설치하려면?**
A: 빌드된 APK 파일을 다른 기기로 전송하여 설치하면 됩니다. 단, 백엔드 서버가 실행 중이어야 합니다.

**Q: 인터넷 없이도 작동하나요?**
A: 네, 로컬 네트워크(Wi-Fi)만 있으면 됩니다. 백엔드 서버가 실행 중이고, 앱과 서버가 같은 네트워크에 연결되어 있으면 작동합니다.

