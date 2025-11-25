@echo off
echo ========================================
echo  Firebase Setup Verification
echo ========================================
echo.

echo Checking for required files...
echo.

REM Check google-services.json
if exist "apps\android\app\google-services.json" (
    echo [OK] google-services.json found
) else (
    echo [MISSING] google-services.json NOT found
    echo          Place it in: apps\android\app\google-services.json
)

echo.

REM Check firebase-service-account.json
if exist "server\firebase-service-account.json" (
    echo [OK] firebase-service-account.json found
) else (
    echo [MISSING] firebase-service-account.json NOT found
    echo          Place it in: server\firebase-service-account.json
)

echo.
echo ========================================

REM If both files exist, offer to rebuild
if exist "apps\android\app\google-services.json" if exist "server\firebase-service-account.json" (
    echo.
    echo All files found! Ready to rebuild.
    echo.
    choice /C YN /M "Do you want to rebuild the Flutter app now"
    if errorlevel 2 goto :end
    if errorlevel 1 goto :rebuild
) else (
    echo.
    echo Please add the missing files first.
    echo See GET_FIREBASE_FILES.md for instructions.
    echo.
    pause
    goto :end
)

:rebuild
echo.
echo Rebuilding Flutter app...
cd apps
flutter clean
flutter pub get
echo.
echo Build complete! Now run: flutter run
cd ..
pause
goto :end

:end
