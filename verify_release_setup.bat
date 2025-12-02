@echo off
echo ╔════════════════════════════════════════════════════════════╗
echo ║          Verifying Play Store Release Setup               ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

set "ERRORS=0"

REM Check 1: Release google-services.json
echo [1/5] Checking release google-services.json...
if exist "apps\h\google-services.json" (
    echo ✅ Release google-services.json found
    findstr /C:"6a48e4e831b68ec8d4691b273465da605d03d759" "apps\h\google-services.json" >nul
    if %errorlevel% equ 0 (
        echo ✅ Correct release SHA-1 fingerprint found
    ) else (
        echo ❌ Release SHA-1 fingerprint not found in google-services.json
        set /a ERRORS+=1
    )
) else (
    echo ❌ Release google-services.json not found at apps\h\google-services.json
    set /a ERRORS+=1
)
echo.

REM Check 2: Keystore
echo [2/5] Checking keystore...
if exist "apps\key\key.jks" (
    echo ✅ Keystore found at apps\key\key.jks
) else (
    echo ❌ Keystore not found at apps\key\key.jks
    set /a ERRORS+=1
)
echo.

REM Check 3: key.properties
echo [3/5] Checking key.properties...
if exist "apps\key\key.properties" (
    echo ✅ key.properties found
    findstr /C:"storeFile=../key/key.jks" "apps\key\key.properties" >nul
    if %errorlevel% equ 0 (
        echo ✅ Correct keystore path configured
    ) else (
        echo ❌ Keystore path not configured correctly
        set /a ERRORS+=1
    )
) else (
    echo ❌ key.properties not found
    set /a ERRORS+=1
)
echo.

REM Check 4: Build configuration
echo [4/5] Checking build.gradle.kts...
if exist "apps\android\app\build.gradle.kts" (
    echo ✅ build.gradle.kts found
    findstr /C:"signingConfig = signingConfigs.getByName(\"release\")" "apps\android\app\build.gradle.kts" >nul
    if %errorlevel% equ 0 (
        echo ✅ Release signing configured
    ) else (
        echo ⚠️  Release signing may not be configured
    )
) else (
    echo ❌ build.gradle.kts not found
    set /a ERRORS+=1
)
echo.

REM Check 5: Flutter installation
echo [5/5] Checking Flutter...
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Flutter is installed
) else (
    echo ❌ Flutter not found in PATH
    set /a ERRORS+=1
)
echo.

REM Summary
echo ╔════════════════════════════════════════════════════════════╗
if %ERRORS% equ 0 (
    echo ║                  ✅ ALL CHECKS PASSED                      ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo 🎉 Your setup is ready for Play Store release!
    echo.
    echo 📋 Configuration Summary:
    echo    Package Name: com.showoff.life
    echo    Release SHA-1: 6a48e4e831b68ec8d4691b273465da605d03d759
    echo    Keystore: apps\key\key.jks
    echo    Alias: key
    echo.
    echo 🚀 Run build_playstore_release.bat to build the app bundle
) else (
    echo ║              ❌ %ERRORS% ERROR(S) FOUND                          ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo ⚠️  Please fix the errors above before building
)
echo.

pause
