@echo off
echo ========================================
echo Starting Backend Server
echo ========================================
echo.

cd backend

echo Checking Maven...
mvn --version
if errorlevel 1 (
    echo ERROR: Maven not found! Please install Maven first.
    pause
    exit /b 1
)

echo.
echo Starting Spring Boot application...
echo Backend will run on: http://localhost:8080
echo API Base URL: http://localhost:8080/api
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

mvn spring-boot:run

pause
