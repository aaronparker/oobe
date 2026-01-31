<#
    Update a Windows install with Visual C++ Redistributables, .NET Runtime,
        Windows App SDK, Desktop App Installer, PowerShell, and OneDrive
#>
[CmdletBinding(SupportsShouldProcess = $false)]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $Path = "${Env:SystemDrive}\Apps" #Path to save binaries
)

# Configure the environment
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$InformationPreference = [System.Management.Automation.ActionPreference]::Continue
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Functions
function Resolve-Url ($Url) {
    try {
        $req = [System.Net.WebRequest]::Create($Url)
        $req.Method = "HEAD"
        $req.AllowAutoRedirect = $false
        $resp = $req.GetResponse()
        return $resp.GetResponseHeader("Location")

    }
    catch [System.Net.WebException] {
        $resp = $_.Exception.Response
        return $resp.GetResponseHeader("Location")
    }
    finally {
        $resp.Close()
        $resp.Dispose()
    }
}

# Create path
Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Create path: $Path"
New-Item -Path $Path -ItemType "Directory" -Force | Out-Null

# Install VcRedists
$VcList = @{
    x64   = "https://aka.ms/vc14/vc_redist.x64.exe"
    x86   = "https://aka.ms/vc14/vc_redist.x86.exe"
    arm64 = "https://aka.ms/vc14/vc_redist.arm64.exe"
}
switch ($Env:PROCESSOR_ARCHITECTURE) {
    "AMD64" {
        $VcList.x86, $VcList.x64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri $_ -OutFile $OutFile -UseBasicParsing
            Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
            $params = @{
                FilePath     = $OutFile
                ArgumentList = "/install /quiet /norestart"
                Wait         = $true
                NoNewWindow  = $true
            }
            Start-Process @params
        }
    }
    "ARM64" {
        $VcList.x86, $VcList.x64, $VcList.arm64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri $_ -OutFile $OutFile -UseBasicParsing
            Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
            $params = @{
                FilePath     = $OutFile
                ArgumentList = "/install /quiet /norestart"
                Wait         = $true
                NoNewWindow  = $true
            }
            Start-Process @params
        }
    }
    default { throw "Unsupported architecture." }
}

# Install the Microsoft .NET LTS
$VersionUrl = "https://dotnetcli.blob.core.windows.net/dotnet/Runtime/LTS/latest.version"
$Version = Invoke-RestMethod -Uri $VersionUrl -UseBasicParsing
$DotNet = @{
    x64   = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/$Version/windowsdesktop-runtime-$Version-win-x64.exe"
    arm64 = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/$Version/windowsdesktop-runtime-$Version-win-arm64.exe"
}
switch ($Env:PROCESSOR_ARCHITECTURE) {
    "AMD64" {
        $DotNet.x64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri $_ -OutFile $OutFile -UseBasicParsing
            Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
            $params = @{
                FilePath     = $OutFile
                ArgumentList = "/install /quiet /norestart"
                Wait         = $true
                NoNewWindow  = $true
            }
            Start-Process @params
        }
    }
    "ARM64" {
        $DotNet.x64, $DotNet.arm64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri $_ -OutFile $OutFile -UseBasicParsing
            Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
            $params = @{
                FilePath     = $OutFile
                ArgumentList = "/install /quiet /norestart"
                Wait         = $true
                NoNewWindow  = $true
            }
            Start-Process @params
        }
    }
    default { throw "Unsupported architecture." }
}

# Install the Microsoft .NET 8.0
$VersionUrl = "https://dotnetcli.blob.core.windows.net/dotnet/Runtime/8.0/latest.version"
$Version = Invoke-RestMethod -Uri $VersionUrl -UseBasicParsing
$DotNet = @{
    x64 = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/$Version/windowsdesktop-runtime-$Version-win-x64.exe"
    x86 = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/$Version/windowsdesktop-runtime-$Version-win-x86.exe"
}
$DotNet.x64, $DotNet.x86 | ForEach-Object {
    $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
    Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
    Invoke-WebRequest -Uri $_ -OutFile $OutFile -UseBasicParsing
    Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
    $params = @{
        FilePath     = $OutFile
        ArgumentList = "/install /quiet /norestart"
        Wait         = $true
        NoNewWindow  = $true
    }
    Start-Process @params
}

