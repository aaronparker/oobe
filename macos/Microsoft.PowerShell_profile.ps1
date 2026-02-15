# Microsoft.PowerShell_profile.ps1

# PSReadLine options
Set-PSReadLineOption -PredictionViewStyle "ListView" -HistoryNoDuplicates

# Enable VSCode shell integration if running in VSCode terminal
if ($env:TERM_PROGRAM -eq "vscode") { . "$(code --locate-shell-integration-path pwsh)" }

# Enable oh-my-posh
oh-my-posh init pwsh | Invoke-Expression

# Load Evergreen module and dot source all .ps1 files in the Private and Shared folders
$Path = "~/projects/_EUCPilots/evergreen-module"
if (Test-Path -Path $Path) {
    Import-Module "$Path/Evergreen/Evergreen.psd1" -Force
    foreach ($file in (Get-ChildItem -Path "$Path/Evergreen/Private/*.ps1")) {
        . $file.FullName
    }
    foreach ($file in (Get-ChildItem -Path "$Path/Evergreen/Shared/*.ps1")) {
        . $file.FullName
    }
}

# Display the Evergreen Apps path in green
Write-Host "Evergreen Apps path: $(Get-EvergreenAppsPath)" -ForegroundColor Green

# Set the default location to the projects folder
Set-Location -Path "~/projects"
