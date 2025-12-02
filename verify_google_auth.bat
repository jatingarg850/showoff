@echo off
echo ========================================
echo Google Auth Configuration Checker
echo ========================================
echo.

echo Checking SHA-1 Fingerprints...
echo.

cd apps\android
call gradlew signingReport | findstr "SHA1"

echo.
echo ========================================
echo IMPORTANT: Add these to Firebase Console
echo ========================================
echo.
echo 1. Go to: https://console.firebase.google.com/project/showofflife-life/settings/general
echo 2. Scroll to "SHA certificate fingerprints"
echo 3. Add BOTH SHA-1 fingerprints shown above
echo 4. Wait 2-3 minutes for changes to sync
echo 5. Hot restart your app
echo.
echo ========================================

pause
