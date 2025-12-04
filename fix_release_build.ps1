# 릴리즈 빌드 문제 해결 스크립트
# api_client.dart의 기본값을 직접 수정하여 빌드

Write-Host "=== 릴리즈 빌드 문제 해결 ===" -ForegroundColor Cyan
Write-Host ""

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
    Write-Host "PC의 IP 주소를 자동으로 찾을 수 없습니다." -ForegroundColor Yellow
    $pcIP = Read-Host "PC의 IP 주소를 입력하세요 (예: 192.168.0.7)"
}

$apiUrl = "http://$pcIP`:5000"

Write-Host ""
Write-Host "✅ 감지된 PC IP 주소: $pcIP" -ForegroundColor Green
Write-Host "✅ 설정할 API 서버 주소: $apiUrl" -ForegroundColor Green
Write-Host ""

# api_client.dart 파일 경로
$apiClientPath = "FrontEnd\lastlast\lib\services\api_client.dart"

if (-not (Test-Path $apiClientPath)) {
    Write-Host "❌ api_client.dart 파일을 찾을 수 없습니다: $apiClientPath" -ForegroundColor Red
    exit 1
}

# 파일 백업
$backupPath = "$apiClientPath.backup"
Copy-Item $apiClientPath $backupPath -Force
Write-Host "📋 파일 백업 완료: $backupPath" -ForegroundColor Gray
Write-Host ""

# 파일 내용 읽기
$content = Get-Content $apiClientPath -Raw -Encoding UTF8

# defaultValue 패턴 찾기 및 교체
$pattern = "defaultValue:\s*'http://[^']+'"
$replacement = "defaultValue: '$apiUrl'"

if ($content -match $pattern) {
    $newContent = $content -replace $pattern, $replacement
    Set-Content -Path $apiClientPath -Value $newContent -NoNewline -Encoding UTF8
    Write-Host "✅ api_client.dart 파일 업데이트 완료" -ForegroundColor Green
    Write-Host "   변경된 주소: $apiUrl" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "⚠️  defaultValue 패턴을 찾을 수 없습니다." -ForegroundColor Yellow
    Write-Host "   수동으로 확인해주세요: $apiClientPath" -ForegroundColor Gray
    exit 1
}

# Flutter 프로젝트 디렉토리로 이동
Set-Location "FrontEnd\lastlast"

# 빌드 캐시 정리
Write-Host "🧹 빌드 캐시 정리 중..." -ForegroundColor Yellow
flutter clean
Write-Host ""

# 의존성 설치
Write-Host "📦 Flutter 의존성 설치 중..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 의존성 설치 실패" -ForegroundColor Red
    # 백업 복원
    Copy-Item $backupPath $apiClientPath -Force
    exit 1
}

Write-Host "✅ 의존성 설치 완료" -ForegroundColor Green
Write-Host ""

# 릴리즈 APK 빌드
Write-Host "🔨 릴리즈 APK 빌드 중..." -ForegroundColor Yellow
Write-Host "   서버 주소: $apiUrl (api_client.dart에 직접 설정됨)" -ForegroundColor Gray
Write-Host ""

flutter build apk --release

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
    
    Write-Host "💡 참고:" -ForegroundColor Yellow
    Write-Host "   - api_client.dart의 defaultValue가 $apiUrl 로 설정되었습니다" -ForegroundColor Gray
    Write-Host "   - 백업 파일: $backupPath" -ForegroundColor Gray
    Write-Host "   - 원래대로 되돌리려면: Copy-Item '$backupPath' '$apiClientPath' -Force" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ 빌드 실패" -ForegroundColor Red
    # 백업 복원
    Copy-Item $backupPath $apiClientPath -Force
    Write-Host "📋 파일 복원 완료" -ForegroundColor Gray
    exit 1
}

