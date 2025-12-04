# 릴리즈 APK 연결 오류 진단 가이드

## 🔍 문제 진단

릴리즈 APK가 설치되었지만 여전히 연결 오류가 발생하는 경우, 다음을 확인하세요.

---

## 1단계: 앱이 사용하는 서버 주소 확인

### 방법 1: Flutter DevTools 사용 (권장)

1. 앱 실행 중
2. Flutter DevTools 열기
3. 로그 탭에서 "API Client" 또는 "서버 주소" 검색
4. 다음 메시지 확인:
   ```
   🔗 API Client 초기화: 서버 주소 = http://...
   ```

### 방법 2: ADB 로그 확인

```powershell
# 휴대폰을 USB로 연결
flutter devices  # 연결 확인

# 로그 확인
flutter logs
# 또는
adb logcat | findstr "API Client"
```

**문제: "Waiting for another flutter command to release the startup lock..." 오류**

이 오류가 발생하면:

1. **Lock 파일 해제 스크립트 실행:**
   ```powershell
   .\fix_flutter_lock.ps1
   ```

2. **또는 수동으로:**
   ```powershell
   # Flutter 프로세스 종료
   Get-Process | Where-Object { $_.ProcessName -like "*flutter*" } | Stop-Process -Force
   
   # Lock 파일 삭제
   Remove-Item "$env:LOCALAPPDATA\Pub\Cache\lock" -Force -ErrorAction SilentlyContinue
   ```

3. **또는 다른 터미널 사용:**
   - VS Code의 다른 터미널 창 열기
   - 또는 Android Studio의 터미널 사용

출력 예시:
```
🔗 API Client 초기화: 서버 주소 = http://192.168.0.7:5000
```

---

## 2단계: 문제 확인 및 해결

### 문제 1: 앱이 localhost 또는 127.0.0.1을 사용

**증상:**
- 로그: `🔗 API Client 초기화: 서버 주소 = http://localhost:5000`
- 또는 `http://127.0.0.1:5000`

**원인:**
- `--dart-define`이 릴리즈 빌드에서 작동하지 않음
- `api_client.dart`의 `defaultValue`가 잘못 설정됨

**해결:**
```powershell
# api_client.dart 직접 수정 후 재빌드
.\fix_release_build.ps1
```

### 문제 2: 앱이 잘못된 IP 주소를 사용

**증상:**
- 로그: `🔗 API Client 초기화: 서버 주소 = http://192.168.0.5:5000`
- 하지만 현재 PC IP는 `192.168.0.7`

**원인:**
- IP 주소가 변경됨
- 이전에 빌드된 APK 사용

**해결:**
1. 현재 PC IP 확인:
   ```powershell
   ipconfig
   ```

2. `api_client.dart` 수정:
   ```dart
   defaultValue: 'http://192.168.0.7:5000', // 현재 PC IP로 변경
   ```

3. 재빌드:
   ```powershell
   .\fix_release_build.ps1
   ```

### 문제 3: 백엔드 서버가 실행되지 않음

**증상:**
- 연결 오류 발생
- 서버가 실행 중이지 않음

**해결:**
```powershell
# 백엔드 서버 실행
.\start_backend.ps1
```

**확인:**
- 터미널에 `* Running on http://0.0.0.0:5000` 메시지가 표시되어야 함

### 문제 4: 네트워크 연결 문제

**증상:**
- 서버는 실행 중
- 앱이 올바른 주소를 사용
- 하지만 연결 실패

**확인 사항:**
1. 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결되어 있는지
2. 휴대폰 브라우저에서 서버 주소 접속 가능한지:
   ```
   http://192.168.0.7:5000
   ```
3. 방화벽 설정 확인

---

## 3단계: 완전한 재설치

위 방법으로 해결되지 않으면:

1. **앱 완전 삭제:**
   - 휴대폰에서 앱 삭제

2. **api_client.dart 확인:**
   ```powershell
   # 파일 열기
   code FrontEnd\lastlast\lib\services\api_client.dart
   ```
   - 10번째 줄의 `defaultValue` 확인
   - 현재 PC IP와 일치하는지 확인

3. **재빌드 및 재설치:**
   ```powershell
   .\fix_release_build.ps1
   ```

---

## 4단계: 빠른 확인 체크리스트

- [ ] 백엔드 서버가 `--host 0.0.0.0` 옵션으로 실행 중
- [ ] 현재 PC IP 주소 확인 (`ipconfig`)
- [ ] `api_client.dart`의 `defaultValue`가 현재 PC IP와 일치
- [ ] 앱 로그에서 사용하는 서버 주소 확인
- [ ] 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결
- [ ] 휴대폰 브라우저에서 서버 주소 접속 가능
- [ ] 방화벽에서 포트 5000 허용

---

## 💡 팁

### 현재 설정 확인

```powershell
# api_client.dart의 현재 설정 확인
Select-String -Path "FrontEnd\lastlast\lib\services\api_client.dart" -Pattern "defaultValue"
```

### PC IP 주소 확인

```powershell
ipconfig | findstr IPv4
```

### 서버 실행 확인

```powershell
# 브라우저에서 접속하거나
Invoke-WebRequest -Uri "http://127.0.0.1:5000/auth/login" -Method POST -Body '{}' -ContentType "application/json"
```

---

## 🚨 여전히 해결되지 않으면

1. **앱 로그 전체 확인:**
   ```powershell
   flutter logs
   ```

2. **서버 로그 확인:**
   - 백엔드 서버 터미널에서 요청이 들어오는지 확인

3. **네트워크 테스트:**
   - 휴대폰 브라우저에서 `http://<PC-IP>:5000` 접속 테스트

