# E3 Hackathon — create a fresh team project folder from the starter template.
#
# Copies starter/ (commands, plugins, AGENTS.md, welcome page) into a new
# folder with NO git history — the team's own /setup command initializes git
# and publishes to the E3 org from inside opencode.
#
# Usage (from anywhere inside the cloned e3-hackathon repo):
#   powershell -ExecutionPolicy Bypass -File setup\new-project.ps1 -Name mama-lishe-orders
#   powershell -ExecutionPolicy Bypass -File setup\new-project.ps1 -Name mama-lishe-orders -Dest D:\projects

#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Name,
    [string]$Dest = (Join-Path $HOME "Desktop")
)

$ErrorActionPreference = "Stop"

$source = Join-Path $PSScriptRoot "..\starter"
$target = Join-Path $Dest $Name

if (-not (Test-Path $source)) {
    Write-Host "Cannot find the starter template at $source — run this from the cloned e3-hackathon repo." -ForegroundColor Red
    exit 1
}
if (Test-Path $target) {
    Write-Host "$target already exists — pick another name or move the old folder first." -ForegroundColor Red
    exit 1
}

Copy-Item -Path $source -Destination $target -Recurse -Force

Write-Host ""
Write-Host "Team project created: $target" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps for the team:"
Write-Host "  1. cd `"$target`""
Write-Host "  2. opencode"
Write-Host "  3. type /setup and follow along"
