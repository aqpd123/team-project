# 릴리즈 APK 문제 진단 스크립트

Write-Host "=== 릴리즈 APK 문제 진단 ===" -ForegroundColor Cyan
Write-Host ""

# 1. 연결된 기기 확인
Write-Host "1. 연결된 기기 확인 중..." -ForegroundColor Yellow
$devices = adb devices 2>&1
if ($devices -match "device$") {
    Write-Host "   ✅ 기기 연결됨" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "   ❌ 연결된 기기가 없습니다" -ForegroundColor Red
    Write-Host "   USB로 휴대폰을 연결하고 USB 디버깅을 활성화하세요" -ForegroundColor Yellow
    exit 1
}

# 2. 현재 PC IP 주소 확인
Write-Host "2. PC IP 주소 확인 중..." -ForegroundColor Yellow
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
    Write-Host "   ⚠️  IP 자동 확인 실패" -ForegroundColor Yellow
}

if ($pcIP) {
    Write-Host "   ✅ PC IP 주소: $pcIP" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "   ❌ IP 주소를 찾을 수 없습니다" -ForegroundColor Red
    exit 1
}

# 3. api_client.dart의 설정 확인
Write-Host "3. api_client.dart 설정 확인 중..." -ForegroundColor Yellow
$apiClientPath = "FrontEnd\lastlast\lib\services\api_client.dart"
if (Test-Path $apiClientPath) {
    $content = Get-Content $apiClientPath -Raw
    if ($content -match "defaultValue:\s*'([^']+)'") {
        $configuredUrl = $matches[1]
        Write-Host "   ✅ 설정된 서버 주소: $configuredUrl" -ForegroundColor Green
        
        if ($configuredUrl -ne "http://$pcIP`:5000") {
            Write-Host "   ⚠️  경고: 설정된 주소가 현재 PC IP와 다릅니다!" -ForegroundColor Yellow
            Write-Host "   현재 PC IP: $pcIP" -ForegroundColor Gray
            Write-Host "   설정된 주소: $configuredUrl" -ForegroundColor Gray
            Write-Host ""
            Write-Host "   해결: .\fix_release_build.ps1 실행" -ForegroundColor Yellow
        }
        Write-Host ""
    } else {
        Write-Host "   ⚠️  defaultValue를 찾을 수 없습니다" -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Host "   ❌ api_client.dart 파일을 찾을 수 없습니다" -ForegroundColor Red
    Write-Host ""
}

# 4. 백엔드 서버 실행 확인
Write-Host "4. 백엔드 서버 실행 확인 중..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:5000/auth/login" -Method POST -Body '{}' -ContentType "application/json" -TimeoutSec 3 -ErrorAction Stop
    Write-Host "   ✅ 서버 실행 중 (응답 코드: $($response.StatusCode))" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 400 -or $statusCode -eq 404) {
        Write-Host "   ✅ 서버 실행 중 (응답 코드: $statusCode)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ 서버가 실행되지 않았습니다!" -ForegroundColor Red
        Write-Host "   해결: .\start_backend.ps1 실행" -ForegroundColor Yellow
    }
}
Write-Host ""

# 5. 앱 로그 확인 (API Client 초기화 메시지)
Write-Host "5. 앱 로그 확인 중..." -ForegroundColor Yellow
Write-Host "   'API Client' 또는 '서버 주소' 검색 중..." -ForegroundColor Gray
Write-Host ""

# flutter logs 사용 시도
try {
    $flutterLogs = flutter logs 2>&1 | Select-String -Pattern "API Client|서버 주소" | Select-Object -Last 5
    if ($flutterLogs) {
        Write-Host "   발견된 로그 (flutter logs):" -ForegroundColor Cyan
        $flutterLogs | ForEach-Object {
            Write-Host "   $_" -ForegroundColor Gray
        }
        Write-Host ""
        
        # 서버 주소 추출
        $urlMatch = $flutterLogs | Select-String -Pattern "http://[^\s]+"
        if ($urlMatch) {
            $usedUrl = ($urlMatch.Matches[0].Value)
            Write-Host "   🔍 앱이 사용하는 서버 주소: $usedUrl" -ForegroundColor Cyan
            Write-Host ""
            
            if ($usedUrl -ne "http://$pcIP`:5000") {
                Write-Host "   ❌ 문제 발견: 앱이 잘못된 서버 주소를 사용하고 있습니다!" -ForegroundColor Red
                Write-Host "   현재 PC IP: $pcIP" -ForegroundColor Gray
                Write-Host "   앱이 사용하는 주소: $usedUrl" -ForegroundColor Gray
                Write-Host ""
                Write-Host "   해결 방법:" -ForegroundColor Yellow
                Write-Host "   1. .\fix_release_build.ps1 실행" -ForegroundColor Gray
                Write-Host "   2. 앱 완전 삭제 후 재설치" -ForegroundColor Gray
            } else {
                Write-Host "   ✅ 앱이 올바른 서버 주소를 사용하고 있습니다" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "   ⚠️  관련 로그를 찾을 수 없습니다" -ForegroundColor Yellow
        Write-Host "   앱을 실행한 후 다음 명령어로 확인하세요:" -ForegroundColor Gray
        Write-Host "   flutter logs | findstr 'API Client'" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠️  로그 확인 실패" -ForegroundColor Yellow
    Write-Host "   수동으로 확인하세요:" -ForegroundColor Gray
    Write-Host "   flutter logs | findstr 'API Client'" -ForegroundColor Gray
}
Write-Host ""

# 6. 실시간 로그 모니터링 안내
Write-Host "6. 실시간 로그 모니터링 방법:" -ForegroundColor Yellow
Write-Host "   adb logcat | findstr 'API Client'" -ForegroundColor Gray
Write-Host "   또는" -ForegroundColor Gray
Write-Host "   adb logcat | findstr '서버 주소'" -ForegroundColor Gray
Write-Host ""

# 7. 종합 진단 결과
Write-Host "=== 진단 완료 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "다음 단계:" -ForegroundColor Yellow
Write-Host "1. 백엔드 서버 실행: .\start_backend.ps1" -ForegroundColor Gray
Write-Host "2. 서버 주소 재설정: .\fix_release_build.ps1" -ForegroundColor Gray
Write-Host "3. 앱 완전 삭제 후 재설치" -ForegroundColor Gray
Write-Host "4. 앱 실행 후 로그 확인: adb logcat | findstr 'API Client'" -ForegroundColor Gray
Write-Host ""

