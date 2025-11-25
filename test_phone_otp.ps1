# PowerShell script to test Phone.email OTP Integration
# Client ID: 16687983578815655151
# API Key: I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf
# Test Phone: +919811226924

Write-Host "Testing Phone.email OTP Integration" -ForegroundColor Cyan
Write-Host ""

# Force TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$clientId = "16687983578815655151"
$apiKey = "I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf"
$phoneNumber = "+919811226924"

Write-Host "Sending OTP to: $phoneNumber" -ForegroundColor Yellow
Write-Host "Using Client ID: $clientId" -ForegroundColor Yellow
Write-Host ""

$headers = @{
    "Content-Type" = "application/json"
    "X-Client-Id" = $clientId
    "X-API-Key" = $apiKey
}

$body = @{
    phone_number = $phoneNumber
} | ConvertTo-Json

try {
    Write-Host "Sending request to Phone.email API..." -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri "https://api.phone.email/auth/v1/otp" `
        -Method Post `
        -Headers $headers `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host ""
    Write-Host "SUCCESS! OTP sent successfully" -ForegroundColor Green
    Write-Host "Session ID: $($response.session_id)" -ForegroundColor Green
    Write-Host "Expires in: $($response.expires_in) seconds" -ForegroundColor Green
    Write-Host ""
    Write-Host "Check your phone for the OTP code!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Full Response:" -ForegroundColor White
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host ""
    Write-Host "FAILED to send OTP" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    
    if ($_.ErrorDetails.Message) {
        Write-Host "Error Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Cyan
