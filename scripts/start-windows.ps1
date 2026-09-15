param([switch]$PrepareOnly)
$ErrorActionPreference = 'Stop'
$revision = '9aecb709d5b3d16172749d10f39f9bea89ac4a67'
$expected = '5b0ef1e3a3b356b95c21915838b5070c50f05b0b1ff9670669ab90455986d989'
$work = Join-Path ([IO.Path]::GetTempPath()) ('lark-training-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$archive = Join-Path $work 'setup.zip'
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/entime-aidx/lark-custom-app-setup/archive/$revision.zip" -OutFile $archive
if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {
    throw 'Download verification failed. Setup was not started.'
}
Expand-Archive -LiteralPath $archive -DestinationPath $work
$setup = Join-Path $work "lark-custom-app-setup-$revision\scripts\setup-windows.ps1"
if (-not (Test-Path -LiteralPath $setup -PathType Leaf)) { throw 'Setup file is missing. Nothing installed.' }
Write-Host "Verified setup files: $work"
if ($PrepareOnly) {
    Write-Host 'Download and extraction verified. No installer started.'
} else {
    & powershell.exe -NoLogo -NoProfile -File $setup -Install
    if ($LASTEXITCODE -ne 0) { throw 'Setup stopped. Read the message above; do not disable company security settings.' }
}
