# PowerShell URL to PDF Converter - One-Click Installer
# This script sets up everything needed to run the converter

param(
    [string]$InstallPath = "$env:USERPROFILE\Desktop\url-to-pdf-converter"
)

Write-Host "PowerShell URL to PDF Converter - Installer" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Create project directory
Write-Host "Creating project directory..." -ForegroundColor Yellow
if (-not (Test-Path $InstallPath)) {
    New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
    New-Item -Path "$InstallPath\input" -ItemType Directory -Force | Out-Null
    New-Item -Path "$InstallPath\output" -ItemType Directory -Force | Out-Null
    New-Item -Path "$InstallPath\logs" -ItemType Directory -Force | Out-Null
    Write-Host "✓ Directories created" -ForegroundColor Green
} else {
    Write-Host "✓ Directory already exists" -ForegroundColor Green
}

# Download main script
Write-Host "Downloading main script..." -ForegroundColor Yellow
try {
    $scriptUrl = "https://raw.githubusercontent.com/Lemontigre/powershell-url-to-pdf-converter/main/URL-to-PDF-Converter.ps1"
    Invoke-WebRequest -Uri $scriptUrl -OutFile "$InstallPath\URL-to-PDF-Converter.ps1"
    Write-Host "✓ Script downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download script: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Download sample URLs
Write-Host "Creating sample URLs file..." -ForegroundColor Yellow
$sampleUrls = @'
# Sample URLs for testing the converter
# Lines starting with # are comments and will be ignored

# News and Information
https://www.google.com
https://www.microsoft.com
https://www.github.com

# Documentation Examples
https://docs.microsoft.com/powershell/
https://stackoverflow.com/questions/tagged/powershell

# Add your own URLs below:
# https://your-website.com
# https://another-site.com/page
'@

$sampleUrls | Out-File -FilePath "$InstallPath\input\urls.txt" -Encoding UTF8
Write-Host "✓ Sample URLs created" -ForegroundColor Green

# Set execution policy
Write-Host "Setting PowerShell execution policy..." -ForegroundColor Yellow
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "✓ Execution policy set" -ForegroundColor Green
} catch {
    Write-Host "! May need to run as Administrator for execution policy" -ForegroundColor Yellow
}

# Create desktop shortcuts
Write-Host "Creating desktop shortcuts..." -ForegroundColor Yellow
try {
    $WshShell = New-Object -comObject WScript.Shell
    
    # Main converter shortcut
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Convert URLs to PDF.lnk")
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$InstallPath\URL-to-PDF-Converter.ps1`""
    $Shortcut.WorkingDirectory = $InstallPath
    $Shortcut.IconLocation = "imageres.dll,2"
    $Shortcut.Description = "Convert URLs to PDF files"
    $Shortcut.Save()
    
    # URL editor shortcut
    $Shortcut2 = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Edit URLs.lnk")
    $Shortcut2.TargetPath = "notepad.exe"
    $Shortcut2.Arguments = "`"$InstallPath\input\urls.txt`""
    $Shortcut2.Description = "Edit URLs to convert"
    $Shortcut2.Save()
    
    Write-Host "✓ Desktop shortcuts created" -ForegroundColor Green
} catch {
    Write-Host "! Could not create shortcuts: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Installation complete
Write-Host "`nInstallation Complete!" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
Write-Host "Location: $InstallPath" -ForegroundColor White
Write-Host "Desktop shortcuts created:" -ForegroundColor White
Write-Host "  - Convert URLs to PDF.lnk" -ForegroundColor Gray
Write-Host "  - Edit URLs.lnk" -ForegroundColor Gray
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Edit URLs using the desktop shortcut or:" -ForegroundColor White
Write-Host "   notepad `"$InstallPath\input\urls.txt`"" -ForegroundColor Gray
Write-Host "2. Double-click 'Convert URLs to PDF' to run" -ForegroundColor White
Write-Host "3. Find PDFs in: $InstallPath\output" -ForegroundColor White
