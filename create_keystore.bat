@echo off
echo Creating Android Keystore for ShowOff.life...
echo.

cd apps\android

keytool -genkey -v -keystore app-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias showoff-key-alias

echo.
echo Keystore created successfully!
echo Location: apps\android\app-release-key.jks
echo.
echo IMPORTANT: Save the password you entered!
echo You'll need it for future app updates.
pause
