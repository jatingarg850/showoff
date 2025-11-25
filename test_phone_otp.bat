@echo off
echo Testing Phone.email OTP Integration
echo.
echo Sending OTP to: +919811226924
echo Using Client ID: 16687983578815655151
echo.
echo Sending request to Phone.email API...
echo.

curl.exe -X POST "https://api.phone.email/auth/v1/otp" ^
  -H "Content-Type: application/json" ^
  -H "X-Client-Id: 16687983578815655151" ^
  -H "X-API-Key: I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf" ^
  -d "{\"phone_number\":\"+919811226924\"}" ^
  -v

echo.
echo.
echo Test completed!
pause
