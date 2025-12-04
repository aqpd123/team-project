# 서버 연결 테스트 스크립트
# 휴대폰에서 접근 가능한지 확인

Write-Host "=== 서버 연결 테스트 ===" -ForegroundColor Cyan
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
Write-Host "✅ 테스트할 API 주소: $apiUrl" -ForegroundColor Green
Write-Host ""

# 서버가 실행 중인지 확인 (실제 API 엔드포인트 사용)
Write-Host "1. 서버 실행 상태 확인 중..." -ForegroundColor Yellow
try {
    # 실제 API 엔드포인트로 테스트 (404는 정상이므로 연결만 확인)
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:5000/auth/login" -Method POST -Body '{}' -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "   ✅ 로컬 서버 응답: $($response.StatusCode)" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 400 -or $statusCode -eq 404) {
        # 400/404는 서버가 실행 중이라는 의미 (연결은 성공, 요청만 잘못됨)
        Write-Host "   ✅ 로컬 서버 실행 중 (응답 코드: $statusCode)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ 로컬 서버에 연결할 수 없습니다!" -ForegroundColor Red
        Write-Host "   백엔드 서버를 실행하세요: .\start_backend.ps1" -ForegroundColor Yellow
        exit 1
    }
}

# 외부 IP로 접근 가능한지 확인 (실제 API 엔드포인트 사용)
Write-Host ""
Write-Host "2. 외부 IP로 접근 가능 여부 확인 중..." -ForegroundColor Yellow
try {
    # 실제 API 엔드포인트로 테스트
    $response = Invoke-WebRequest -Uri "$apiUrl/auth/login" -Method POST -Body '{}' -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "   ✅ 외부 IP로 접근 가능: $($response.StatusCode)" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 400 -or $statusCode -eq 404) {
        # 400/404는 서버가 실행 중이고 접근 가능하다는 의미
        Write-Host "   ✅ 외부 IP로 접근 가능 (응답 코드: $statusCode)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ 외부 IP로 접근할 수 없습니다!" -ForegroundColor Red
        Write-Host "   원인: 서버가 --host 0.0.0.0 옵션으로 실행되지 않았을 수 있습니다" -ForegroundColor Yellow
        Write-Host "   해결: .\start_backend.ps1 또는 py -m flask run --host 0.0.0.0 --port 5000" -ForegroundColor Yellow
        exit 1
    }
}

# 방화벽 확인
Write-Host ""
Write-Host "3. 방화벽 규칙 확인 중..." -ForegroundColor Yellow
$firewallRule = Get-NetFirewallRule -DisplayName "Flask Server" -ErrorAction SilentlyContinue
if ($firewallRule) {
    Write-Host "   ✅ 방화벽 규칙이 설정되어 있습니다" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  방화벽 규칙이 설정되지 않았습니다" -ForegroundColor Yellow
    Write-Host "   관리자 권한으로 다음 명령어를 실행하세요:" -ForegroundColor Yellow
    Write-Host "   New-NetFirewallRule -DisplayName 'Flask Server' -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== 테스트 완료 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "📱 휴대폰에서 테스트:" -ForegroundColor Yellow
Write-Host "   1. 휴대폰 브라우저에서 다음 주소로 접속:" -ForegroundColor Gray
Write-Host "      $apiUrl" -ForegroundColor Cyan
Write-Host "   2. 접속이 되면 서버는 정상 작동 중입니다" -ForegroundColor Gray
Write-Host "   3. 접속이 안 되면:" -ForegroundColor Gray
Write-Host "      - 컴퓨터와 휴대폰이 같은 Wi-Fi에 연결되어 있는지 확인" -ForegroundColor Gray
Write-Host "      - 방화벽 설정 확인" -ForegroundColor Gray
Write-Host ""

