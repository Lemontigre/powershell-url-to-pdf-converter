# Setup Documentation

This folder contains installation and setup scripts for the PowerShell URL to PDF Converter.

## Quick Install

### One-Click Installation

Run this command in PowerShell (as Administrator recommended):

```powershell
# Download and run installer
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Lemontigre/powershell-url-to-pdf-converter/main/setup/install.ps1" -OutFile "$env:TEMP\install.ps1"; & "$env:TEMP\install.ps1"
```

## Manual Installation

```powershell
#Create project folder
mkdir "$env:USERPROFILE\Desktop\url-to-pdf-converter"
cd "$env:USERPROFILE\Desktop\url-to-pdf-converter"
mkdir input, output, logs
#Download script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Lemontigre/powershell-url-to-pdf-converter/main/URL-to-PDF-Converter.ps1" -OutFile "URL-to-PDF-Converter.ps1"
#Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#Create URLs file
@"
https://www.google.com
https://www.microsoft.com
https://www.github.com
"@ | Out-File -FilePath "input\urls.txt" -Encoding UTF8
```

## Desktop Shortcuts

```powershell
#Create Converter Shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Convert URLs to PDF.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$env:USERPROFILE\Desktop\url-to-pdf-converter\URL-to-PDF-Converter.ps1`""
$Shortcut.IconLocation = "imageres.dll,2"
$Shortcut.Save()
#Create URL Editor Shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Edit URLs.lnk")
$Shortcut.TargetPath = "notepad.exe"
$Shortcut.Arguments = "`"$env:USERPROFILE\Desktop\url-to-pdf-converter\input\urls.txt`""
$Shortcut.Save()
```

## Verify Installation

```powershell
# Check if files exist
Test-Path "$env:USERPROFILE\Desktop\url-to-pdf-converter\URL-to-PDF-Converter.ps1"
Test-Path "$env:USERPROFILE\Desktop\url-to-pdf-converter\input\urls.txt"

# Check execution policy
Get-ExecutionPolicy -Scope CurrentUser

# Test script
& "$env:USERPROFILE\Desktop\url-to-pdf-converter\URL-to-PDF-Converter.ps1"
```
