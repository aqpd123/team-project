# WiFi 디버깅 재연결 스크립트 (WiFi 변경 시 사용)
# WiFi가 바뀐 경우 이 스크립트를 실행하세요

Write-Host "=== WiFi 디버깅 재연결 ===" -ForegroundColor Cyan
Write-Host ""

# ADB 경로 설정
$env:Path += ";C:\Users\user\AppData\Local\Android\sdk\platform-tools"
$adbPath = "C:\Users\user\AppData\Local\Android\sdk\platform-tools\adb.exe"

# 1. PC의 현재 IP 주소 확인
Write-Host "1️⃣ PC의 현재 IP 주소 확인 중..." -ForegroundColor Yellow
$pcIP = $null

# 여러 방법으로 IP 주소 확인 시도
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
    Write-Host "   PowerShell 명령어로 IP 확인 실패, 수동 입력으로 전환" -ForegroundColor Yellow
}

if (-not $pcIP) {
    Write-Host ""
    Write-Host "PC의 IP 주소를 자동으로 찾을 수 없습니다." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "IP 주소 확인 방법:" -ForegroundColor Cyan
    Write-Host "  1. PowerShell에서: ipconfig" -ForegroundColor White
    Write-Host "  2. 설정 → 네트워크 및 인터넷 → 이더넷/Wi-Fi → 속성" -ForegroundColor White
    Write-Host ""
    $pcIP = Read-Host "PC의 IP 주소를 입력하세요 (예: 192.168.0.7)"
}

if (-not $pcIP) {
    Write-Host "❌ IP 주소를 입력하지 않았습니다." -ForegroundColor Red
    exit 1
}

Write-Host "✅ PC의 IP 주소: $pcIP" -ForegroundColor Green
Write-Host ""

# 2. Flutter 앱의 API_BASE_URL 업데이트
Write-Host "2️⃣ Flutter 앱의 API 주소 업데이트 중..." -ForegroundColor Yellow
$apiClientPath = "FrontEnd\lastlast\lib\services\api_client.dart"

