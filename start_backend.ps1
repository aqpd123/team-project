# 백엔드 서버 시작 스크립트 (외부 접속 허용)
# WiFi 디버깅을 위해 --host 0.0.0.0 옵션 사용

Write-Host "=== 백엔드 서버 시작 ===" -ForegroundColor Cyan
Write-Host ""

# 가상환경 활성화
if (Test-Path ".\.venv311\Scripts\Activate.ps1") {
    .\.venv311\Scripts\Activate.ps1
    Write-Host "✅ 가상환경 활성화 완료" -ForegroundColor Green
} else {
    Write-Host "❌ 가상환경을 찾을 수 없습니다." -ForegroundColor Red
    exit 1
}

# Flask 앱 설정
$env:FLASK_APP = "app.main:create_app"

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

Write-Host ""
Write-Host "✅ 감지된 PC IP 주소: $pcIP" -ForegroundColor Green
Write-Host ""

# Flutter 앱의 API 주소 자동 업데이트
Write-Host "📱 Flutter 앱의 API 주소 업데이트 중..." -ForegroundColor Yellow
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
        Write-Host "✅ Flutter 앱 API 주소 업데이트 완료: $newUrl" -ForegroundColor Green
    } else {
        Write-Host "⚠️  API 주소 패턴을 찾을 수 없습니다. 수동으로 확인해주세요." -ForegroundColor Yellow
        Write-Host "   파일: $apiClientPath" -ForegroundColor Gray
        Write-Host "   설정할 주소: $newUrl" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  Flutter 앱 파일을 찾을 수 없습니다: $apiClientPath" -ForegroundColor Yellow
    Write-Host "   수동으로 API 주소를 설정해주세요: $newUrl" -ForegroundColor Gray
}

Write-Host ""
Write-Host "서버 시작 중..." -ForegroundColor Yellow
Write-Host "접속 주소: http://0.0.0.0:5000" -ForegroundColor Cyan
Write-Host "로컬 접속: http://127.0.0.1:5000" -ForegroundColor Cyan
Write-Host "외부 접속: http://$pcIP`:5000" -ForegroundColor Cyan
Write-Host ""
Write-Host "종료하려면 Ctrl+C를 누르세요" -ForegroundColor Yellow
Write-Host ""

# Flask 서버 시작 (외부 접속 허용)
py -m flask run --host 0.0.0.0 --port 5000

