@echo off
echo ========================================
echo   Building ShowOff.life Release AAB
echo ========================================
echo.

REM Check if keystore exists
if not exist "apps\android\app-release-key.jks" (
    echo ERROR: Keystore not found!
    echo Please create keystore first by running:
    echo   cd apps\android
    echo   keytool -genkey -v -keystore app-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias showoff-key-alias
    echo.
    pause
    exit /b 1
)

REM Check if key.properties exists
if not exist "apps\android\key.properties" (
    echo ERROR: key.properties not found!
    echo Please create apps\android\key.properties with your keystore passwords
    echo.
    pause
    exit /b 1
)

echo Step 1: Cleaning previous builds...
cd apps
call flutter clean

echo.
echo Step 2: Getting dependencies...
call flutter pub get

echo.
echo Step 3: Building release AAB...
call flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Your signed AAB is ready at:
    echo apps\build\app\outputs\bundle\release\app-release.aab
    echo.
    echo File size:
    dir build\app\outputs\bundle\release\app-release.aab | find "app-release.aab"
    echo.
    echo Next steps:
    echo 1. Go to Google Play Console
    echo 2. Upload app-release.aab
    echo 3. Fill in release notes
    echo 4. Submit for review
    echo.
) else (
    echo.
    echo ========================================
    echo   BUILD FAILED!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo.
)

cd ..
pause
