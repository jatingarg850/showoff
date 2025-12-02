@echo off
echo ========================================
echo   Starting Kafka for ShowOff.life
echo ========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

echo Starting Kafka cluster...
docker-compose -f docker-compose.kafka.yml up -d

echo.
echo Waiting for Kafka to be ready...
timeout /t 10 /nobreak >nul

echo.
echo ========================================
echo   Kafka Started Successfully!
echo ========================================
echo.
echo Kafka Broker: localhost:9092
echo Kafka UI: http://localhost:8080
echo.
echo To stop Kafka:
echo   docker-compose -f docker-compose.kafka.yml down
echo.
echo To view logs:
echo   docker-compose -f docker-compose.kafka.yml logs -f
echo.
pause
