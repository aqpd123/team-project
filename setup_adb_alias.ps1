# ADB 별칭 설정 스크립트
# 이 스크립트를 실행하면 PowerShell에서 'adb' 명령어를 바로 사용할 수 있습니다.

$adbPath = "C:\Users\user\AppData\Local\Android\sdk\platform-tools\adb.exe"
$profilePath = $PROFILE

# PowerShell 프로필이 없으면 생성
if (-not (Test-Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
    Write-Host "✅ PowerShell 프로필을 생성했습니다: $profilePath" -ForegroundColor Green
}

# ADB 경로가 이미 추가되어 있는지 확인
$profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue
$adbAliasExists = $profileContent | Select-String -Pattern "Set-Alias.*adb" -Quiet
$adbPathExists = $profileContent | Select-String -Pattern "platform-tools" -Quiet

if (-not $adbAliasExists -and -not $adbPathExists) {
    # 프로필에 ADB 설정 추가
    Add-Content -Path $profilePath -Value ""
    Add-Content -Path $profilePath -Value "# ADB (Android Debug Bridge) 설정"
    Add-Content -Path $profilePath -Value "`$env:Path += `";C:\Users\user\AppData\Local\Android\sdk\platform-tools`""
    Add-Content -Path $profilePath -Value "Set-Alias -Name adb -Value `"$adbPath`""
    
    Write-Host "✅ ADB 별칭을 PowerShell 프로필에 추가했습니다!" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  PowerShell을 재시작하거나 다음 명령어를 실행하세요:" -ForegroundColor Yellow
    Write-Host "   . `$PROFILE" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "ℹ️  ADB 별칭이 이미 설정되어 있습니다." -ForegroundColor Blue
}

# 현재 세션에 즉시 적용
$env:Path += ";C:\Users\user\AppData\Local\Android\sdk\platform-tools"
Set-Alias -Name adb -Value $adbPath -Scope Global -Force

Write-Host ""
Write-Host "✅ 현재 세션에서 'adb' 명령어를 사용할 수 있습니다!" -ForegroundColor Green
Write-Host ""
Write-Host "테스트: adb version" -ForegroundColor Cyan

