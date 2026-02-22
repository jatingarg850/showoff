# ============================================================================
# Build AAB (Android App Bundle) for Play Store - PowerShell Version
# ============================================================================
# This script builds a signed AAB for Play Store release using the keystore
# Keystore: keystore/upload-showofflife.jks
# ============================================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                  ShowOff.life - AAB Build for Play Store               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>&1
    Write-Host "✅ Flutter found" -ForegroundColor Green
    Write-Host "   $($flutterVersion[0])" -ForegroundColor Gray
} catch {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Navigate to apps directory
$appsPath = Join-Path $PSScriptRoot "apps"
if (-not (Test-Path $appsPath)) {
    Write-Host "❌ Failed to find apps directory at: $appsPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Set-Location $appsPath
Write-Host "📁 Working directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean previous builds
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter clean failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✅ Clean completed" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Step 2: Getting dependencies..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter pub get failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✅ Dependencies fetched" -ForegroundColor Green
Write-Host ""

# Step 3: Build AAB
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Step 3: Building AAB (Android App Bundle)..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
Write-Host "This may take several minutes..." -ForegroundColor Cyan
Write-Host ""

flutter build appbundle --release
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ AAB build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "- Verify keystore path: keystore/upload-showofflife.jks" -ForegroundColor Gray
    Write-Host "- Check key.properties file: apps/key/key.properties" -ForegroundColor Gray
    Write-Host "- Ensure keystore password is correct" -ForegroundColor Gray
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "✅ AAB build completed successfully!" -ForegroundColor Green
Write-Host ""

# Step 4: Verify AAB file
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Step 4: Verifying AAB file..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

$aabFile = "build\app\outputs\bundle\release\app-release.aab"

if (Test-Path $aabFile) {
    Write-Host "✅ AAB file found: $aabFile" -ForegroundColor Green
    
    $fileSize = (Get-Item $aabFile).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Host "📦 File size: $fileSizeMB MB" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "❌ AAB file not found at expected location" -ForegroundColor Red
    Write-Host "Expected: $aabFile" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                         BUILD SUCCESSFUL! ✅                           ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$fullPath = Join-Path (Get-Location) $aabFile
Write-Host "📦 AAB File Location:" -ForegroundColor Cyan
Write-Host "   $fullPath" -ForegroundColor White
Write-Host ""

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Go to Google Play Console (https://play.google.com/console)" -ForegroundColor Gray
Write-Host "   2. Select your app (ShowOff.life)" -ForegroundColor Gray
Write-Host "   3. Go to Release → Production" -ForegroundColor Gray
Write-Host "   4. Click 'Create new release'" -ForegroundColor Gray
Write-Host "   5. Upload the AAB file" -ForegroundColor Gray
Write-Host "   6. Review and publish" -ForegroundColor Gray
Write-Host ""

Write-Host "🔐 Keystore Information:" -ForegroundColor Cyan
Write-Host "   - Keystore: keystore/upload-showofflife.jks" -ForegroundColor Gray
Write-Host "   - Key Alias: upload-showofflife" -ForegroundColor Gray
Write-Host "   - Config: apps/key/key.properties" -ForegroundColor Gray
Write-Host ""

Write-Host "💡 Tips:" -ForegroundColor Cyan
Write-Host "   - Keep your keystore file safe and backed up" -ForegroundColor Gray
Write-Host "   - Never share your keystore password" -ForegroundColor Gray
Write-Host "   - Use the same keystore for all future updates" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
