Get-Date -Format "hh:mm:ss tt"
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Import-Module -Name "LanguagePackManagement"
$params = @{
    Language        = "en-AU"
    CopyToSettings  = $true
    ExcludeFeatures = $true
}
$r = Install-Language @params
Get-Date -Format "hh:mm:ss tt"
