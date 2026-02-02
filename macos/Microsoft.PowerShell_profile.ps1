# Microsoft.PowerShell_profile.ps1
Set-PSReadLineOption -PredictionViewStyle ListView
if ($env:TERM_PROGRAM -eq "vscode") { . "$(code --locate-shell-integration-path pwsh)" }
oh-my-posh init pwsh | Invoke-Expression
Set-Location -Path "/Users/aaron/projects"
clear
