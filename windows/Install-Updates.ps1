<#
    Update a Windows install with Visual C++ Redistributables, .NET Runtime,
        Windows App SDK, Desktop App Installer, PowerShell, and OneDrive
#>
[CmdletBinding(SupportsShouldProcess = $false)]
param ()

# Configure the environment
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$InformationPreference = [System.Management.Automation.ActionPreference]::Continue
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

Import-Module -Name "PSWindowsUpdate"
$params = @{
    Install              = $true
    Download             = $true
    AcceptAll            = $true
    MicrosoftUpdate      = $true
    IgnoreReboot         = $true
    IgnoreRebootRequired = $true
    IgnoreUserInput      = $true
}
Install-WindowsUpdate @params
