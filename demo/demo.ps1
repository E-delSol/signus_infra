# Signus Demo Launcher for Windows
# Requires Git for Windows (Git Bash)
#
# Usage: .\demo\demo.ps1

$gitBash = "C:\Program Files\Git\bin\bash.exe"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Test-Path $gitBash)) {
    Write-Host "ERROR: Git Bash not found at $gitBash" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install Git for Windows:" -ForegroundColor Yellow
    Write-Host "  https://git-scm.com/download/win"
    Write-Host ""
    Write-Host "After install, re-run this script." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         SIGNUS DEMO LAUNCHER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Launching via Git Bash..." -ForegroundColor Gray
Write-Host ""

& $gitBash "$scriptDir/demo.sh"
