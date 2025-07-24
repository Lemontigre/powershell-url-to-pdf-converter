# Simple URL to PDF Converter - Full Path Version
# Can be run from anywhere on your system

$projectDir = "$env:USERPROFILE\Desktop\url-to-pdf-converter"
$inputFile = "$projectDir\input\urls.txt"
$outputDir = "$projectDir\output"

Write-Host "=== Simple URL to PDF Converter ===" -ForegroundColor Green
Write-Host "Project: $projectDir" -ForegroundColor Yellow

# Create directories if they don't exist
if (-not (Test-Path $projectDir)) {
    New-Item -Path $projectDir -ItemType Directory -Force | Out-Null
    New-Item -Path "$projectDir\input" -ItemType Directory -Force | Out-Null
    New-Item -Path "$projectDir\output" -ItemType Directory -Force | Out-Null
    New-Item -Path "$projectDir\logs" -ItemType Directory -Force | Out-Null
    Write-Host "Created project directories" -ForegroundColor Green
}

if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
}

# Create sample URLs file if it doesn't exist
if (-not (Test-Path $inputFile)) {
    @"
https://www.google.com
https://www.microsoft.com
https://www.github.com
https://example.com
"@ | Out-File -FilePath $inputFile -Encoding UTF8
    Write-Host "Created sample URLs file" -ForegroundColor Green
}

# Read URLs
$urls = Get-Content $inputFile -ErrorAction SilentlyContinue | Where-Object {$_ -and $_.Trim() -and $_ -notmatch '^#'}
if (-not $urls) {
    Write-Host "No URLs found in $inputFile" -ForegroundColor Red
    Write-Host "Add URLs to the file (one per line) and run again" -ForegroundColor Yellow
    exit
}

Write-Host "Found $($urls.Count) URLs to convert" -ForegroundColor Cyan

# Find Edge
$edgePath = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edgePath)) {
    $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
}

if (-not (Test-Path $edgePath)) {
    Write-Host "ERROR: Microsoft Edge not found!" -ForegroundColor Red
    exit
}

Write-Host "Using: $edgePath" -ForegroundColor Green

# Convert URLs
$counter = 0
$successCount = 0

foreach ($url in $urls) {
    $counter++
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $fileName = "PDF_$counter`_$timestamp.pdf"
    $outputPath = "$outputDir\$fileName"
    
    Write-Host "`n[$counter/$($urls.Count)] $url" -ForegroundColor Cyan
    
    try {
        $process = Start-Process -FilePath $edgePath -ArgumentList "--headless", "--disable-gpu", "--print-to-pdf=`"$outputPath`"", "`"$url`"" -Wait -PassThru -WindowStyle Hidden
        
        Start-Sleep 1
        
        if (Test-Path $outputPath) {
            $sizeKB = [math]::Round((Get-Item $outputPath).Length / 1KB, 1)
            Write-Host "  ✓ $fileName ($sizeKB KB)" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  ✗ Failed (Exit: $($process.ExitCode))" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep 1
}

# Summary
Write-Host "`n=== COMPLETE ===" -ForegroundColor Green
Write-Host "Converted: $successCount/$($urls.Count)" -ForegroundColor White
Write-Host "Output: $outputDir" -ForegroundColor White

if ($successCount -gt 0) {
    Write-Host "`nFiles created:" -ForegroundColor Yellow
    Get-ChildItem "$outputDir\*.pdf" | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | ForEach-Object {
        $sizeKB = [math]::Round($_.Length / 1KB, 1)
        Write-Host "  $($_.Name) ($sizeKB KB)" -ForegroundColor White
    }
    
    Write-Host "`nTo open output folder:" -ForegroundColor Yellow
    Write-Host "  explorer `"$outputDir`"" -ForegroundColor Gray
}
