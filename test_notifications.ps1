# PowerShell script to test notifications
Write-Host "🧪 Testing ShowOff.life Notification System" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Step 1: Check server health
Write-Host "`n1. Checking server health..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method GET
    $healthData = $healthResponse.Content | ConvertFrom-Json
    Write-Host "✅ Server Status: $($healthData.message)" -ForegroundColor Green
    Write-Host "✅ WebSocket Enabled: $($healthData.websocket.enabled)" -ForegroundColor Green
    Write-Host "✅ Active Connections: $($healthData.websocket.activeConnections)" -ForegroundColor Green
} catch {
    Write-Host "❌ Server not accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Get auth token
Write-Host "`n2. Please provide your login credentials:" -ForegroundColor Yellow
$email = Read-Host "Enter your email/phone"
$password = Read-Host "Enter your password" -AsSecureString
$passwordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

Write-Host "`n3. Logging in..." -ForegroundColor Yellow
try {
    $loginBody = @{
        emailOrPhone = $email
        password = $passwordText
    } | ConvertTo-Json

    $loginResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $loginData = $loginResponse.Content | ConvertFrom-Json
    
    if ($loginData.success) {
        $token = $loginData.data.token
        $username = $loginData.data.user.username
        Write-Host "✅ Login successful! Welcome $username" -ForegroundColor Green
    } else {
        Write-Host "❌ Login failed: $($loginData.message)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Login error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 4: Test direct notification
Write-Host "`n4. Testing direct notification..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $notificationResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/notifications/test/direct" -Method POST -Headers $headers
    $notificationData = $notificationResponse.Content | ConvertFrom-Json
    
    if ($notificationData.success) {
        Write-Host "✅ Direct notification created successfully!" -ForegroundColor Green
        Write-Host "✅ Notification ID: $($notificationData.notificationId)" -ForegroundColor Green
        Write-Host "📱 Check your phone and app for the notification!" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Notification creation failed: $($notificationData.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Notification test error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Test other notification types
Write-Host "`n5. Testing other notification types..." -ForegroundColor Yellow

$testTypes = @("like", "comment", "follow")
foreach ($type in $testTypes) {
    try {
        Write-Host "Testing $type notification..." -ForegroundColor Gray
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/notifications/test/$type" -Method POST -Headers $headers
        $data = $response.Content | ConvertFrom-Json
        
        if ($data.success) {
            Write-Host "✅ $type notification: $($data.message)" -ForegroundColor Green
        } else {
            Write-Host "❌ $type notification failed: $($data.message)" -ForegroundColor Red
        }
        Start-Sleep -Seconds 1
    } catch {
        Write-Host "❌ $type notification error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 6: Check notifications
Write-Host "`n6. Checking your notifications..." -ForegroundColor Yellow
try {
    $notificationsResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/notifications?page=1&limit=10" -Method GET -Headers $headers
    $notificationsData = $notificationsResponse.Content | ConvertFrom-Json
    
    if ($notificationsData.success) {
        $count = $notificationsData.data.Count
        $unreadCount = $notificationsData.unreadCount
        Write-Host "✅ Total notifications: $count" -ForegroundColor Green
        Write-Host "✅ Unread notifications: $unreadCount" -ForegroundColor Green
        
        if ($count -gt 0) {
            Write-Host "`nRecent notifications:" -ForegroundColor Cyan
            $notificationsData.data | Select-Object -First 3 | ForEach-Object {
                $sender = if ($_.sender.displayName) { $_.sender.displayName } else { $_.sender.username }
                Write-Host "  • $($_.type): $sender - $($_.message)" -ForegroundColor White
            }
        }
    }
} catch {
    Write-Host "❌ Error fetching notifications: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Notification test completed!" -ForegroundColor Cyan
Write-Host "Check your Flutter app and phone for notifications!" -ForegroundColor Yellow
Write-Host "`nIf notifications appeared, the system is working! 🚀" -ForegroundColor Green
Write-Host "If not, check the DEBUG_NOTIFICATIONS.md file for troubleshooting." -ForegroundColor Yellow