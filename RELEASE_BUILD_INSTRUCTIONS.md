# 릴리즈 빌드 및 설치 가이드

## 🚨 중요: 릴리즈 빌드 시 서버 연결 문제 해결

릴리즈 빌드를 휴대폰에 설치한 후 서버와 연결되지 않는 문제를 해결하는 방법입니다.

---

## 📋 사전 준비

### 1. 백엔드 서버 실행 확인

릴리즈 빌드된 앱도 백엔드 서버가 실행 중이어야 작동합니다.

```powershell
# 방법 1: 스크립트 사용 (권장, IP 자동 감지)
.\start_backend.ps1

# 방법 2: 직접 실행
.\.venv311\Scripts\Activate.ps1
$env:FLASK_APP = "app.main:create_app"
py -m flask run --host 0.0.0.0 --port 5000
```

**중요**: `--host 0.0.0.0` 옵션을 추가해야 다른 기기에서 접근 가능합니다!

**성공 메시지:**
```
 * Running on http://0.0.0.0:5000
```

### 2. 컴퓨터 IP 주소 확인

```powershell
ipconfig
# IPv4 주소 확인 (예: 192.168.0.7)
```

### 3. 방화벽 설정 확인

Windows 방화벽에서 포트 5000을 허용해야 합니다:

```powershell
# 관리자 권한으로 실행
New-NetFirewallRule -DisplayName "Flask Server" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
```

또는 Windows 방화벽 설정에서 수동으로 포트 5000 허용

---

## 🔨 릴리즈 APK 빌드 (서버 주소 지정)

### 방법 1: 빌드 스크립트 사용 (가장 간단, 권장)

```powershell
# 프로젝트 루트에서 실행
.\build_release.ps1
```

이 스크립트는:
- 컴퓨터 IP 주소를 자동으로 감지
- 서버 주소를 자동으로 설정하여 빌드
- 빌드 완료 후 APK 위치 안내

### 방법 2: 빌드 시 서버 주소 지정 (수동)

```powershell
cd FrontEnd\lastlast

# 1. 컴퓨터 IP 주소 확인
ipconfig
# 예: 192.168.0.7

# 2. 서버 주소를 지정하여 빌드
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.0.7:5000
```

**빌드된 파일:**
- `build\app\outputs\flutter-apk\app-release.apk`

### 방법 2: api_client.dart 직접 수정 후 빌드 (권장, --dart-define이 작동하지 않을 때)

**문제**: `--dart-define`이 릴리즈 빌드에서 제대로 작동하지 않을 수 있습니다.

**해결**: `api_client.dart`의 `defaultValue`를 직접 수정하는 방법:

```powershell
# 자동 수정 스크립트 사용 (권장)
.\fix_release_build.ps1
```

또는 수동으로:

1. `FrontEnd\lastlast\lib\services\api_client.dart` 파일 열기
2. `defaultValue` 수정:
   ```dart
   const String defaultApiBaseUrl = String.fromEnvironment(
     'API_BASE_URL',
     defaultValue: 'http://192.168.0.7:5000', // 여기를 컴퓨터 IP로 변경
   );
   ```
3. 빌드:
   ```powershell
   cd FrontEnd\lastlast
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

---

## 📱 APK 설치 및 테스트

### 방법 1: 자동 설치 (권장)

빌드 스크립트가 자동으로 설치를 시도합니다:

```powershell
# 빌드 및 자동 설치
.\fix_release_build.ps1
# 또는
.\build_release.ps1
```

**필수 조건:**
- USB로 휴대폰 연결
- USB 디버깅 활성화
- `adb devices`로 연결 확인

**자동 설치 과정:**
1. 빌드 완료 후 연결된 기기 자동 감지
2. `flutter install` 명령어로 설치 시도
3. 실패 시 `adb install`로 재시도

### 방법 2: 수동 설치

자동 설치가 실패하거나 USB 연결이 안 될 때:

#### 2-1. USB 연결 후 설치

```powershell
cd FrontEnd\lastlast
flutter install
```

또는

```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

#### 2-2. APK 파일 전송 후 설치

1. APK 파일을 휴대폰으로 전송:
   - USB 연결 후 복사
   - 이메일로 전송
   - 클라우드 스토리지 사용

2. 휴대폰에서 설치:
   - 파일 관리자로 APK 파일 열기
   - "알 수 없는 출처" 설치 허용 (필요시)
   - 설치 진행

### 3. 연결 확인

**필수 조건:**
- ✅ 백엔드 서버가 실행 중 (`http://0.0.0.0:5000`)
- ✅ 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결
- ✅ 방화벽에서 포트 5000 허용
- ✅ APK 빌드 시 올바른 서버 주소 지정

**테스트 방법:**
1. 앱 실행
2. 로그인 또는 회원가입 시도
3. 서버 연결이 정상이면 정상 작동
4. 연결 실패 시 "서버에 연결할 수 없습니다" 오류 표시

---

## 🔧 문제 해결

### 문제 1: "서버에 연결할 수 없습니다" 오류

**원인:**
- 백엔드 서버가 실행되지 않음
- 서버 주소가 잘못됨
- 방화벽 차단
- 다른 Wi-Fi에 연결됨

**해결:**
1. 백엔드 서버 실행 확인:
   ```powershell
   # 서버가 실행 중인지 확인
   # 터미널에 "Running on http://0.0.0.0:5000" 메시지가 있어야 함
   ```

2. 서버 주소 확인:
   - 컴퓨터 IP 주소 재확인: `ipconfig`
   - APK 빌드 시 지정한 주소와 일치하는지 확인

3. 방화벽 확인:
   ```powershell
   # 포트 5000이 열려있는지 확인
   netstat -an | findstr 5000
   ```

4. 같은 Wi-Fi 확인:
   - 컴퓨터와 휴대폰이 같은 Wi-Fi 네트워크에 연결되어 있는지 확인

### 문제 2: 빌드 시 서버 주소를 지정했는데도 연결 안 됨

**해결:**
1. 앱 완전 삭제 후 재설치
2. 빌드 캐시 정리:
   ```powershell
   cd FrontEnd\lastlast
   flutter clean
   flutter pub get
   flutter build apk --release --dart-define=API_BASE_URL=http://192.168.0.7:5000
   ```

### 문제 3: 컴퓨터 IP 주소가 자주 변경됨

**해결:**
1. 컴퓨터 IP 주소를 고정 IP로 설정 (라우터 설정)
2. 또는 매번 IP 확인 후 재빌드

---

## ✅ 체크리스트

릴리즈 빌드 전 확인사항:

- [ ] 백엔드 서버가 `--host=0.0.0.0` 옵션으로 실행 중
- [ ] 컴퓨터 IP 주소 확인 완료
- [ ] 방화벽에서 포트 5000 허용
- [ ] 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결
- [ ] 빌드 시 `--dart-define=API_BASE_URL=...` 지정
- [ ] APK 설치 후 앱이 정상 작동

---

## 💡 팁

1. **개발 중**: 디버그 빌드 사용 (`flutter run`)
2. **테스트**: 릴리즈 빌드 사용 (`flutter build apk --release --dart-define=...`)
3. **배포**: 클라우드 서버 사용 시 서버 주소를 클라우드 주소로 변경