# Install the Microsoft Windows App SDK
# https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads
$AppSdk = @{
    x64   = "https://aka.ms/windowsappsdk/1.7/latest/windowsappruntimeinstall-x64.exe"
    arm64 = "https://aka.ms/windowsappsdk/1.7/latest/windowsappruntimeinstall-arm64.exe"
}
switch ($Env:PROCESSOR_ARCHITECTURE) {
    "AMD64" {
        $AppSdk.x64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri (Resolve-Url -Url $_) -OutFile $OutFile -UseBasicParsing
        }
    }
    "ARM64" {
        $AppSdk.arm64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri (Resolve-Url -Url $_) -OutFile $OutFile -UseBasicParsing
        }
    }
    default { throw "Unsupported architecture." }
}
Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
$params = @{
    FilePath     = $OutFile
    ArgumentList = "--msix --quiet"
    Wait         = $true
    NoNewWindow  = $true
}
Start-Process @params

# Desktop App Installer
# https://learn.microsoft.com/en-us/windows/msix/app-installer/install-update-app-installer
$OutFile = "$Path\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$Url = Resolve-Url -Url "https://aka.ms/getwinget"
Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $Url"
$params = @{
    Uri             = $Url
    OutFile         = $OutFile
    UseBasicParsing = $true
}
Invoke-WebRequest @params
try {
    Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
    Add-AppxPackage -Path $OutFile
}
catch {
    Write-Information -MessageData "$($PSStyle.Foreground.Green)Retrying: $OutFile"
    Add-AppxPackage -Path $OutFile -ErrorAction "SilentlyContinue" -ForceApplicationShutdown
}

# PowerShell LTS
$VersionUrl = "https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json"
$Version = (Invoke-RestMethod -Uri $VersionUrl -UseBasicParsing).LTSReleaseTag[0] -replace "v", ""
$Pwsh = @{
    x64   = "https://github.com/PowerShell/PowerShell/releases/download/v$Version/PowerShell-$Version-win-x64.msi"
    arm64 = "https://github.com/PowerShell/PowerShell/releases/download/v$Version/PowerShell-$Version-win-arm64.msi"
}
switch ($Env:PROCESSOR_ARCHITECTURE) {
    "AMD64" {
        $Pwsh.x64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri $_ -OutFile $OutFile -UseBasicParsing
        }
    }
    "ARM64" {
        $Pwsh.arm64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri $_ -OutFile $OutFile -UseBasicParsing
        }
    }
    default { throw "Unsupported architecture." }
}
Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
$params = @{
    FilePath     = "$Env:SystemRoot\System32\msiexec.exe"
    ArgumentList = "/package `"$OutFile`" /quiet /norestart USE_MU=1 ENABLE_MU=1"
    Wait         = $true
    NoNewWindow  = $true
}
Start-Process @params

# Update Microsoft OneDrive and install per-machine
$params = @{
    Uri             = "https://g.live.com/1rewlive5skydrive/OneDriveProductionV2"
    ContentType     = "application/xml; charset=utf-8"
    Method          = "Default"
    OutFile         = "$Path\OneDrive.xml"
    UseBasicParsing = $true
}
Invoke-WebRequest @params
[System.Xml.XmlDocument]$OneDriveXml = Get-Content -Path "$Path\OneDrive.xml" -Encoding "utf8"
switch ($Env:PROCESSOR_ARCHITECTURE) {
    "AMD64" {
        $Url = $OneDriveXml.root.update.amd64binary.url | Select-Object -First 1
    }
    "ARM64" {
        $Url = $OneDriveXml.root.update.arm64binary.url | Select-Object -First 1
    }
    default { throw "Unsupported architecture." }
}
$OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $Url -Leaf)
Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $Url"
Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
reg add "HKLM\Software\Microsoft\OneDrive" /v "AllUsersInstall" /t REG_DWORD /d 1 /reg:64 /f *> $null
Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
$params = @{
    FilePath     = $OutFile
    ArgumentList = "/silent /allusers"
    Wait         = $false
    NoNewWindow  = $true
}
Start-Process @params
do {
    Start-Sleep -Seconds 5
} while (Get-Process -Name "OneDriveSetup" -ErrorAction "SilentlyContinue")
Get-Process -Name "OneDrive" -ErrorAction "SilentlyContinue" | ForEach-Object {
    Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Stop process: $($_.Name)"
    Stop-Process -Name $_.Name -Force -ErrorAction "SilentlyContinue"
}

# Cleanup downloads
Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Remove path: $Path"
Remove-Item -Path $Path -Recurse -Force -ErrorAction "SilentlyContinue"

# Trust the PSGallery for modules
Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Install NuGet, PowerShellGet"
# Register-PackageSource -Name "NuGet" -Location "https://api.nuget.org/v3/index.json" -ProviderName "NuGet" -Trusted -Confirm:$false
Install-PackageProvider -Name "PowerShellGet" -MinimumVersion "2.2.5" -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"

# Install modules
Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Install modules: Evergreen, PSWindowsUpdate, PSReadLine"
Install-Module -Name "Evergreen", "PSWindowsUpdate", "PSReadLine" -AllowClobber -Force -Scope AllUsers
