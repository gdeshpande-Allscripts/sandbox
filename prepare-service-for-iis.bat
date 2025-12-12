@echo off
echo ============================================
echo Preparing Mock CDS Service for IIS
echo ============================================
echo.

cd /d "%~dp0mock-cds-service"

echo Step 1: Installing dependencies...
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo Error: npm install failed
    pause
    exit /b 1
)

echo.
echo Step 2: Verifying web.config exists...
if not exist "web.config" (
    echo ERROR: web.config not found!
    echo Please ensure web.config was created in mock-cds-service folder.
    pause
    exit /b 1
)

echo.
echo Step 3: Creating iisnode folder for logs...
if not exist "iisnode" mkdir iisnode

echo.
echo ============================================
echo Preparation Complete!
echo ============================================
echo.
echo Service files are in: %~dp0mock-cds-service
echo.
echo Next steps:
echo 1. Install iisnode from https://github.com/Azure/iisnode/releases
echo 2. Create IIS website pointing to mock-cds-service folder
echo 3. Set Application Pool to "No Managed Code"
echo 4. Ensure IIS_IUSRS has Modify permissions
echo 5. Bind to port 3001 (or configure your preferred port)
echo.
pause
