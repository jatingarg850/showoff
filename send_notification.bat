@echo off
REM Quick notification sender for Windows
REM Usage: send_notification.bat "Title" "Message" [target]

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: send_notification.bat "Title" "Message" [target]
    echo.
    echo Examples:
    echo   send_notification.bat "Hello" "Welcome to ShowOff" all
    echo   send_notification.bat "Update" "New features available" verified
    echo   send_notification.bat "Bonus" "Claim your coins" active
    echo.
    echo Targets: all, verified, active, new
    exit /b 1
)

set TITLE=%~1
set MESSAGE=%~2
set TARGET=%~3

if "%TARGET%"=="" set TARGET=all

echo.
echo ========================================
echo  Sending Notification
echo ========================================
echo  Title: %TITLE%
echo  Message: %MESSAGE%
echo  Target: %TARGET%
echo ========================================
echo.

cd server
node scripts/sendNotification.js --title "%TITLE%" --message "%MESSAGE%" --target %TARGET%
cd ..

echo.
echo Done!
pause
