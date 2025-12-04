# Flutter lock 파일 해제 스크립트

Write-Host "=== Flutter Lock 파일 해제 ===" -ForegroundColor Cyan
Write-Host ""

# Flutter lock 파일 위치
$lockPath = "$env:LOCALAPPDATA\Pub\Cache\lock"

Write-Host "1. Flutter 프로세스 종료 시도 중..." -ForegroundColor Yellow
try {
    # Flutter 관련 프로세스 종료
    Get-Process | Where-Object { $_.ProcessName -like "*flutter*" -or $_.ProcessName -like "*dart*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Flutter 프로세스 종료 완료" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Flutter 프로세스가 실행 중이지 않거나 종료할 수 없습니다" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "2. Lock 파일 삭제 시도 중..." -ForegroundColor Yellow
if (Test-Path $lockPath) {
    try {
        Remove-Item $lockPath -Force -ErrorAction Stop
        Write-Host "   ✅ Lock 파일 삭제 완료: $lockPath" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Lock 파일 삭제 실패: $_" -ForegroundColor Red
        Write-Host "   수동으로 삭제하세요: $lockPath" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ℹ️  Lock 파일이 없습니다" -ForegroundColor Gray
}
Write-Host ""

Write-Host "3. Flutter 프로젝트 lock 파일 확인 중..." -ForegroundColor Yellow
$projectLockPath = "FrontEnd\lastlast\.dart_tool\package_config_subset"
if (Test-Path $projectLockPath) {
    Write-Host "   ℹ️  프로젝트 lock 파일 발견: $projectLockPath" -ForegroundColor Gray
    Write-Host "   (일반적으로 문제가 되지 않습니다)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "✅ 완료!" -ForegroundColor Green
Write-Host ""
Write-Host "이제 다음 명령어를 다시 시도하세요:" -ForegroundColor Yellow
Write-Host "   flutter logs" -ForegroundColor Gray
Write-Host "   또는" -ForegroundColor Gray
Write-Host "   flutter devices" -ForegroundColor Gray
Write-Host ""

