@echo off
echo Testing Mock CDS Service with sample request...
echo.

curl -X POST http://localhost:3001/cds-services/medication-order-sign-advisor ^
  -H "Content-Type: application/json" ^
  -d @test-request.json

echo.
echo.
echo Test complete!
pause
