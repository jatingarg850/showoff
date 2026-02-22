@echo off
REM ============================================================================
REM Build AAB (Android App Bundle) for Play Store with NEW KEYSTORE
REM ============================================================================
REM This script builds a signed AAB for Play Store release using the new keystore
REM Keystore: keystore/upload-showofflife.jks
REM Certificate: keystore/upload_certificate.pem
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════════════════╗
echo ║          ShowOff.life - AAB Build for Play Store (NEW KEYSTORE)        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Flutter found
echo.

REM Verify keystore files exist
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Verifying keystore files...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not exist "keystore\upload-showofflife.jks" (
    echo ❌ Keystore file not found: keystore\upload-showofflife.jks
    pause
    exit /b 1
)
echo ✅ Keystore found: keystore\upload-showofflife.jks

if not exist "keystore\upload_certificate.pem" (
    echo ⚠️  Certificate file not found: keystore\upload_certificate.pem
    echo    (This is optional, but recommended for verification)
)
echo ✅ Certificate found: keystore\upload_certificate.pem

echo ✅ Key properties configured: apps\android\key\key.properties
echo.

REM Navigate to apps directory
cd /d "%~dp0apps"
if errorlevel 1 (
    echo ❌ Failed to navigate to apps directory
    pause
    exit /b 1
)

echo 📁 Working directory: %cd%
echo.

REM Step 1: Clean previous builds
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Step 1: Cleaning previous builds...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
flutter clean
if errorlevel 1 (
    echo ❌ Flutter clean failed
    pause
    exit /b 1
)
echo ✅ Clean completed
echo.

REM Step 2: Get dependencies
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Step 2: Getting dependencies...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
flutter pub get
if errorlevel 1 (
    echo ❌ Flutter pub get failed
    pause
    exit /b 1
)
echo ✅ Dependencies fetched
echo.

REM Step 3: Build AAB
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Step 3: Building AAB (Android App Bundle)...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo This may take several minutes...
echo.

flutter build appbundle --release
if errorlevel 1 (
    echo ❌ AAB build failed
    echo.
    echo Troubleshooting:
    echo - Verify keystore path: keystore/upload-showofflife.jks
    echo - Check key.properties file: apps/android/key/key.properties
    echo - Ensure keystore password is correct
    echo - Key alias should be: upload-showofflife
    pause
    exit /b 1
)

echo.
echo ✅ AAB build completed successfully!
echo.

REM Step 4: Verify AAB file
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Step 4: Verifying AAB file...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set AAB_FILE=build\app\outputs\bundle\release\app-release.aab

if exist "%AAB_FILE%" (
    echo ✅ AAB file found: %AAB_FILE%
    
    REM Get file size
    for %%A in ("%AAB_FILE%") do (
        set SIZE=%%~zA
        set /a SIZE_MB=!SIZE! / 1048576
        echo 📦 File size: !SIZE_MB! MB
    )
    echo.
) else (
    echo ❌ AAB file not found at expected location
    echo Expected: %AAB_FILE%
    pause
    exit /b 1
)

echo.
echo ╔════════════════════════════════════════════════════════════════════════╗
echo ║                         BUILD SUCCESSFUL! ✅                           ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo.
echo 📦 AAB File Location:
echo    %cd%\%AAB_FILE%
echo.
echo 📋 Next Steps:
echo    1. Go to Google Play Console (https://play.google.com/console)
echo    2. Select your app (ShowOff.life)
echo    3. Go to Release → Production
echo    4. Click "Create new release"
echo    5. Upload the AAB file
echo    6. Review and publish
echo.
echo 🔐 Keystore Information (NEW):
echo    - Keystore: keystore/upload-showofflife.jks
echo    - Key Alias: upload-showofflife
echo    - Certificate: keystore/upload_certificate.pem
echo    - Config: apps/android/key/key.properties
echo.
echo 💡 Tips:
echo    - Keep your keystore file safe and backed up
echo    - Never share your keystore password
echo    - Use the same keystore for all future updates
echo.

cd ..
pause
