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
            Get-ChildItem -Path $OutFile | Unblock-File
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
            Get-ChildItem -Path $OutFile | Unblock-File
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
            Get-ChildItem -Path $OutFile | Unblock-File
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
            Get-ChildItem -Path $OutFile | Unblock-File
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
    Get-ChildItem -Path $OutFile | Unblock-File
    Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
    $params = @{
        FilePath     = $OutFile
        ArgumentList = "/install /quiet /norestart"
        Wait         = $true
        NoNewWindow  = $true
    }
    Start-Process @params
}

# Install Windows Terminal
# Get the latest release of Windows Terminal from GitHub
Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Get latest Windows Terminal release"
$WindowsTerminal = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/terminal/releases/latest" | Select-Object -First 1
Write-Information -MessageData "$($PSStyle.Foreground.Green)Found: $($WindowsTerminal.tag_name)"
$Urls = $WindowsTerminal.assets.browser_download_url
$PreinstallUrl = $Urls | Where-Object { $_ -match "msixbundle_Windows10_PreinstallKit.zip" }
$OutFile = "$Path\WindowsTerminal_Windows10_PreinstallKit.zip"
$params = @{
    Uri             = $PreinstallUrl
    OutFile         = $OutFile
    UseBasicParsing = $true
}
Invoke-WebRequest @params
Expand-Archive -Path $OutFile -DestinationPath "$Path\Preinstall" -Force
Get-ChildItem -Path "$Path\Preinstall" -Recurse | Unblock-File

# Install or update the Microsoft.UI.Xaml2.8 package
Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: Microsoft.UI.Xaml2.8"
Get-ChildItem -Path "$Path\Preinstall" -Include "*.appx" -Recurse -Exclude "*_arm__*" | ForEach-Object {
    if ($Env:PROCESSOR_ARCHITECTURE -eq "AMD64" -and $_.Name -match "_arm64__") {
        Write-Information -MessageData "$($PSStyle.Foreground.Yellow)Skipping incompatible package: $($_.FullName)"
        return
    }
    Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $($_.FullName)"
    Add-AppxProvisionedPackage -Online -PackagePath $_.FullName -SkipLicense -ErrorAction "SilentlyContinue"
}

# Download the Windows Terminal msixbundle
$TerminalUrl = $Urls | Where-Object { $_ -match "8wekyb3d8bbwe.msixbundle$" }
$OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $TerminalUrl -Leaf)
Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $TerminalUrl"
$params = @{
    Uri             = $TerminalUrl
    OutFile         = $OutFile
    UseBasicParsing = $true
}
Invoke-WebRequest @params
Get-ChildItem -Path $OutFile | Unblock-File
Add-AppxProvisionedPackage -Online -PackagePath $OutFile -SkipLicense

# Install the Microsoft Windows App SDK
# https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads
$AppSdk = @{
    x64   = "https://aka.ms/windowsappsdk/2.2/2.2.0/windowsappruntimeinstall-x64.exe"
    arm64 = "https://aka.ms/windowsappsdk/2.2/2.2.0/windowsappruntimeinstall-arm64.exe"
    x86   = "https://aka.ms/windowsappsdk/2.2/2.2.0/windowsappruntimeinstall-x86.exe"
}
switch ($Env:PROCESSOR_ARCHITECTURE) {
    "AMD64" {
        $AppSdk.x64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri (Resolve-Url -Url $_) -OutFile $OutFile -UseBasicParsing
            Get-ChildItem -Path $OutFile | Unblock-File
        }
    }
    "ARM64" {
        $AppSdk.arm64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri (Resolve-Url -Url $_) -OutFile $OutFile -UseBasicParsing
            Get-ChildItem -Path $OutFile | Unblock-File
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
Get-ChildItem -Path $OutFile | Unblock-File
try {
    Write-Information -MessageData "$($PSStyle.Foreground.Green)Installing: $OutFile"
    Add-AppxProvisionedPackage -Online -PackagePath $OutFile -SkipLicense
}
catch {
    # Write-Information -MessageData "$($PSStyle.Foreground.Green)Retrying: $OutFile"
    # Add-AppxProvisionedPackage -Online -PackagePath $OutFile -SkipLicense -ErrorAction "SilentlyContinue"
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
            Get-ChildItem -Path $OutFile | Unblock-File
        }
    }
    "ARM64" {
        $Pwsh.arm64 | ForEach-Object {
            $OutFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $_ -Leaf)
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Download: $_"
            Invoke-WebRequest -Uri $_ -OutFile $OutFile -UseBasicParsing
            Get-ChildItem -Path $OutFile | Unblock-File
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
Get-ChildItem -Path $OutFile | Unblock-File
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
Get-ChildItem -Path $OutFile | Unblock-File
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
Install-PackageProvider -Name "PowerShellGet" -MinimumVersion "2.2.5" -Force | Out-Null
Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"

# Install modules
Write-Information -MessageData "$($PSStyle.Foreground.Cyan)Install modules: Evergreen, EvergreenUI, PSWindowsUpdate, PSReadLine"
Install-Module -Name "Evergreen", "EvergreenUI", "PSWindowsUpdate", "PSReadLine" -AllowClobber -Force -Scope AllUsers
