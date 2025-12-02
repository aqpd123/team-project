# Flutter 모바일 디버깅 가이드

## 🚫 Expo Go는 사용할 수 없습니다

**Expo Go는 React Native 전용 앱**입니다. Flutter 앱은 Expo Go로 실행할 수 없습니다.

## ✅ 가벼운 디버깅 방법들

### 방법 1: VS Code 사용 (가장 가벼움) ⭐ 추천

#### 준비사항
1. **VS Code 설치** (이미 설치되어 있다면 생략)
2. **Flutter 확장 프로그램 설치**
   - VS Code에서 `Ctrl+Shift+X` (확장 프로그램)
   - "Flutter" 검색 후 설치
   - "Dart" 확장도 자동 설치됨

#### 사용 방법

1. **USB 디버깅 활성화** (안드로이드)
   ```
   - 휴대폰 설정 → 개발자 옵션 → USB 디버깅 활성화
   - USB로 PC에 연결
   ```

2. **디바이스 확인**
   ```powershell
   cd FrontEnd/lastlast
   flutter devices
   ```

3. **VS Code에서 실행**
   - `F5` 키를 누르거나
   - 왼쪽 사이드바의 "실행 및 디버그" 아이콘 클릭
   - "Flutter (모바일 디버깅)" 선택 후 실행

4. **Hot Reload**
   - 코드 수정 후 `Ctrl+S` 저장하면 자동으로 Hot Reload
   - 또는 터미널에서 `r` 키 입력

#### 장점
- ✅ Android Studio보다 훨씬 가볍고 빠름
- ✅ Hot Reload 지원
- ✅ 브레이크포인트 디버깅 가능
- ✅ Flutter DevTools 통합

---

### 방법 2: WiFi 디버깅 (Android 11+) - USB 없이

#### 설정 방법

**⚠️ 중요: 먼저 USB로 갤럭시 S22를 PC에 연결해야 합니다!**

1. **USB로 갤럭시 S22 연결**
   - USB 케이블로 PC에 연결
   - 휴대폰에서 "USB 디버깅 허용" 팝업이 뜨면 확인
   - 설정 → 개발자 옵션 → USB 디버깅 활성화 확인

2. **ADB 경로 설정 (한 번만)**
   
   **방법 A: PowerShell 프로필에 별칭 추가 (추천)**
   ```powershell
   # PowerShell 프로필 열기
   notepad $PROFILE
   
   # 다음 내용 추가
   $env:Path += ";C:\Users\user\AppData\Local\Android\sdk\platform-tools"
   Set-Alias -Name adb -Value "C:\Users\user\AppData\Local\Android\sdk\platform-tools\adb.exe"
   
   # 저장 후 PowerShell 재시작
   ```
   
   **방법 B: 직접 경로 사용 (별칭 없이)**
   ```powershell
   # 매번 전체 경로 사용
   & "C:\Users\user\AppData\Local\Android\sdk\platform-tools\adb.exe" <명령어>
   ```

3. **USB로 연결된 디바이스 확인**
   ```powershell
   # 별칭 설정한 경우
   adb devices
   
   # 또는 직접 경로 사용
   & "C:\Users\user\AppData\Local\Android\sdk\platform-tools\adb.exe" devices
   ```
   
   갤럭시 S22가 보여야 합니다 (예: `R58M30ABCDE    device`)

4. **WiFi 디버깅 모드로 전환**
   ```powershell
   # 별칭 설정한 경우
   adb tcpip 5555
   
   # 또는 직접 경로 사용
   & "C:\Users\user\AppData\Local\Android\sdk\platform-tools\adb.exe" tcpip 5555
   ```
   
   성공 메시지: `restarting in TCP mode port: 5555`

5. **휴대폰의 IP 주소 확인**
   ```
   갤럭시 S22에서:
   설정 → Wi-Fi → 연결된 네트워크 클릭 → IP 주소 확인
   (예: 192.168.0.100)
   ```

6. **WiFi로 연결**
   ```powershell
   # 별칭 설정한 경우
   adb connect 192.168.0.100:5555
   
   # 또는 직접 경로 사용
   & "C:\Users\user\AppData\Local\Android\sdk\platform-tools\adb.exe" connect 192.168.0.100:5555
   ```
   
   성공 메시지: `connected to 192.168.0.100:5555`

7. **연결 확인 및 USB 제거**
   ```powershell
   adb devices
   # 또는
   & "C:\Users\user\AppData\Local\Android\sdk\platform-tools\adb.exe" devices
   ```
   
   WiFi로 연결된 디바이스가 보이면 USB를 뽑아도 됩니다!

8. **Flutter에서 확인**
   ```powershell
   cd FrontEnd/lastlast
   flutter devices  # WiFi로 연결된 디바이스 확인
   flutter run       # 실행
   ```

#### 장점
- ✅ USB 케이블 없이 디버깅 가능
- ✅ 같은 WiFi 네트워크면 어디서든 가능

---

### 방법 3: 터미널에서 직접 실행 (가장 가벼움)

Android Studio나 VS Code 없이도 가능합니다:

```powershell
cd FrontEnd/lastlast

# 연결된 디바이스 확인
flutter devices

# 앱 실행 (Hot Reload 지원)
flutter run

# 특정 디바이스 선택
flutter run -d <device-id>

# Hot Reload: 터미널에서 'r' 키
# Hot Restart: 터미널에서 'R' 키
# Quit: 터미널에서 'q' 키
```

#### 장점
- ✅ IDE 없이도 가능
- ✅ 가장 가벼움
- ✅ Hot Reload 지원

---

### 방법 4: Flutter DevTools (웹 기반 디버깅)

앱이 실행 중일 때:

```powershell
# 터미널에 DevTools URL이 표시됨
# 예: http://127.0.0.1:9100/?uri=...
# 브라우저에서 열면 됨
```

또는 VS Code에서:
- 실행 중인 앱의 디버그 콘솔에서 "Open DevTools" 클릭

#### 기능
- 성능 프로파일링
- 위젯 트리 확인
- 네트워크 요청 확인
- 로그 확인

---

## 🔧 문제 해결

### 디바이스가 인식되지 않을 때

1. **USB 디버깅 확인**
   ```
   휴대폰: 설정 → 개발자 옵션 → USB 디버깅 활성화
   ```

2. **ADB 재시작**
   ```powershell
   adb kill-server
   adb start-server
   adb devices
   ```

3. **USB 드라이버 확인** (Windows)
   - 휴대폰 제조사 USB 드라이버 설치 필요

### Hot Reload가 작동하지 않을 때

- `R` 키로 Hot Restart 시도
- 앱을 완전히 종료 후 다시 실행

---

## 📱 iOS 디버깅 (Mac만 가능)

Mac을 사용하는 경우:

```powershell
# iOS 시뮬레이터 실행
open -a Simulator

# 또는 실제 iPhone 연결 후
flutter devices
flutter run
```

---

## 💡 추천 워크플로우

1. **개발 중**: VS Code 사용 (가볍고 편리)
2. **빠른 테스트**: 터미널에서 `flutter run`
3. **성능 분석**: Flutter DevTools 사용

---

## 참고 자료

- [Flutter 공식 문서 - 디버깅](https://docs.flutter.dev/testing/debugging)
- [VS Code Flutter 확장](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)

