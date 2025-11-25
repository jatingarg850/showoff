@echo off
echo ========================================
echo Phone.email Web Integration Test
echo ========================================
echo.
echo Testing backend endpoint...
echo.

node test_phone_email_web.js

echo.
echo ========================================
echo Test complete!
echo ========================================
echo.
echo To test in browser, open:
echo http://localhost:3000/phone-login-demo
echo.
pause
