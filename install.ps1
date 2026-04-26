# sendall Windows installer
# Run from inside the cloned repo:
#   Right-click install.ps1 -> Run with PowerShell
# Or from PowerShell terminal:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\install.ps1

$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "sendall installer" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "────────────────────────────────"

# ── Check Python ──────────────────────────────────────────────────────────────
$python = $null
foreach ($cmd in @("python", "python3", "py")) {
    try {
        $ver = & $cmd --version 2>&1
        if ($ver -match "Python 3") { $python = $cmd; break }
    } catch {}
}

if (-not $python) {
    Write-Host "Python 3 not found." -ForegroundColor Yellow
    Write-Host "Please install it from https://python.org then re-run this script."
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Python 3    : OK" -ForegroundColor Green

# ── Copy sendall to a permanent location ─────────────────────────────────────
$installDir  = "$env:USERPROFILE\.sendall"
$sendallSrc  = Join-Path $RepoDir "sendall"
$sendallDest = Join-Path $installDir "sendall.py"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Copy-Item $sendallSrc $sendallDest -Force

# ── Create sendall.cmd wrapper so it works from any terminal ─────────────────
$cmdWrapper = Join-Path $installDir "sendall.cmd"
Set-Content $cmdWrapper "@echo off`r`n$python `"$sendallDest`" %*"

# Add to user PATH if not already there
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$userPath;$installDir", "User")
    Write-Host "Added to PATH. Please restart your terminal after install." -ForegroundColor Yellow
}
Write-Host "sendall bin : OK" -ForegroundColor Green

# ── Enable receiving by default ───────────────────────────────────────────────
New-Item -ItemType File -Force -Path "$env:USERPROFILE\.sendall_enabled" | Out-Null

# ── Register as a Task Scheduler task (auto-starts on login) ─────────────────
$taskName   = "sendall-listener"
$action     = New-ScheduledTaskAction -Execute $python -Argument "`"$sendallDest`" --listen"
$trigger    = New-ScheduledTaskTrigger -AtLogOn
$settings   = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1)
$principal  = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

# Remove existing task if present
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
    -Settings $settings -Principal $principal -Force | Out-Null

# Start it now
Start-ScheduledTask -TaskName $taskName
Write-Host "Task        : registered and started" -ForegroundColor Green

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "sendall installed!" -ForegroundColor Green
Write-Host ""
Write-Host "  Send a message:   sendall 192.168.1.42 Hey, lunch is ready!"
Write-Host "  Stop receiving:   sendall --stop"
Write-Host "  Start receiving:  sendall --start"
Write-Host "  Check status:     sendall --status"
Write-Host ""
Write-Host "  Receiving is ON by default."
Write-Host ""
Read-Host "Press Enter to close"
