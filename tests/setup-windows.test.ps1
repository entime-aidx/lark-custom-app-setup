$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\scripts\setup-windows.ps1')
function Assert-True { param($Condition, $Message); if (-not $Condition) { throw $Message } }
$empty = @{ Node = $null; Git = $null; Claude = $null; Lark = $null }
$p = @(Get-SetupPlan $empty)
Assert-True ($p.Count -eq 4) 'Exactly four packages must be planned.'
Assert-True (($p | Where-Object Action -eq 'INSTALL').Count -eq 4) 'All missing packages should be planned.'
$full = @{ Node = '24.0.0'; Git = '2.50.0'; Claude = '2.1.0'; Lark = '1.0.92' }
$p = @(Get-SetupPlan $full)
Assert-True (($p | Where-Object Action -eq 'KEEP').Count -eq 4) 'Installed software must be reused.'
$oldRejected = $false
try { Get-SetupPlan @{ Node = '18.0.0'; Git = $null; Claude = $null; Lark = $null } | Out-Null } catch { $oldRejected = $true }
Assert-True $oldRejected 'Old Node must not be silently replaced.'
$p = @(Get-SetupPlan $empty)
$commands = @($p | ForEach-Object { Get-InstallCommand $_ })
Assert-True (($commands[0].Arguments -join ' ') -eq 'install --id OpenJS.NodeJS.LTS --exact --source winget --no-upgrade --interactive') 'Node package must be exact and no-upgrade.'
Assert-True (($commands[1].Arguments -join ' ') -match 'Git.Git') 'Git package mismatch.'
Assert-True (($commands[2].Arguments -join ' ') -match 'Anthropic.ClaudeCode') 'Claude package mismatch.'
Assert-True ($commands[3].File -eq 'npm.cmd') 'Use npm.cmd to avoid npm.ps1 policy problems.'
foreach ($command in $commands) {
    Assert-True (($command.Arguments -join ' ') -notmatch 'accept-.*agreements|ignore-security|force|allow-reboot') 'Must preserve agreement/security/restart prompts.'
}
# Mock external execution: verify fail-fast and no version lookup after a failed install.
$script:InstallCalls = 0
function winget.exe { $script:InstallCalls++; $global:LASTEXITCODE = 17 }
function Get-SoftwareVersion { throw 'Version lookup must not run after install failure.' }
$failure = $false
try { Invoke-InstallStep $p[0] } catch { $failure = $_.Exception.Message -match 'exit 17' }
Assert-True $failure 'Installer error must stop the step.'
Assert-True ($script:InstallCalls -eq 1) 'Must not retry failed installers blindly.'
Invoke-InstallStep ([pscustomobject]@{ Action = 'KEEP'; Label = 'Existing'; Version = '1.0.0' })
Assert-True ($script:InstallCalls -eq 1) 'KEEP must not call installer.'
Write-Host 'Windows setup planning, existing-install protection, and fail-fast tests passed. No software installed.'
