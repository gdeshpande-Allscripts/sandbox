@echo off
echo Starting Mock CDS Hooks Service and Sandbox...
echo.

start "Mock CDS Service" cmd /k "cd mock-cds-service && npm start"
timeout /t 2 /nobreak >nul

start "CDS Hooks Sandbox" cmd /k "npm run dev"

echo.
echo Both services are starting in separate windows:
echo   - Mock CDS Service: http://localhost:3001
echo   - CDS Hooks Sandbox: http://localhost:8080
echo.
echo To add the order-sign service in the sandbox:
echo   1. Click the "+" button in the sandbox header
echo   2. Enter: http://localhost:3001/cds-services
echo   3. Click Save
echo   4. Navigate to Rx Sign view
