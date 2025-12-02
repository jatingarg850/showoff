@echo off
echo ========================================
echo   Kafka Setup for ShowOff.life
echo ========================================
echo.

echo Step 1: Installing Node.js dependencies...
cd server
call npm install kafkajs
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo Step 2: Checking Docker...
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Docker is not running!
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    echo.
    echo After installing Docker, run: start-kafka.bat
    pause
    exit /b 0
)

echo.
echo Step 3: Starting Kafka cluster...
docker-compose -f docker-compose.kafka.yml up -d

echo.
echo Step 4: Waiting for Kafka to initialize...
timeout /t 15 /nobreak >nul

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Edit server/.env and set: KAFKA_ENABLED=true
echo 2. Start your server: npm start
echo 3. Access Kafka UI: http://localhost:8080
echo.
echo Documentation: KAFKA_SETUP_COMPLETE.md
echo.
pause
