@echo off
echo ========================================
echo Restarting Server
echo ========================================
echo.
echo This will help fix the 405 error by
echo restarting the server with updated routes.
echo.
echo ========================================
echo.
echo Please follow these steps:
echo.
echo 1. Go to the terminal where server is running
echo 2. Press Ctrl+C to stop the server
echo 3. Run: npm start
echo.
echo OR
echo.
echo Open a NEW terminal and run:
echo    cd server
echo    npm start
echo.
echo ========================================
echo.
echo After server restarts, test with:
echo    http://localhost:3000/phone-login-demo
echo.
echo Or run diagnostics:
echo    node diagnose_405.js
echo.
pause
