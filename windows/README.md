# Scripts Directory

This directory contains utility scripts for Windows system configuration and application management. These scripts are designed to be used as part of Windows image customization processes or standalone system maintenance tasks.

## Scripts Overview

### Install-Core.ps1

**Purpose**: Downloads and installs essential runtime components and applications required for a modern Windows environment.

**Description**: This script automates the installation of core Microsoft runtime libraries and applications that are commonly required but may not be present in a base Windows installation. It supports both x64 and ARM64 architectures and handles architecture-specific downloads automatically.

**Components Installed**:
- **Visual C++ Redistributables**: Installs the latest Visual C++ Redistributable packages (x86, x64, and ARM64 as appropriate) required by many applications
- **Microsoft .NET Runtime**: Downloads and installs the latest Long Term Support (LTS) version of the .NET Desktop Runtime
- **Windows App SDK**: Installs the Microsoft Windows App SDK runtime components required for modern Windows applications
- **Desktop App Installer (winget)**: Installs the Microsoft Store's Desktop App Installer, which includes the Windows Package Manager (winget) command-line tool
- **PowerShell LTS**: Downloads and installs the latest Long Term Support version of PowerShell 7
- **Microsoft OneDrive**: Updates OneDrive to the latest version and configures it for per-machine installation

**Parameters**:
- `Path` (Optional): Specifies the temporary download location for installation files. Default: `C:\Apps`

**Features**:
- Architecture detection and appropriate package selection
- Silent installation with no user interaction required
- Automatic cleanup of downloaded installation files
- PowerShell Gallery configuration (sets PSGallery as trusted repository)
- OneDrive per-machine installation setup

**Usage Example**:
```powershell
.\Install-Core.ps1 -Path "D:\Temp\Downloads"
```

**Requirements**:
- Administrative privileges
- Internet connectivity
- Windows 10/11 or Windows Server 2016-2025

---

### Update-StoreApp.ps1

**Purpose**: Updates Microsoft Store applications using the Windows Runtime API for programmatic app updates.

**Description**: This script provides a reliable method to update Microsoft Store applications programmatically, which is particularly useful in enterprise environments or during image creation where the Microsoft Store may not be available or accessible. It uses the Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager WinRT API to request updates directly.

**Key Features**:
- **Programmatic Updates**: Updates Store apps without requiring user interaction or Store UI access
- **Batch Processing**: Can update multiple applications simultaneously
- **Progress Monitoring**: Displays progress information during update operations
- **Error Handling**: Gracefully handles apps that are not installed or cannot be updated
- **Flexible Input**: Accepts specific package family names or can update all user-installed apps

**Default Applications Updated**:
- Windows Terminal
- Calculator
- Desktop App Installer (winget)
- Notepad
- Paint
- Alarms & Clock
- Feedback Hub
- Widgets (Web Experience Pack)
- Microsoft Store

**Parameters**:
- `PackageFamilyName` (Optional): Array of package family names to update. If not specified, updates a predefined list of common Microsoft applications

**Usage Examples**:
```powershell
# Update default list of applications
.\Update-StoreApp.ps1

# Update specific applications
.\Update-StoreApp.ps1 -PackageFamilyName "Microsoft.WindowsTerminal_8wekyb3d8bbwe", "Microsoft.WindowsCalculator_8wekyb3d8bbwe"

# Update all non-system apps (pipeline usage)
Get-AppxPackage | Where-Object { $_.NonRemovable -eq $false -and $_.IsFramework -eq $false } | .\Update-StoreApp.ps1
```

**Requirements**:
- Windows PowerShell 5.1 (not compatible with PowerShell Core/7 on some platforms)
- Windows 10/11 (not designed for Windows Server)
- Internet connectivity for downloading updates
- Appropriate permissions to update applications

**Technical Notes**:
- Uses Windows Runtime (WinRT) APIs for Store integration
- Implements asynchronous operation handling for update tasks
- Includes built-in retry logic and error handling
- Progress reporting through Write-Progress cmdlet

---

### Set-Language.ps1

**Purpose**: Configures system language, locale, and regional settings for Windows installations.

**Description**: This script automates the process of installing language packs and configuring all language-related settings in Windows. It's particularly useful for creating region-specific Windows images or configuring systems for specific geographic locations during deployment.

**Configuration Areas**:
- **Language Pack Installation**: Downloads and installs the specified language pack
- **System Locale**: Sets the system locale for non-Unicode applications
- **User Interface Language**: Configures the display language for Windows UI elements
- **Regional Settings**: Sets the home location and regional formatting
- **Time Zone**: Configures the system time zone
- **Culture Settings**: Sets number, date, and currency formatting preferences

**Parameters**:
- `Language` (Optional): Language code to install and configure. Default: `"en-AU"` (English - Australia)
- `TimeZone` (Optional): Time zone identifier to set. Default: `"AUS Eastern Standard Time"`

**Language Configuration Process**:
1. Imports the LanguagePackManagement module
2. Downloads and installs the specified language pack
3. Copies language settings to system settings
4. Sets culture and regional preferences
5. Configures UI language override
6. Sets system preferred UI language
7. Configures geographic location based on language
8. Sets the specified time zone

**Usage Examples**:
```powershell
# Set to Australian English (default)
.\Set-Language.ps1

# Set to US English with Pacific time zone
.\Set-Language.ps1 -Language "en-US" -TimeZone "Pacific Standard Time"

# Set to French with Central European time zone
.\Set-Language.ps1 -Language "fr-FR" -TimeZone "Central Europe Standard Time"
```

**Requirements**:
- Administrative privileges (script includes #Requires -RunAsAdministrator)
- Windows 10/11 or Windows Server with Desktop Experience
- Internet connectivity for language pack downloads
- LanguagePackManagement and International PowerShell modules

**Error Handling**:
- Includes try-catch block to handle installation failures gracefully
- Exits with code 0 even on failure to prevent blocking automated deployment processes (useful for Windows Autopilot scenarios)

**Common Use Cases**:
- Windows image localization
- Automated deployment in specific regions
- Compliance with local language requirements
- Virtual desktop infrastructure (VDI) customization
- Windows Autopilot device configuration

---

## General Notes

### Execution Context
- All scripts are designed to run in elevated (administrator) context
- Scripts support both interactive and automated execution scenarios
- Compatible with Windows deployment tools and frameworks

### Architecture Support
- Install-Core.ps1 automatically detects and supports x64 and ARM64 architectures
- Update-StoreApp.ps1 works with all Windows Store supported architectures
- Set-Language.ps1 is architecture-independent

### Integration
These scripts can be integrated into:
- Windows image customization workflows
- Microsoft Deployment Toolkit (MDT) task sequences
- System Center Configuration Manager (SCCM) deployments
- Windows Autopilot provisioning
- Azure Virtual Desktop image preparation
- Custom PowerShell Desired State Configuration (DSC) resources

### Best Practices
- Test scripts in a non-production environment before deployment
- Review and customize the default application lists in Update-StoreApp.ps1 for your organization
- Verify language pack availability for your target language in Set-Language.ps1
- Ensure proper network connectivity for download operations
- Consider implementing logging for deployment scenarios
