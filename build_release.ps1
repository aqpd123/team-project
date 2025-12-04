# 릴리즈 APK 빌드 스크립트
# 서버 주소를 자동으로 감지하여 빌드

Write-Host "=== 릴리즈 APK 빌드 ===" -ForegroundColor Cyan
Write-Host ""

# Flutter 프로젝트 디렉토리로 이동
$flutterDir = "FrontEnd\lastlast"
if (-not (Test-Path $flutterDir)) {
    Write-Host "❌ Flutter 프로젝트 디렉토리를 찾을 수 없습니다: $flutterDir" -ForegroundColor Red
    exit 1
}

Set-Location $flutterDir

# 현재 PC의 IP 주소 확인
$pcIP = $null
try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
    foreach ($adapter in $adapters) {
        $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        foreach ($ip in $ipConfig) {
            if ($ip.IPAddress -match '^192\.168\.' -or $ip.IPAddress -match '^10\.') {
                $pcIP = $ip.IPAddress
                break
            }
        }
        if ($pcIP) { break }
    }
} catch {
    Write-Host "⚠️  IP 자동 확인 실패" -ForegroundColor Yellow
}

if (-not $pcIP) {
    Write-Host ""
    Write-Host "PC의 IP 주소를 자동으로 찾을 수 없습니다." -ForegroundColor Yellow
    Write-Host "IP 주소 확인 방법: PowerShell에서 'ipconfig' 명령어 실행" -ForegroundColor Cyan
    Write-Host ""
    $pcIP = Read-Host "PC의 IP 주소를 입력하세요 (예: 192.168.0.7)"
    
    if (-not $pcIP) {
        Write-Host "❌ IP 주소를 입력하지 않았습니다. 기본값을 사용합니다." -ForegroundColor Red
        $pcIP = "192.168.0.7"
    }
}

$apiUrl = "http://$pcIP`:5000"

Write-Host ""
Write-Host "✅ 감지된 PC IP 주소: $pcIP" -ForegroundColor Green
Write-Host "✅ API 서버 주소: $apiUrl" -ForegroundColor Green
Write-Host ""

# 의존성 설치
Write-Host "📦 Flutter 의존성 설치 중..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 의존성 설치 실패" -ForegroundColor Red
    exit 1
}

Write-Host "✅ 의존성 설치 완료" -ForegroundColor Green
Write-Host ""

# 릴리즈 APK 빌드
Write-Host "🔨 릴리즈 APK 빌드 중..." -ForegroundColor Yellow
Write-Host "   서버 주소: $apiUrl" -ForegroundColor Gray
Write-Host ""

Write-Host "빌드 명령어: flutter build apk --release --dart-define=API_BASE_URL=$apiUrl" -ForegroundColor Gray
Write-Host ""

flutter build apk --release --dart-define=API_BASE_URL=$apiUrl

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ 빌드 완료!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 APK 파일 위치:" -ForegroundColor Cyan
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    Write-Host "   $apkPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔍 빌드된 APK가 사용할 서버 주소: $apiUrl" -ForegroundColor Cyan
    Write-Host ""
    
    # 자동 설치 시도
    Write-Host "📲 휴대폰에 자동 설치 시도 중..." -ForegroundColor Yellow
    Write-Host ""
    
    # 연결된 기기 확인
    $devices = adb devices 2>&1
    $deviceConnected = $false
    
    if ($devices -match "device$") {
        $deviceConnected = $true
        Write-Host "✅ 연결된 기기 발견" -ForegroundColor Green
        Write-Host ""
        
        # flutter install 사용 (더 안정적)
        Write-Host "   flutter install 실행 중..." -ForegroundColor Gray
        flutter install
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ 휴대폰에 설치 완료!" -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "⚠️  flutter install 실패, adb install 시도 중..." -ForegroundColor Yellow
            Write-Host ""
            
            # adb install으로 재시도
            $fullApkPath = (Resolve-Path $apkPath).Path
            adb install -r $fullApkPath
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "✅ 휴대폰에 설치 완료! (adb 사용)" -ForegroundColor Green
                Write-Host ""
            } else {
                Write-Host ""
                Write-Host "⚠️  자동 설치 실패. 수동으로 설치해주세요:" -ForegroundColor Yellow
                Write-Host "   $fullApkPath" -ForegroundColor Gray
                Write-Host ""
            }
        }
    } else {
        Write-Host "⚠️  연결된 기기를 찾을 수 없습니다." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   수동 설치 방법:" -ForegroundColor Gray
        Write-Host "   1. USB로 휴대폰 연결" -ForegroundColor Gray
        Write-Host "   2. USB 디버깅 활성화" -ForegroundColor Gray
        Write-Host "   3. 다음 명령어 실행: flutter install" -ForegroundColor Gray
        Write-Host "   또는 APK 파일을 휴대폰으로 전송하여 설치" -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host "⚠️  중요: 연결 오류가 발생하면 다음을 확인하세요" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   1. 백엔드 서버 실행 확인:" -ForegroundColor Gray
    Write-Host "      .\start_backend.ps1" -ForegroundColor Gray
    Write-Host "      또는" -ForegroundColor Gray
    Write-Host "      py -m flask run --host 0.0.0.0 --port 5000" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   2. 서버 연결 테스트:" -ForegroundColor Gray
    Write-Host "      .\test_server_connection.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   3. 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결되어 있는지 확인" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   4. Windows 방화벽에서 포트 5000을 허용해야 합니다" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   5. 앱 실행 시 로그에서 '🔗 API Client 초기화: 서버 주소 = ...' 확인" -ForegroundColor Gray
    Write-Host "      (adb logcat | findstr 'API Client' 또는 Flutter DevTools 사용)" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ 빌드 실패" -ForegroundColor Red
    exit 1
}

