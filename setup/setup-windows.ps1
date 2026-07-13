# E3 Hackathon -- Windows machine setup
#
# Installs everything a participant machine needs: Git (incl. Git Bash),
# GitHub CLI, Node.js LTS, opencode, and Netlify CLI. Idempotent -- safe to
# re-run; a second run acts as a verification pass.
#
# Run from a regular (non-admin) PowerShell:
#   powershell -ExecutionPolicy Bypass -File setup-windows.ps1
#
# Optionally pass the participant's identity to skip the prompts:
#   powershell -ExecutionPolicy Bypass -File setup-windows.ps1 -GitName "Asha M" -GitEmail "asha@example.com"
#
# Note: opencode's docs recommend WSL on Windows, but native install is
# supported and avoids virtualization/BIOS/reboot variables on student-owned
# laptops. Our stack (plain HTML/CSS/JS + git + gh + netlify) works natively.
# Instructors may use WSL on machines they control if they prefer.

#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$GitName,
    [string]$GitEmail
)

$ErrorActionPreference = "Stop"

function Test-Tool([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Host ""
Write-Host "=== E3 Hackathon setup ===" -ForegroundColor Cyan

# --- 0. winget is required ---------------------------------------------------
if (-not (Test-Tool "winget")) {
    Write-Host "winget is not available on this machine." -ForegroundColor Red
    Write-Host "Install 'App Installer' from the Microsoft Store (requires Windows 10 1809+), then re-run this script."
    exit 1
}

# --- 1. Base tools via winget ------------------------------------------------
$packages = @(
    @{ Id = "Git.Git";           Tool = "git";  Label = "Git (includes Git Bash)" },
    @{ Id = "GitHub.cli";        Tool = "gh";   Label = "GitHub CLI" },
    @{ Id = "OpenJS.NodeJS.LTS"; Tool = "node"; Label = "Node.js LTS" }
)

# --source winget: the msstore source uses certificate pinning, which fails on
# networks with SSL inspection (school/institutional proxies). We don't need it.
foreach ($p in $packages) {
    if (Test-Tool $p.Tool) {
        Write-Host "[ok] $($p.Label) already installed" -ForegroundColor Green
    } else {
        Write-Host "[..] Installing $($p.Label)..." -ForegroundColor Yellow
        winget install --id $p.Id -e --source winget --silent --accept-package-agreements --accept-source-agreements
        Refresh-Path
        if (-not (Test-Tool $p.Tool)) {
            Write-Host "[!!] $($p.Label) installed but '$($p.Tool)' not on PATH yet -- close this window, open a NEW PowerShell, and re-run the script." -ForegroundColor Red
            exit 1
        }
        Write-Host "[ok] $($p.Label) installed" -ForegroundColor Green
    }
}

# --- 2. npm tools: opencode + netlify -----------------------------------------
foreach ($t in @(
    @{ Pkg = "opencode-ai";  Tool = "opencode"; Label = "opencode" },
    @{ Pkg = "netlify-cli";  Tool = "netlify";  Label = "Netlify CLI" }
)) {
    if (Test-Tool $t.Tool) {
        Write-Host "[ok] $($t.Label) already installed" -ForegroundColor Green
    } else {
        Write-Host "[..] Installing $($t.Label) (npm)..." -ForegroundColor Yellow
        npm install -g $t.Pkg
        Refresh-Path
        Write-Host "[ok] $($t.Label) installed" -ForegroundColor Green
    }
}

# --- 3. Git identity + defaults ------------------------------------------------
if (-not $GitName)  { $GitName  = git config --global user.name }
if (-not $GitName)  { $GitName  = Read-Host "Participant's name (shown on their checkpoints)" }
if (-not $GitEmail) { $GitEmail = git config --global user.email }
if (-not $GitEmail) { $GitEmail = Read-Host "Participant's email (same as their GitHub account)" }

git config --global user.name  "$GitName"
git config --global user.email "$GitEmail"
git config --global init.defaultBranch main
git config --global core.autocrlf true
Write-Host "[ok] Git identity: $GitName <$GitEmail>" -ForegroundColor Green

# --- 4. Verification summary ----------------------------------------------------
Write-Host ""
Write-Host "=== Verification ===" -ForegroundColor Cyan
$allOk = $true
foreach ($tool in @("git", "gh", "node", "npm", "opencode", "netlify")) {
    if (Test-Tool $tool) {
        $version = (& $tool --version 2>&1 | Select-Object -First 1)
        Write-Host ("[ok] {0,-9} {1}" -f $tool, $version) -ForegroundColor Green
    } else {
        Write-Host ("[!!] {0,-9} MISSING" -f $tool) -ForegroundColor Red
        $allOk = $false
    }
}

# --- 5. Manual steps (interactive logins -- can't be scripted) --------------------
Write-Host ""
Write-Host "=== Remaining manual steps (instructor, per machine) ===" -ForegroundColor Cyan
Write-Host "  1. gh auth login        (GitHub.com > HTTPS > login with browser, as the participant)"
Write-Host "  2. opencode auth login  (paste the instructor-held API key for this team)"
Write-Host "  3. netlify login        (team Netlify account -- needed for Day 4 /publish)"
Write-Host "  4. Create the team's project folder from the E3 starter template"
Write-Host ""
if ($allOk) {
    Write-Host "Machine ready (pending manual logins above)." -ForegroundColor Green
} else {
    Write-Host "Some tools are missing -- fix the [!!] lines above and re-run." -ForegroundColor Red
    exit 1
}
