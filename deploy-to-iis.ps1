# Quick IIS Deployment Script
# Run as Administrator

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "CDS Hooks Sandbox - IIS Deployment Script" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

# Import WebAdministration module
Import-Module WebAdministration -ErrorAction SilentlyContinue
if (-not (Get-Module WebAdministration)) {
    Write-Host "ERROR: IIS WebAdministration module not found!" -ForegroundColor Red
    Write-Host "Please install IIS with Management Tools" -ForegroundColor Yellow
    pause
    exit
}

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$sandboxPath = Join-Path $scriptPath "build"
$servicePath = Join-Path $scriptPath "mock-cds-service"

# Build the sandbox
Write-Host "Step 1: Building Sandbox..." -ForegroundColor Green
Set-Location $scriptPath
& npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    pause
    exit
}

# Create Sandbox Website
Write-Host ""
Write-Host "Step 2: Creating IIS Website for Sandbox..." -ForegroundColor Green
$sandboxSite = "CDS-Hooks-Sandbox"
$sandboxPort = 8080

# Remove if exists
if (Test-Path "IIS:\Sites\$sandboxSite") {
    Remove-WebSite -Name $sandboxSite
    Write-Host "Removed existing site: $sandboxSite" -ForegroundColor Yellow
}

# Create new site
New-WebSite -Name $sandboxSite -PhysicalPath $sandboxPath -Port $sandboxPort -Force
Write-Host "Created website: $sandboxSite on port $sandboxPort" -ForegroundColor Green

# Set permissions for Sandbox
Write-Host "Setting permissions for Sandbox..." -ForegroundColor Green
$acl = Get-Acl $sandboxPath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS","ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl $sandboxPath $acl

# Create Mock Service Website
Write-Host ""
Write-Host "Step 3: Creating IIS Website for Mock CDS Service..." -ForegroundColor Green
$serviceSite = "CDS-Mock-Service"
$servicePort = 3001

# Remove if exists
if (Test-Path "IIS:\Sites\$serviceSite") {
    Remove-WebSite -Name $serviceSite
    Write-Host "Removed existing site: $serviceSite" -ForegroundColor Yellow
}

# Create new site
New-WebSite -Name $serviceSite -PhysicalPath $servicePath -Port $servicePort -Force
Write-Host "Created website: $serviceSite on port $servicePort" -ForegroundColor Green

# Configure App Pool for Node.js
$appPoolName = $serviceSite
Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "managedRuntimeVersion" -Value ""
Write-Host "Configured App Pool for Node.js (No Managed Code)" -ForegroundColor Green

# Set permissions for Service
Write-Host "Setting permissions for Mock Service..." -ForegroundColor Green
$acl = Get-Acl $servicePath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS","Modify","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl $servicePath $acl

# Start websites
Write-Host ""
Write-Host "Step 4: Starting websites..." -ForegroundColor Green
Start-WebSite -Name $sandboxSite
Start-WebSite -Name $serviceSite

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sandbox URL: http://localhost:$sandboxPort" -ForegroundColor Yellow
Write-Host "Mock Service URL: http://localhost:$servicePort/cds-services" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: Ensure you have installed:" -ForegroundColor Yellow
Write-Host "  1. IIS URL Rewrite Module" -ForegroundColor White
Write-Host "  2. iisnode (for Node.js service)" -ForegroundColor White
Write-Host ""
Write-Host "Test the service:" -ForegroundColor Cyan
Write-Host "  Invoke-RestMethod -Uri http://localhost:$servicePort/cds-services" -ForegroundColor White
Write-Host ""

pause
