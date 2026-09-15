# Windows PowerShell 5.1+ / PowerShell 7. No execution-policy or security changes.
[CmdletBinding()]
param([switch]$Install)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SoftwareVersion {
    param([string]$Command)
    $resolved = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $resolved) { return $null }
    $raw = & $resolved.Source --version 2>$null
    if ($LASTEXITCODE -ne 0) { throw "Cannot check $Command. Fix the existing installation before continuing." }
    $match = [regex]::Match(($raw -join ' '), '\b(\d+)\.(\d+)(?:\.(\d+))?\b')
    if (-not $match.Success) { throw "Cannot read version of $Command. No replacement was installed." }
    return $match.Value
}

function Get-SetupPlan {
    param([hashtable]$Versions)
    if ($Versions.Node -and [int]($Versions.Node.Split('.')[0]) -lt 22) {
        throw 'Existing Node.js is older than the training baseline (22+). Ask IT how to upgrade without affecting other work.'
    }
    $items = @(
        @{ Key = 'Node'; Label = 'Node.js LTS'; Command = 'node.exe'; Package = 'OpenJS.NodeJS.LTS'; Manager = 'winget' },
        @{ Key = 'Git'; Label = 'Git for Windows'; Command = 'git.exe'; Package = 'Git.Git'; Manager = 'winget' },
        @{ Key = 'Claude'; Label = 'Claude Code'; Command = 'claude'; Package = 'Anthropic.ClaudeCode'; Manager = 'winget' },
        @{ Key = 'Lark'; Label = 'Lark CLI'; Command = 'lark-cli'; Package = '@larksuite/cli@latest'; Manager = 'npm' }
    )
    foreach ($item in $items) {
        [pscustomobject]@{
            Key = $item.Key; Label = $item.Label; Command = $item.Command
            Package = $item.Package; Manager = $item.Manager
            Action = $(if ($Versions[$item.Key]) { 'KEEP' } else { 'INSTALL' })
            Version = $Versions[$item.Key]
        }
    }
}

function Get-InstallCommand {
    param($Item)
    if ($Item.Manager -eq 'winget') {
        return @{ File = 'winget.exe'; Arguments = @('install', '--id', $Item.Package, '--exact', '--source', 'winget', '--no-upgrade', '--interactive') }
    }
    if ($Item.Manager -eq 'npm') {
        return @{ File = 'npm.cmd'; Arguments = @('install', '--global', $Item.Package) }
    }
    throw 'Unknown package manager.'
}

function Update-SessionPath {
    # Refresh this process only; never rewrite the user's persistent PATH.
    $paths = @($env:Path, [Environment]::GetEnvironmentVariable('Path', 'Machine'), [Environment]::GetEnvironmentVariable('Path', 'User'))
    # Common documented user install locations; add only directories already present.
    foreach ($candidate in @((Join-Path $env:APPDATA 'npm'), (Join-Path $env:USERPROFILE '.local\bin'))) {
        if (Test-Path -LiteralPath $candidate -PathType Container) { $paths += $candidate }
    }
    $env:Path = ($paths | Where-Object { $_ }) -join ';'
}

function Invoke-InstallStep {
    param($Item)
    if ($Item.Action -eq 'KEEP') {
        Write-Host "KEEP: $($Item.Label) $($Item.Version)"
        return
    }
    $command = Get-InstallCommand $Item
    if (-not (Get-Command $command.File -ErrorAction SilentlyContinue)) {
        throw "$($command.File) not found. Reopen PowerShell or ask IT; setup stopped."
    }
    Write-Host "INSTALL: $($Item.Label) from $($Item.Manager) ($($Item.Package))"
    $arguments = $command.Arguments
    & $command.File @arguments | Out-Host
    $code = $LASTEXITCODE
    if ($code -ne 0) {
        throw "Installation of $($Item.Label) stopped (exit $code). Do not continue blindly. If a restart is requested, restart and run setup again."
    }
    Update-SessionPath
    $version = Get-SoftwareVersion $Item.Command
    if (-not $version) { throw "$($Item.Label) is not available in PATH yet. Reopen the terminal and run setup again." }
    if ($Item.Key -eq 'Node' -and [int]($version.Split('.')[0]) -lt 22) { throw 'Node.js 22+ is required by this training guide.' }
    Write-Host "OK: $($Item.Label) $version"
}

function Invoke-WindowsSetup {
    param([bool]$Apply)
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'Run this setup on Windows. Use the Mac guide on macOS.' }
    $osVersion = [Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10 -or ($osVersion.Major -eq 10 -and $osVersion.Build -lt 17763)) { throw 'Windows 10 build 17763 (1809) or later is required.' }
    if (-not [Environment]::Is64BitOperatingSystem) { throw 'A 64-bit Windows operating system is required.' }
    if (-not [Environment]::Is64BitProcess) { throw 'Open 64-bit PowerShell before running setup.' }
    Update-SessionPath
    $versions = @{
        Node = Get-SoftwareVersion 'node.exe'
        Git = Get-SoftwareVersion 'git.exe'
        Claude = Get-SoftwareVersion 'claude'
        Lark = Get-SoftwareVersion 'lark-cli'
    }
    $plan = @(Get-SetupPlan $versions)
    $plan | Format-Table Label, Action, Version, Manager -AutoSize | Out-Host
    if (-not $Apply) {
        Write-Host 'Preview only. No software installed. Use -Install to apply this plan.'
        return
    }
    if (@($plan | Where-Object { $_.Action -eq 'INSTALL' -and $_.Manager -eq 'winget' }).Count -gt 0 -and -not (Get-Command 'winget.exe' -ErrorAction SilentlyContinue)) {
        throw 'WinGet is missing. Install/update Microsoft App Installer through your approved company process, then try again. No software has been installed.'
    }
    if ($versions.Node -and -not (Get-Command 'npm.cmd' -ErrorAction SilentlyContinue)) { throw 'Existing Node.js has no npm.cmd. Repair the approved Node installation first.' }
    if (@($plan | Where-Object { $_.Action -eq 'INSTALL' }).Count -gt 0) {
        Write-Host 'Only the missing software above will be installed. UAC and license prompts remain interactive.'
        if ((Read-Host 'Type INSTALL to continue; anything else cancels') -cne 'INSTALL') { Write-Host 'Cancelled. No software installed.'; return }
    }
    foreach ($item in $plan) { Invoke-InstallStep $item }
    Write-Host ''
    $preflight = Join-Path $PSScriptRoot '..\skills\lark-custom-app-setup\scripts\preflight.mjs'
    & node.exe $preflight | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Software setup finished, but the PC check needs attention. Read CHECK items above.' }
    Write-Host 'PC SETUP COMPLETE. Lark authorization and Base editing are NOT verified.'
    Write-Host 'Reopen Git Bash, run claude, sign in, then enter these lines inside Claude Code:'
    Write-Host '/plugin marketplace add entime-aidx/lark-custom-app-setup'
    Write-Host '/plugin install lark-custom-app-setup@entime-training'
}

if ($MyInvocation.InvocationName -ne '.') {
    try { Invoke-WindowsSetup ([bool]$Install) }
    catch { Write-Host "STOP: $($_.Exception.Message)" -ForegroundColor Red; exit 1 }
}
