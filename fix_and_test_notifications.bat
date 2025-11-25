@echo off
echo ========================================
echo  Notification System Fix and Test
echo ========================================
echo.

echo Step 1: Running diagnostic...
echo.
node diagnose_notifications.js
echo.

echo Step 2: Testing notification flow...
echo.
node test_notification_flow.js
echo.

echo ========================================
echo  Fix Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Restart your server (Ctrl+C then npm start)
echo 2. Hot restart Flutter app (press R)
echo 3. Send a test notification from admin panel
echo.
echo Admin panel: http://localhost:3000/admin/notifications
echo.
pause
