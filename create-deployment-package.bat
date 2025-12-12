@echo off
echo ============================================
echo Creating IIS Deployment Package
echo ============================================
echo.

set PACKAGE_DIR=C:\IIS-Deployment-Package
set SANDBOX_DIR=%PACKAGE_DIR%\CDS-Sandbox
set SERVICE_DIR=%PACKAGE_DIR%\CDS-Service

echo Creating package directories...
if exist "%PACKAGE_DIR%" rd /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%"
mkdir "%SANDBOX_DIR%"
mkdir "%SERVICE_DIR%"

echo.
echo Copying Sandbox files from build folder...
xcopy /E /I /Y "build\*" "%SANDBOX_DIR%"

echo.
echo Copying Mock CDS Service files...
xcopy /E /I /Y "mock-cds-service\*" "%SERVICE_DIR%"

echo.
echo Removing unnecessary files from service package...
if exist "%SERVICE_DIR%\test-request.json" del "%SERVICE_DIR%\test-request.json"
if exist "%SERVICE_DIR%\test-service.ps1" del "%SERVICE_DIR%\test-service.ps1"
if exist "%SERVICE_DIR%\test-service.bat" del "%SERVICE_DIR%\test-service.bat"

echo.
echo Creating deployment instructions...
(
echo ================================================================
echo   CDS Hooks Sandbox - IIS Deployment Package
echo   Created: %date% %time%
echo ================================================================
echo.
echo CONTENTS:
echo   - CDS-Sandbox\     : Static website files ^(Sandbox UI^)
echo   - CDS-Service\     : Node.js service files ^(Mock CDS Service^)
echo   - INSTRUCTIONS.txt : This file
echo.
echo ================================================================
echo PREREQUISITES:
echo ================================================================
echo.
echo 1. IIS with Static Content feature enabled
echo 2. URL Rewrite Module for IIS
echo    Download: https://www.iis.net/downloads/microsoft/url-rewrite
echo.
echo 3. iisnode for Node.js applications
echo    Download: https://github.com/Azure/iisnode/releases
echo.
echo 4. Node.js installed on the server
echo    Download: https://nodejs.org/
echo.
echo ================================================================
echo DEPLOYMENT STEPS:
echo ================================================================
echo.
echo PART 1: Deploy CDS Sandbox ^(Static Website^)
echo -----------------------------------------------
echo.
echo 1. Copy CDS-Sandbox folder to: C:\inetpub\wwwroot\CDS-Sandbox
echo    ^(or your preferred location^)
echo.
echo 2. Open IIS Manager
echo.
echo 3. Create New Website:
echo    - Site name: CDS-Hooks-Sandbox
echo    - Physical path: C:\inetpub\wwwroot\CDS-Sandbox
echo    - Port: 8080
echo.
echo 4. Set Permissions:
echo    - Right-click folder ^> Properties ^> Security
echo    - Add IIS_IUSRS with Read ^& Execute permissions
echo.
echo 5. The web.config file is already included for SPA routing
echo.
echo ================================================================
echo.
echo PART 2: Deploy Mock CDS Service ^(Node.js^)
echo -----------------------------------------------
echo.
echo 1. Copy CDS-Service folder to: C:\inetpub\wwwroot\CDS-Service
echo    ^(or your preferred location^)
echo.
echo 2. Open Command Prompt in the service folder and run:
echo    npm install
echo.
echo 3. Open IIS Manager
echo.
echo 4. Create New Website:
echo    - Site name: CDS-Mock-Service
echo    - Physical path: C:\inetpub\wwwroot\CDS-Service
echo    - Port: 3001
echo.
echo 5. Configure Application Pool:
echo    - Select the app pool for CDS-Mock-Service
echo    - Set .NET CLR version: No Managed Code
echo    - Set Pipeline mode: Integrated
echo.
echo 6. Set Permissions:
echo    - Right-click folder ^> Properties ^> Security
echo    - Add IIS_IUSRS with Modify permissions
echo.
echo 7. The web.config file is already included for iisnode
echo.
echo ================================================================
echo TESTING:
echo ================================================================
echo.
echo 1. Test Sandbox:
echo    Open browser: http://localhost:8080
echo.
echo 2. Test Mock Service:
echo    Open browser: http://localhost:3001/cds-services
echo    You should see JSON with available services
echo.
echo 3. Connect Sandbox to Service:
echo    - In sandbox, click "+" button
echo    - Enter: http://localhost:3001/cds-services
echo    - Click Add
echo    - Navigate to Rx Sign view to test
echo.
echo ================================================================
echo TROUBLESHOOTING:
echo ================================================================
echo.
echo Sandbox Issues:
echo - 404 on refresh: Ensure URL Rewrite module is installed
echo - 403 Forbidden: Check IIS_IUSRS permissions
echo - Blank page: Check browser console for errors
echo.
echo Mock Service Issues:
echo - 500.1001 error: Ensure iisnode is installed
echo - Cannot find module: Run npm install in service folder
echo - Port conflict: Change port binding in IIS
echo.
echo For HTTPS: Configure SSL certificate in IIS bindings
echo.
echo ================================================================
) > "%PACKAGE_DIR%\INSTRUCTIONS.txt"

echo.
echo ============================================
echo Package Created Successfully!
echo ============================================
echo.
echo Location: %PACKAGE_DIR%
echo.
echo Contents:
dir "%PACKAGE_DIR%" /B
echo.
echo Next steps:
echo 1. Copy C:\IIS-Deployment-Package to your IIS server
echo 2. Follow instructions in INSTRUCTIONS.txt
echo.
pause
