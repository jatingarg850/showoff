@echo off
echo ========================================
echo Phone.email Integration - Quick Start
echo ========================================
echo.

echo Step 1: Checking if server is running...
echo.
node test_server_health.js

echo.
echo ========================================
echo.
echo If server is NOT running, please:
echo 1. Open a new terminal
echo 2. Run: cd server
echo 3. Run: npm start
echo.
echo Then run this script again.
echo.
echo If server IS running:
echo Open your browser to:
echo http://localhost:3000/phone-login-demo
echo.
echo ========================================
pause
