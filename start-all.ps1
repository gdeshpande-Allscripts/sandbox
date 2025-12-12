# Start Mock CDS Hooks Service and Sandbox
Write-Host "Starting Mock CDS Hooks Service and Sandbox..." -ForegroundColor Cyan
Write-Host ""

# Start Mock CDS Service in new window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\mock-cds-service'; npm start"

# Wait a bit for the service to start
Start-Sleep -Seconds 2

# Start CDS Hooks Sandbox in new window  
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; npm run dev"

Write-Host ""
Write-Host "Both services are starting in separate windows:" -ForegroundColor Green
Write-Host "  - Mock CDS Service: http://localhost:3001" -ForegroundColor Yellow
Write-Host "  - CDS Hooks Sandbox: http://localhost:8080" -ForegroundColor Yellow
Write-Host ""
Write-Host "To add the order-sign service in the sandbox:" -ForegroundColor Cyan
Write-Host "  1. Click the '+' button in the sandbox header"
Write-Host "  2. Enter: http://localhost:3001/cds-services"
Write-Host "  3. Click Save"
Write-Host "  4. Navigate to Rx Sign view"