if (Test-Path $apiClientPath) {
    $content = Get-Content $apiClientPath -Raw -Encoding UTF8
    $newUrl = "http://$pcIP`:5000"
    
    # defaultValue를 새 IP로 업데이트
    $pattern = "defaultValue:\s*'http://[^']+'"
    $replacement = "defaultValue: '$newUrl'"
    
    if ($content -match $pattern) {
        $newContent = $content -replace $pattern, $replacement
        Set-Content -Path $apiClientPath -Value $newContent -NoNewline -Encoding UTF8
        Write-Host "✅ API 주소가 업데이트되었습니다: $newUrl" -ForegroundColor Green
    } else {
        Write-Host "⚠️  API 주소 패턴을 찾을 수 없습니다. 수동으로 확인해주세요." -ForegroundColor Yellow
        Write-Host "   파일: $apiClientPath" -ForegroundColor Gray
        Write-Host "   설정할 주소: $newUrl" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  API 클라이언트 파일을 찾을 수 없습니다: $apiClientPath" -ForegroundColor Yellow
    Write-Host "   수동으로 API 주소를 설정해주세요: $newUrl" -ForegroundColor Gray
}

Write-Host ""

# 3. 기존 adb 연결 확인 및 정리
Write-Host "3️⃣ 기존 adb 연결 확인 중..." -ForegroundColor Yellow
$devices = & $adbPath devices
$wifiDevices = $devices | Select-String -Pattern ":\d+"

if ($wifiDevices) {
    Write-Host "   기존 WiFi 연결 발견, 연결 해제 중..." -ForegroundColor Gray
    foreach ($device in $wifiDevices) {
        $deviceId = ($device -split '\s+')[0]
        if ($deviceId -match ':\d+') {
            & $adbPath disconnect $deviceId | Out-Null
        }
    }
}

Write-Host ""

# 4. 휴대폰의 IP 주소 입력 요청
Write-Host "4️⃣ 갤럭시 S22의 IP 주소를 입력하세요" -ForegroundColor Yellow
Write-Host ""
Write-Host "IP 주소 확인 방법:" -ForegroundColor Cyan
Write-Host "  설정 → Wi-Fi → 연결된 네트워크 클릭 → IP 주소 확인" -ForegroundColor White
Write-Host ""
$phoneIP = Read-Host "휴대폰의 IP 주소 입력 (예: 192.168.0.100)"

if (-not $phoneIP) {
    Write-Host "❌ IP 주소를 입력하지 않았습니다." -ForegroundColor Red
    exit 1
}

# 5. USB로 연결되어 있는지 확인
Write-Host ""
Write-Host "5️⃣ USB 연결 확인 중..." -ForegroundColor Yellow
$allDevices = & $adbPath devices
$usbDevices = $allDevices | Select-String -Pattern "device$" | Where-Object { $_ -notmatch "emulator" -and $_ -notmatch ":\d+" }

if (-not $usbDevices) {
    Write-Host "⚠️  USB로 연결된 디바이스가 없습니다." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "다음을 수행하세요:" -ForegroundColor Cyan
    Write-Host "  1. USB 케이블로 갤럭시 S22를 PC에 연결" -ForegroundColor White
    Write-Host "  2. 휴대폰에서 'USB 디버깅 허용' 팝업 확인" -ForegroundColor White
    Write-Host "  3. 설정 → 개발자 옵션 → USB 디버깅 활성화 확인" -ForegroundColor White
    Write-Host ""
    Write-Host "현재 연결된 디바이스:" -ForegroundColor Gray
    Write-Host $allDevices
    Write-Host ""
    $continue = Read-Host "USB 연결 후 계속하시겠습니까? (y/n)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        Write-Host "❌ 스크립트를 종료합니다." -ForegroundColor Red
        exit 1
    }
    
    # 다시 확인
    $allDevices = & $adbPath devices
    $usbDevices = $allDevices | Select-String -Pattern "device$" | Where-Object { $_ -notmatch "emulator" -and $_ -notmatch ":\d+" }
    
    if (-not $usbDevices) {
        Write-Host "❌ 여전히 USB로 연결된 디바이스가 없습니다." -ForegroundColor Red
        Write-Host "   USB 연결을 확인하고 다시 시도하세요." -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "✅ USB로 연결된 디바이스 발견" -ForegroundColor Green
$deviceId = ($usbDevices -split '\s+')[0]
Write-Host "   디바이스 ID: $deviceId" -ForegroundColor Gray

# WiFi 디버깅 모드로 전환
Write-Host ""
Write-Host "6️⃣ WiFi 디버깅 모드로 전환 중..." -ForegroundColor Yellow
Write-Host "   명령어: adb tcpip 5555" -ForegroundColor Gray

# 여러 디바이스가 있는 경우 특정 디바이스 지정
if ($deviceId) {
    $result = & $adbPath -s $deviceId tcpip 5555 2>&1
} else {
    $result = & $adbPath tcpip 5555 2>&1
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ WiFi 디버깅 모드로 전환되었습니다!" -ForegroundColor Green
    Write-Host "   포트: 5555" -ForegroundColor Gray
} else {
    Write-Host "⚠️  WiFi 디버깅 모드 전환 실패: $result" -ForegroundColor Yellow
    Write-Host "   계속 진행합니다..." -ForegroundColor Gray
}

Write-Host ""

# 6. WiFi로 연결
Write-Host "7️⃣ WiFi로 연결 중..." -ForegroundColor Yellow
$connectResult = & $adbPath connect "$phoneIP`:5555" 2>&1

if ($LASTEXITCODE -eq 0 -or $connectResult -match "connected") {
    Write-Host "✅ WiFi로 연결되었습니다!" -ForegroundColor Green
    Write-Host "   연결 주소: $phoneIP`:5555" -ForegroundColor Gray
} else {
    Write-Host "❌ 연결 실패: $connectResult" -ForegroundColor Red
    Write-Host ""
    Write-Host "다음을 확인하세요:" -ForegroundColor Yellow
    Write-Host "  1. PC와 휴대폰이 같은 WiFi 네트워크에 연결되어 있는지" -ForegroundColor White
    Write-Host "  2. IP 주소가 올바른지" -ForegroundColor White
    Write-Host "  3. 방화벽이 포트 5555를 차단하지 않는지" -ForegroundColor White
    Write-Host "  4. USB로 연결 후 'adb tcpip 5555'를 다시 실행했는지" -ForegroundColor White
    exit 1
}

Write-Host ""

# 7. 연결 확인
Write-Host "8️⃣ 연결 확인 중..." -ForegroundColor Yellow
$finalDevices = & $adbPath devices
Write-Host $finalDevices

Write-Host ""
Write-Host "🎉 WiFi 디버깅 재연결 완료!" -ForegroundColor Green
Write-Host ""
Write-Host "설정 요약:" -ForegroundColor Cyan
Write-Host "  PC IP: $pcIP" -ForegroundColor White
Write-Host "  휴대폰 IP: $phoneIP" -ForegroundColor White
Write-Host "  API 주소: http://$pcIP`:5000" -ForegroundColor White
Write-Host ""
Write-Host "이제 USB 케이블을 뽑아도 됩니다!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Flutter 앱 실행:" -ForegroundColor Yellow
Write-Host "  cd FrontEnd\lastlast" -ForegroundColor White
Write-Host "  flutter run -d $phoneIP`:5555" -ForegroundColor White
Write-Host ""

