# WiFi 디버깅 설정 스크립트
# 갤럭시 S22를 USB로 연결한 후 이 스크립트를 실행하세요

Write-Host "=== WiFi 디버깅 설정 ===" -ForegroundColor Cyan
Write-Host ""

# ADB 경로 설정
$env:Path += ";C:\Users\user\AppData\Local\Android\sdk\platform-tools"
$adbPath = "C:\Users\user\AppData\Local\Android\sdk\platform-tools\adb.exe"

# 1. 연결된 디바이스 확인
Write-Host "1️⃣ 연결된 디바이스 확인 중..." -ForegroundColor Yellow
$devices = & $adbPath devices
Write-Host $devices

$physicalDevice = $devices | Select-String -Pattern "device$" | Where-Object { $_ -notmatch "emulator" }

if (-not $physicalDevice) {
    Write-Host ""
    Write-Host "❌ 갤럭시 S22가 연결되지 않았습니다!" -ForegroundColor Red
    Write-Host ""
    Write-Host "다음을 확인하세요:" -ForegroundColor Yellow
    Write-Host "  1. USB 케이블로 갤럭시 S22를 PC에 연결" -ForegroundColor White
    Write-Host "  2. 휴대폰에서 'USB 디버깅 허용' 팝업 확인" -ForegroundColor White
    Write-Host "  3. 설정 → 개발자 옵션 → USB 디버깅 활성화" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✅ 갤럭시 S22가 연결되었습니다!" -ForegroundColor Green
Write-Host ""

# 2. WiFi 디버깅 모드로 전환
Write-Host "2️⃣ WiFi 디버깅 모드로 전환 중..." -ForegroundColor Yellow
$result = & $adbPath tcpip 5555 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ WiFi 디버깅 모드로 전환되었습니다!" -ForegroundColor Green
    Write-Host "   포트: 5555" -ForegroundColor Gray
} else {
    Write-Host "❌ 오류 발생: $result" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 3. IP 주소 입력 요청
Write-Host "3️⃣ 갤럭시 S22의 IP 주소를 입력하세요" -ForegroundColor Yellow
Write-Host ""
Write-Host "IP 주소 확인 방법:" -ForegroundColor Cyan
Write-Host "   설정 → Wi-Fi → 연결된 네트워크 클릭 → IP 주소 확인" -ForegroundColor White
Write-Host ""
$ipAddress = Read-Host "IP 주소 입력 (예: 192.168.0.100)"

if (-not $ipAddress) {
    Write-Host "❌ IP 주소를 입력하지 않았습니다." -ForegroundColor Red
    exit 1
}

# 4. WiFi로 연결
Write-Host ""
Write-Host "4️⃣ WiFi로 연결 중..." -ForegroundColor Yellow
$connectResult = & $adbPath connect "$ipAddress`:5555" 2>&1

if ($LASTEXITCODE -eq 0 -or $connectResult -match "connected") {
    Write-Host "✅ WiFi로 연결되었습니다!" -ForegroundColor Green
    Write-Host "   연결 주소: $ipAddress`:5555" -ForegroundColor Gray
} else {
    Write-Host "❌ 연결 실패: $connectResult" -ForegroundColor Red
    Write-Host ""
    Write-Host "다음을 확인하세요:" -ForegroundColor Yellow
    Write-Host "  1. PC와 휴대폰이 같은 WiFi 네트워크에 연결되어 있는지" -ForegroundColor White
    Write-Host "  2. IP 주소가 올바른지" -ForegroundColor White
    Write-Host "  3. 방화벽이 포트 5555를 차단하지 않는지" -ForegroundColor White
    exit 1
}

Write-Host ""

# 5. 연결 확인
Write-Host "5️⃣ 연결 확인 중..." -ForegroundColor Yellow
$finalDevices = & $adbPath devices
Write-Host $finalDevices

Write-Host ""
Write-Host "🎉 WiFi 디버깅 설정 완료!" -ForegroundColor Green
Write-Host ""
Write-Host "이제 USB 케이블을 뽑아도 됩니다!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Flutter에서 확인:" -ForegroundColor Yellow
Write-Host "  cd FrontEnd\lastlast" -ForegroundColor White
Write-Host "  flutter devices" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""

