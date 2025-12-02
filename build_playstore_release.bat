@echo off
echo ╔════════════════════════════════════════════════════════════╗
echo ║     Building App Bundle for Google Play Store             ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Step 1: Copy release google-services.json
echo [1/6] Copying release google-services.json...
copy /Y "apps\h\google-services.json" "apps\android\app\google-services.json"
if %errorlevel% neq 0 (
    echo ❌ Failed to copy google-services.json
    pause
    exit /b 1
)
echo ✅ Release google-services.json copied
echo.

REM Step 2: Verify keystore exists
echo [2/6] Verifying keystore...
if not exist "apps\key\key.jks" (
    echo ❌ Keystore not found at apps\key\key.jks
    echo Please create keystore first
    pause
    exit /b 1
)
echo ✅ Keystore found at apps\key\key.jks
echo.

REM Step 3: Clean previous builds
echo [3/6] Cleaning previous builds...
cd apps
call flutter clean
if %errorlevel% neq 0 (
    echo ❌ Flutter clean failed
    cd ..
    pause
    exit /b 1
)
echo ✅ Clean completed
echo.

REM Step 4: Get dependencies
echo [4/6] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Flutter pub get failed
    cd ..
    pause
    exit /b 1
)
echo ✅ Dependencies installed
echo.

REM Step 5: Build App Bundle
echo [5/6] Building App Bundle (this may take several minutes)...
echo.
call flutter build appbundle --release
if %errorlevel% neq 0 (
    echo ❌ Build failed
    cd ..
    pause
    exit /b 1
)
echo.
echo ✅ App Bundle built successfully!
echo.

REM Step 6: Show output location
echo [6/6] Build complete!
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                  BUILD SUCCESSFUL                          ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 📦 App Bundle Location:
echo    apps\build\app\outputs\bundle\release\app-release.aab
echo.
echo 📋 Build Information:
echo    Package: com.showoff.life
echo    Release SHA-1: 6a48e4e831b68ec8d4691b273465da605d03d759
echo    Keystore: apps\key\key.jks
echo    Alias: key
echo.
echo 🚀 Next Steps:
echo    1. Upload app-release.aab to Google Play Console
echo    2. Fill in store listing details
echo    3. Submit for review
echo.

cd ..
pause
