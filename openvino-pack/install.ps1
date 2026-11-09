param(
    [Parameter(Mandatory = $true)][string]$MaaDir,
    [switch]$Rollback
)

$ErrorActionPreference = "Stop"
$packDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backupDir = Join-Path $MaaDir ("backup-openvino-" + (Get-Date -Format "yyyyMMdd-HHmmss"))

function Backup-And-Copy([string]$src, [string]$dstDir) {
    $name = Split-Path -Leaf $src
    $dst = Join-Path $dstDir $name
    if (Test-Path $dst) {
        New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
        Copy-Item $dst (Join-Path $backupDir $name) -Force
    }
    Copy-Item $src $dst -Force
}

if ($Rollback) {
    $latest = Get-ChildItem -Directory -Filter "backup-openvino-*" -Path $MaaDir |
        Sort-Object Name -Descending | Select-Object -First 1
    if (-not $latest) { throw "No backup found under $MaaDir" }
    Get-ChildItem $latest.FullName -File | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $MaaDir $_.Name) -Force
    }
    Write-Host "Rolled back from $($latest.FullName)"
    exit 0
}

Get-ChildItem $packDir -Filter "*.dll" | ForEach-Object {
    Backup-And-Copy $_.FullName $MaaDir
}
Write-Host "Installed OpenVINO pack into $MaaDir"
if (Test-Path $backupDir) { Write-Host "Backup: $backupDir" }
