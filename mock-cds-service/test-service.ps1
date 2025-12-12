# Test the Mock CDS Service with PowerShell
Write-Host "Testing Mock CDS Service with sample request..." -ForegroundColor Cyan
Write-Host ""

$requestBody = Get-Content -Path "test-request.json" -Raw

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3001/cds-services/medication-order-sign-advisor" `
        -Method Post `
        -Body $requestBody `
        -ContentType "application/json"
    
    Write-Host "Response received:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test complete!" -ForegroundColor Cyan
