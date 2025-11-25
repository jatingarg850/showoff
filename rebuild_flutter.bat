@echo off
echo ========================================
echo Flutter Clean Build
echo ========================================
echo.
echo This will clean and rebuild your Flutter app
echo to fix the Google Sign-In initialization error.
echo.
echo ========================================
echo.

cd apps

echo Step 1: Cleaning Flutter build...
call flutter clean

echo.
echo Step 2: Getting dependencies...
call flutter pub get

echo.
echo Step 3: Building and running app...
call flutter run

pause
