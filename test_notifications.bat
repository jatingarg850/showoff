@echo off
echo 🧪 Testing ShowOff.life Notification System
echo =========================================

echo.
echo 1. Checking server health...
curl -s http://localhost:3000/health

echo.
echo.
echo 2. To test notifications, you need to:
echo    a) Get your auth token by logging in
echo    b) Use the token to test notifications

echo.
echo Example commands:
echo.
echo Login (replace with your credentials):
echo curl -X POST http://localhost:3000/api/auth/login ^
echo   -H "Content-Type: application/json" ^
echo   -d "{\"emailOrPhone\": \"your_email\", \"password\": \"your_password\"}"

echo.
echo Test notification (replace YOUR_TOKEN):
echo curl -X POST http://localhost:3000/api/notifications/test/direct ^
echo   -H "Authorization: Bearer YOUR_TOKEN"

echo.
echo 📱 For easier testing, run: powershell -ExecutionPolicy Bypass -File test_notifications.ps1
echo.
pause