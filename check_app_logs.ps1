# 앱 로그 확인 스크립트 (Flutter lock 문제 해결)

Write-Host "=== 앱 로그 확인 ===" -ForegroundColor Cyan
Write-Host ""

# 방법 1: Flutter devices로 연결 확인
Write-Host "1. 연결된 기기 확인 중..." -ForegroundColor Yellow
$devices = flutter devices 2>&1

if ($devices -match "device") {
    Write-Host "   ✅ 기기 연결됨" -ForegroundColor Green
    Write-Host ""
    
    # 방법 2: adb logcat 직접 사용 (Flutter lock 문제 회피)
    Write-Host "2. ADB 로그 확인 중 (API Client 관련)..." -ForegroundColor Yellow
    Write-Host "   'API Client' 또는 '서버 주소' 검색 중..." -ForegroundColor Gray
    Write-Host ""
    Write-Host "   최근 로그 (최대 20줄):" -ForegroundColor Cyan
    Write-Host "   " -NoNewline
    
    # adb logcat으로 직접 확인 (Flutter lock 문제 없음)
    $logOutput = adb logcat -d -t 100 2>&1 | Select-String -Pattern "API Client|서버 주소|defaultApiBaseUrl|DioError|Connection" | Select-Object -Last 20
    
    if ($logOutput) {
        $logOutput | ForEach-Object {
            Write-Host "   $_" -ForegroundColor Gray
        }
        Write-Host ""
        
        # 서버 주소 추출
        $urlMatch = $logOutput | Select-String -Pattern "http://[^\s]+"
        if ($urlMatch) {
            $usedUrl = ($urlMatch.Matches[0].Value)
            Write-Host "   🔍 발견된 서버 주소: $usedUrl" -ForegroundColor Cyan
            Write-Host ""
        }
    } else {
        Write-Host "   ⚠️  관련 로그를 찾을 수 없습니다" -ForegroundColor Yellow
        Write-Host "   앱을 실행한 후 다시 확인하세요" -ForegroundColor Gray
    }
    Write-Host ""
    
    # 실시간 로그 모니터링 안내
    Write-Host "3. 실시간 로그 모니터링 방법:" -ForegroundColor Yellow
    Write-Host "   adb logcat | findstr 'API Client'" -ForegroundColor Gray
    Write-Host "   (Ctrl+C로 종료)" -ForegroundColor Gray
    Write-Host ""
    
} else {
    Write-Host "   ❌ 연결된 기기를 찾을 수 없습니다" -ForegroundColor Red
    Write-Host ""
    Write-Host "   해결 방법:" -ForegroundColor Yellow
    Write-Host "   1. USB로 휴대폰 연결" -ForegroundColor Gray
    Write-Host "   2. USB 디버깅 활성화" -ForegroundColor Gray
    Write-Host "   3. flutter devices 명령어로 확인" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "=== 완료 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 팁:" -ForegroundColor Yellow
Write-Host "   - Flutter lock 오류가 발생하면: .\fix_flutter_lock.ps1 실행" -ForegroundColor Gray
Write-Host "   - 실시간 로그: adb logcat | findstr 'API Client'" -ForegroundColor Gray
Write-Host ""

