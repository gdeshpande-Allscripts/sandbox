@echo off
echo ============================================
echo Building CDS Hooks Sandbox for IIS
echo ============================================
echo.

cd /d "%~dp0"

echo Step 1: Installing dependencies...
call npm install --legacy-peer-deps
if %ERRORLEVEL% NEQ 0 (
    echo Error: npm install failed
    pause
    exit /b 1
)

echo.
echo Step 2: Building production bundle...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo Error: Build failed
    pause
    exit /b 1
)

echo.
echo Step 3: Creating web.config in build folder...
if not exist "build\web.config" (
    echo web.config not found in build folder!
    echo Please ensure web.config was created.
)

echo.
echo ============================================
echo Build Complete!
echo ============================================
echo.
echo Production files are in: %~dp0build
echo.
echo Next steps:
echo 1. Copy build folder to IIS wwwroot or your desired location
echo 2. Create IIS website pointing to the build folder
echo 3. Install URL Rewrite module if not already installed
echo 4. Ensure IIS_IUSRS has read permissions on the folder
echo.
pause
