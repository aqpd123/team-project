# 애플리케이션 디버깅 가이드

이 가이드는 Flutter 앱을 WiFi를 통해 휴대폰에 띄우고 Flask 서버를 실행하는 전체 과정을 설명합니다.

---

## 📋 목차

1. [사전 준비사항](#사전-준비사항)
2. [초기 설정 (최초 1회)](#초기-설정-최초-1회)
3. [일일 디버깅 시작하기](#일일-디버깅-시작하기)
4. [WiFi 네트워크 변경 시](#wifi-네트워크-변경-시)
5. [문제 해결](#문제-해결)
6. [참고 정보](#참고-정보)

---

## 사전 준비사항

### 필수 요구사항

- ✅ **Python 3.11** 설치
- ✅ **Flutter SDK** 설치
- ✅ **Android SDK** 설치 (ADB 포함)
- ✅ **갤럭시 S22** (또는 다른 Android 기기)
- ✅ **USB 케이블**
- ✅ **같은 WiFi 네트워크** (PC와 휴대폰이 같은 네트워크에 연결)

### 프로젝트 구조 확인

```
TeamProject/
├── app/                    # Flask 백엔드
├── FrontEnd/lastlast/      # Flutter 프론트엔드
├── start_backend.ps1       # 백엔드 서버 시작 스크립트
├── wifi_debug_reconnect.ps1 # WiFi 디버깅 재연결 스크립트
└── setup_adb_alias.ps1     # ADB 별칭 설정 스크립트
```

---

## 초기 설정 (최초 1회)

### 1. ADB 별칭 설정 (선택사항)

PowerShell에서 `adb` 명령어를 바로 사용하려면:

```powershell
.\setup_adb_alias.ps1
```

이 스크립트는 PowerShell 프로필에 ADB 경로를 추가합니다.  
**참고**: PowerShell을 재시작하거나 `. $PROFILE` 명령어를 실행해야 적용됩니다.

### 2. 휴대폰 개발자 옵션 활성화

1. **설정** → **휴대전화 정보** → **소프트웨어 정보**
2. **빌드 번호**를 7번 연속 터치
3. **설정** → **개발자 옵션**으로 이동
4. **USB 디버깅** 활성화

### 3. 환경 변수 파일 확인

프로젝트 루트에 `.env` 파일이 있는지 확인:

```powershell
# .env 파일이 없으면 env.example을 복사
Copy-Item env.example .env
```

`.env` 파일 내용 확인:
```
DATABASE_URL=mysql+pymysql://root@127.0.0.1:3306/teamproject?charset=utf8mb4
```

---

## 일일 디버깅 시작하기

### Step 1: WiFi 디버깅 설정

#### 1-1. USB로 휴대폰 연결

1. USB 케이블로 갤럭시 S22를 PC에 연결
2. 휴대폰에서 **"USB 디버깅 허용"** 팝업이 나타나면 **허용** 선택
3. **"이 컴퓨터에서 항상 허용"** 체크 (선택사항)

#### 1-2. WiFi 디버깅 재연결 스크립트 실행

```powershell
.\wifi_debug_reconnect.ps1
```

**스크립트가 자동으로 수행하는 작업:**
1. ✅ PC의 IP 주소 자동 감지
2. ✅ Flutter 앱의 API 주소 자동 업데이트
3. ✅ 기존 WiFi 연결 정리
4. ✅ 휴대폰 IP 주소 입력 요청
5. ✅ USB 연결 확인 및 WiFi 디버깅 모드 전환 (`adb tcpip 5555`)
6. ✅ WiFi로 연결 (`adb connect [휴대폰IP]:5555`)

**입력 요청:**
- PC IP: 자동 감지되거나 수동 입력
- 휴대폰 IP: 휴대폰에서 확인
  - **확인 방법**: 설정 → Wi-Fi → 연결된 네트워크 클릭 → IP 주소

**성공 메시지:**
```
✅ WiFi로 연결되었습니다!
   연결 주소: 192.168.0.100:5555
```

#### 1-3. 연결 확인

```powershell
adb devices
```

다음과 같이 표시되어야 합니다:
```
List of devices attached
192.168.0.100:5555    device
```

**✅ 성공!** 이제 USB 케이블을 뽑아도 됩니다.

---

### Step 2: Flask 백엔드 서버 실행

#### 2-1. 백엔드 서버 시작

```powershell
.\start_backend.ps1
```

**스크립트가 자동으로 수행하는 작업:**
1. ✅ 가상환경 활성화 (`.venv311`)
2. ✅ PC의 IP 주소 자동 감지
3. ✅ Flutter 앱의 API 주소 자동 업데이트
4. ✅ Flask 서버 시작 (`--host 0.0.0.0`)

**출력 예시:**
```
=== 백엔드 서버 시작 ===

✅ 가상환경 활성화 완료
✅ 감지된 PC IP 주소: 192.168.0.7
✅ Flutter 앱 API 주소 업데이트 완료: http://192.168.0.7:5000

서버 시작 중...
접속 주소: http://0.0.0.0:5000
로컬 접속: http://127.0.0.1:5000
외부 접속: http://192.168.0.7:5000

 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://192.168.0.7:5000
```

**✅ 서버가 실행 중입니다!** 이 창은 열어둡니다.

---

### Step 3: Flutter 앱 실행

#### 3-1. 새 PowerShell 창 열기

백엔드 서버가 실행 중인 PowerShell 창은 그대로 두고, **새 PowerShell 창**을 엽니다.

#### 3-2. Flutter 디렉토리로 이동

```powershell
cd FrontEnd\lastlast
```

#### 3-3. 연결된 디바이스 확인

```powershell
flutter devices
```

다음과 같이 표시되어야 합니다:
```
2 connected devices:

sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
SM-S906N (mobile)           • 192.168.0.100:5555 • android-arm64  • Android 13 (API 33)
```

**참고**: `192.168.0.100:5555`가 WiFi로 연결된 휴대폰입니다.

#### 3-4. Flutter 앱 실행

```powershell
flutter run -d 192.168.0.100:5555
```

또는 디바이스 ID만 지정:
```powershell
flutter run -d 192.168.0.100:5555
```

**출력 예시:**
```
Launching lib\main.dart on SM-S906N in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app.apk...
Flutter run key commands.
```

**✅ 앱이 휴대폰에 설치되고 실행됩니다!**

---

## WiFi 네트워크 변경 시

네트워크가 바뀌면 IP 주소가 변경되므로 다음을 다시 수행해야 합니다:

### 빠른 재연결 방법

```powershell
# 1. WiFi 디버깅 재연결
.\wifi_debug_reconnect.ps1

# 2. 백엔드 서버 재시작 (기존 창에서 Ctrl+C 후)
.\start_backend.ps1

# 3. Flutter 앱 재실행 (새 터미널에서)
cd FrontEnd\lastlast
flutter run -d [새로운휴대폰IP]:5555
```

---

## 문제 해결

### ❌ 문제 1: USB 디바이스가 감지되지 않음

**증상:**
```
List of devices attached
(비어있음)
```

**해결 방법:**
1. USB 케이블 확인 (데이터 전송 가능한 케이블인지)
2. 휴대폰에서 **"USB 디버깅 허용"** 팝업 확인
3. 개발자 옵션에서 **USB 디버깅** 활성화 확인
4. USB 연결 모드 확인: **파일 전송 (MTP)** 모드로 설정

---

### ❌ 문제 2: WiFi 연결 실패

**증상:**
```
failed to connect to 192.168.0.100:5555
```

**해결 방법:**

1. **같은 WiFi 네트워크 확인**
   - PC와 휴대폰이 같은 WiFi에 연결되어 있는지 확인

2. **IP 주소 확인**
   ```powershell
   # PC IP 확인
   ipconfig
   
   # 휴대폰 IP 확인
   # 설정 → Wi-Fi → 연결된 네트워크 → IP 주소
   ```

3. **USB로 다시 연결 후 tcpip 실행**
   ```powershell
   # USB로 연결
   adb devices
   
   # WiFi 디버깅 모드로 전환
   adb tcpip 5555
   
   # WiFi로 연결
   adb connect [휴대폰IP]:5555
   ```

4. **방화벽 확인**
   - Windows 방화벽이 포트 5555를 차단하지 않는지 확인

---

### ❌ 문제 3: Flutter 앱이 서버에 연결할 수 없음

**증상:**
```
서버에 연결할 수 없습니다.
```

**해결 방법:**

1. **백엔드 서버가 실행 중인지 확인**
   - `start_backend.ps1` 스크립트가 실행 중인지 확인
   - 서버 로그에 오류가 없는지 확인

2. **API 주소 확인**
   - `FrontEnd\lastlast\lib\services\api_client.dart` 파일 확인
   - `defaultValue`가 PC의 현재 IP 주소와 일치하는지 확인
   ```dart
   defaultValue: 'http://192.168.0.7:5000',  // PC의 현재 IP
   ```

3. **IP 주소 수동 업데이트**
   - PC의 현재 IP 주소 확인: `ipconfig`
   - `api_client.dart` 파일에서 IP 주소 수정
   - Flutter 앱 재시작 (Hot Restart로는 안 됨)

4. **네트워크 연결 확인**
   - PC와 휴대폰이 같은 WiFi 네트워크에 연결되어 있는지 확인

---

### ❌ 문제 4: 백엔드 서버 시작 실패

**증상:**
```
❌ 가상환경을 찾을 수 없습니다.
또는
ModuleNotFoundError: No module named 'flask'
```

**해결 방법:**

1. **가상환경 확인**
   ```powershell
   # 가상환경이 있는지 확인
   Test-Path .\.venv311\Scripts\Activate.ps1
   ```

2. **가상환경 재생성 (필요시)**
   ```powershell
   python -m venv .venv311
   .\.venv311\Scripts\Activate.ps1
   pip install -r requirements.txt
   ```

3. **데이터베이스 연결 확인**
   - MySQL 서버가 실행 중인지 확인
   - `.env` 파일의 `DATABASE_URL` 확인

---

### ❌ 문제 5: Flutter 앱이 디바이스를 찾을 수 없음

**증상:**
```
No devices found.
```

**해결 방법:**

1. **adb devices 확인**
   ```powershell
   adb devices
   ```
   - WiFi 연결이 표시되어야 함: `192.168.0.100:5555    device`

2. **WiFi 재연결**
   ```powershell
   .\wifi_debug_reconnect.ps1
   ```

3. **Flutter 디바이스 새로고침**
   ```powershell
   flutter devices
   ```

---

## 참고 정보

### 주요 스크립트 파일

| 파일명 | 용도 |
|--------|------|
| `start_backend.ps1` | Flask 백엔드 서버 시작 |
| `wifi_debug_reconnect.ps1` | WiFi 디버깅 재연결 (네트워크 변경 시) |
| `setup_adb_alias.ps1` | ADB 별칭 설정 (최초 1회) |

### 주요 명령어

```powershell
# ADB 디바이스 확인
adb devices

# WiFi 디버깅 모드로 전환 (USB 연결 필요)
adb tcpip 5555

# WiFi로 연결
adb connect [휴대폰IP]:5555

# WiFi 연결 해제
adb disconnect [휴대폰IP]:5555

# Flutter 디바이스 확인
flutter devices

# Flutter 앱 실행
flutter run -d [디바이스ID]

# PC IP 주소 확인
ipconfig
```

### IP 주소 확인 방법

**PC:**
```powershell
ipconfig | Select-String "IPv4"
```

**휴대폰:**
- 설정 → Wi-Fi → 연결된 네트워크 클릭 → IP 주소

### 파일 위치

- **Flutter API 설정**: `FrontEnd\lastlast\lib\services\api_client.dart`
- **백엔드 환경 변수**: `.env`
- **가상환경**: `.venv311`

---

## 작업 흐름 요약

```
1. USB로 휴대폰 연결
   ↓
2. wifi_debug_reconnect.ps1 실행
   ↓
3. USB 케이블 제거
   ↓
4. start_backend.ps1 실행 (백엔드 서버)
   ↓
5. 새 터미널에서 flutter run 실행
   ↓
✅ 디버깅 시작!
```

---

## 추가 팁

### Hot Reload
Flutter 앱 실행 중:
- **`r`**: Hot Reload (빠른 변경 반영)
- **`R`**: Hot Restart (전체 재시작)
- **`q`**: 종료

### 로그 확인
- **백엔드 로그**: `start_backend.ps1` 실행한 PowerShell 창
- **프론트엔드 로그**: `flutter run` 실행한 터미널 창

### 네트워크 변경 시
네트워크가 바뀔 때마다:
1. `wifi_debug_reconnect.ps1` 실행
2. `start_backend.ps1` 재실행
3. Flutter 앱 재시작

---

## 문의사항

문제가 해결되지 않으면 다음 정보와 함께 문의하세요:
- 오류 메시지 전체
- `adb devices` 출력
- `flutter devices` 출력
- PC와 휴대폰의 IP 주소
- 네트워크 환경 (WiFi 이름 등)

---

**마지막 업데이트**: 2024년

