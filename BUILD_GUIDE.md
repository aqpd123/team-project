# Flutter 앱 빌드 가이드

## 📱 앱 빌드 방법

### 1. 디버그 APK 빌드 (개발/테스트용)

```powershell
cd FrontEnd\lastlast
flutter pub get
flutter build apk --debug
```

**빌드 위치:**
- `build\app\outputs\flutter-apk\app-debug.apk`

**특징:**
- 디버그 정보 포함
- 크기가 큼
- 개발/테스트용

### 2. 릴리즈 APK 빌드 (배포용)

**중요**: 릴리즈 빌드 시 서버 주소를 명시적으로 지정해야 합니다!

```powershell
cd FrontEnd\lastlast
flutter pub get

# 1. 컴퓨터 IP 주소 확인
ipconfig
# IPv4 주소 확인 (예: 192.168.0.7)

# 2. 서버 주소를 지정하여 빌드
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.0.7:5000
```

**빌드 위치:**
- `build\app\outputs\flutter-apk\app-release.apk`

**특징:**
- 최적화됨
- 크기가 작음
- 배포용
- 서버 주소가 빌드 시점에 고정됨

**주의사항:**
- `--dart-define=API_BASE_URL=...`를 반드시 지정해야 합니다
- 컴퓨터 IP 주소가 변경되면 다시 빌드해야 합니다
- 백엔드 서버가 실행 중이어야 앱이 작동합니다

### 3. Android App Bundle (AAB) 빌드 (Google Play 배포용)

```powershell
cd FrontEnd\lastlast
flutter pub get
flutter build appbundle --release
```

**빌드 위치:**
- `build\app\outputs\bundle\release\app-release.aab`

**특징:**
- Google Play Store 배포용
- APK보다 작음
- 동적 배포 지원

---

## 🔧 빌드 전 설정

### 1. API 서버 주소 설정

`FrontEnd\lastlast\lib\services\api_client.dart` 파일 확인:

```dart
const String defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.0.7:5000', // 여기를 수정
);
```

**실제 기기에서 테스트할 때:**
1. 컴퓨터 IP 주소 확인:
   ```powershell
   ipconfig
   # IPv4 주소 확인 (예: 192.168.0.5)
   ```

2. `api_client.dart`에서 `defaultValue` 수정:
   ```dart
   defaultValue: 'http://192.168.0.5:5000',
   ```

3. 빌드 시 환경 변수로 지정 (선택사항):
   ```powershell
   flutter build apk --release --dart-define=API_BASE_URL=http://192.168.0.5:5000
   ```

### 2. 앱 버전 설정

`FrontEnd\lastlast\pubspec.yaml` 파일:

```yaml
version: 1.0.0+1  # 버전명+빌드번호
```

---

## 📦 APK 설치 방법

### 방법 1: USB 연결 (권장)

```powershell
# USB로 연결된 기기에 직접 설치
flutter install
```

### 방법 2: ADB 사용

```powershell
# APK 파일을 기기에 설치
adb install build\app\outputs\flutter-apk\app-release.apk
```

### 방법 3: 파일 전송

1. APK 파일을 휴대폰으로 전송 (이메일, USB, 클라우드 등)
2. 휴대폰에서 파일 관리자로 APK 파일 열기
3. "알 수 없는 출처" 설치 허용 (필요시)
4. 설치 진행

---

## 🚨 빌드 오류 해결

### 오류: "Gradle build failed"

```powershell
# Gradle 캐시 정리
cd FrontEnd\lastlast\android
.\gradlew clean
cd ..\..
flutter clean
flutter pub get
flutter build apk --release
```

### 오류: "SDK not found"

1. Android Studio 설치
2. Android SDK 설치 확인
3. 환경 변수 설정:
   ```powershell
   $env:ANDROID_HOME = "C:\Users\<사용자명>\AppData\Local\Android\Sdk"
   ```

### 오류: "Signing config not found" (릴리즈 빌드)

릴리즈 빌드는 서명 키가 필요합니다. 디버그 빌드를 사용하거나 서명 키를 설정하세요.

---

## 📝 빌드 체크리스트

빌드 전 확인사항:

- [ ] `flutter doctor` 명령어로 환경 확인
- [ ] `flutter pub get` 실행 완료
- [ ] API 서버 주소가 올바르게 설정됨
- [ ] 백엔드 서버가 실행 중임
- [ ] 인터넷 연결 확인 (의존성 다운로드용)

