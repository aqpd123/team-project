# 서버 연결 문제 해결 가이드

## 🔴 "the connection errored" 오류 해결

릴리즈 빌드된 APK를 설치한 후 서버 연결 오류가 발생하는 경우, 다음 단계를 따라 확인하세요.

---

## 1단계: 서버 연결 테스트

```powershell
# 서버 연결 테스트 스크립트 실행
.\test_server_connection.ps1
```

이 스크립트는:
- ✅ 서버가 실행 중인지 확인
- ✅ 외부 IP로 접근 가능한지 확인
- ✅ 방화벽 규칙 확인

---

## 2단계: 백엔드 서버 실행 확인

**중요**: 서버가 `--host 0.0.0.0` 옵션으로 실행되어야 합니다!

```powershell
# 방법 1: 스크립트 사용 (권장)
.\start_backend.ps1

# 방법 2: 직접 실행
.\.venv311\Scripts\Activate.ps1
$env:FLASK_APP = "app.main:create_app"
py -m flask run --host 0.0.0.0 --port 5000
```

**확인 사항:**
- 터미널에 `* Running on http://0.0.0.0:5000` 메시지가 표시되어야 함
- `http://127.0.0.1:5000`만 표시되면 외부 접근 불가

---

## 3단계: 빌드 시 서버 주소 확인

빌드 시 서버 주소가 올바르게 지정되었는지 확인:

```powershell
# 빌드 스크립트 실행 (IP 자동 감지)
.\build_release.ps1
```

빌드 출력에서 다음을 확인:
```
✅ 감지된 PC IP 주소: 192.168.0.7
✅ API 서버 주소: http://192.168.0.7:5000
🔍 빌드된 APK가 사용할 서버 주소: http://192.168.0.7:5000
```

---

## 4단계: 앱에서 사용하는 서버 주소 확인

앱 실행 시 로그에서 실제 사용하는 서버 주소를 확인:

### 방법 1: ADB 로그 확인 (USB 연결 시)

```powershell
# 휴대폰을 USB로 연결
adb logcat | findstr "API Client"
```

출력 예시:
```
🔗 API Client 초기화: 서버 주소 = http://192.168.0.7:5000
```

### 방법 2: Flutter DevTools 사용

1. 앱 실행 중 Flutter DevTools 열기
2. 로그 탭에서 "API Client" 검색

---

## 5단계: 네트워크 연결 확인

### 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결되어 있는지 확인

1. **컴퓨터 IP 확인:**
   ```powershell
   ipconfig
   # IPv4 주소 확인 (예: 192.168.0.7)
   ```

2. **휴대폰에서 테스트:**
   - 휴대폰 브라우저에서 `http://192.168.0.7:5000` 접속
   - 접속이 되면 서버는 정상 작동 중
   - 접속이 안 되면 네트워크 문제

---

## 6단계: 방화벽 설정 확인

Windows 방화벽에서 포트 5000을 허용:

```powershell
# 관리자 권한으로 실행
New-NetFirewallRule -DisplayName "Flask Server" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
```

또는 Windows 방화벽 설정에서 수동으로 포트 5000 허용

---

## 🔍 문제 진단 체크리스트

연결 오류 발생 시 다음을 확인:

- [ ] 백엔드 서버가 `--host 0.0.0.0` 옵션으로 실행 중
- [ ] 서버가 `http://0.0.0.0:5000`에서 실행 중 (터미널 확인)
- [ ] 빌드 시 올바른 서버 주소 지정 (`--dart-define=API_BASE_URL=...`)
- [ ] 앱 로그에서 사용하는 서버 주소 확인
- [ ] 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결
- [ ] 방화벽에서 포트 5000 허용
- [ ] 휴대폰 브라우저에서 서버 주소 접속 가능

---

## 🛠️ 자주 발생하는 문제

### 문제 1: 서버 주소가 localhost로 설정됨 또는 --dart-define이 작동하지 않음

**증상:**
- 앱 로그: `🔗 API Client 초기화: 서버 주소 = http://localhost:5000`
- 또는 `http://127.0.0.1:5000`
- 디버그 APK는 작동하지만 릴리즈 APK만 연결 안 됨

**원인:**
- 릴리즈 빌드에서 `--dart-define`이 제대로 작동하지 않을 수 있음
- Flutter의 릴리즈 빌드는 최적화 과정에서 환경 변수를 다르게 처리할 수 있음

**해결 방법 1: api_client.dart 직접 수정 (권장)**
```powershell
# 자동 수정 스크립트 사용
.\fix_release_build.ps1
```

**해결 방법 2: 수동 수정**
1. `FrontEnd\lastlast\lib\services\api_client.dart` 파일 열기
2. `defaultValue`를 컴퓨터 IP로 변경:
   ```dart
   defaultValue: 'http://192.168.0.7:5000',
   ```
3. 빌드:
   ```powershell
   cd FrontEnd\lastlast
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

### 문제 2: 서버가 외부 접근을 허용하지 않음

**증상:**
- 터미널: `* Running on http://127.0.0.1:5000`
- 외부 IP로 접근 불가

**해결:**
- `--host 0.0.0.0` 옵션 추가
- `.\start_backend.ps1` 스크립트 사용

### 문제 3: 방화벽 차단

**증상:**
- 컴퓨터에서는 접근 가능
- 휴대폰에서는 접근 불가

**해결:**
- 방화벽 규칙 추가
- `.\test_server_connection.ps1` 실행하여 확인

### 문제 4: 다른 Wi-Fi에 연결됨

**증상:**
- 서버는 정상 작동
- 휴대폰에서 접근 불가

**해결:**
- 컴퓨터와 휴대폰이 같은 Wi-Fi 네트워크에 연결되어 있는지 확인

---

## 📞 추가 도움

위 방법으로 해결되지 않으면:

1. `test_server_connection.ps1` 실행 결과 확인
2. 앱 로그에서 실제 사용하는 서버 주소 확인
3. 휴대폰 브라우저에서 서버 주소 직접 접속 테스트

