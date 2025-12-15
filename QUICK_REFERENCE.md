# 🚀 Quick Reference Card

## Server URLs
```
HTTP:   http://3.110.103.187
HTTPS:  https://3.110.103.187
SSH:    ssh -i showoff-key.pem ec2-user@3.110.103.187
```

## Health Check
```bash
curl http://3.110.103.187/health
```

## Send OTP
```bash
curl -X POST http://3.110.103.187/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "9876543210", "countryCode": "91"}'
```

## Verify OTP
```bash
curl -X POST http://3.110.103.187/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "9876543210", "countryCode": "91", "otp": "123456"}'
```

## PM2 Commands
```bash
pm2 list                    # Show all processes
pm2 logs showoff-api        # View logs
pm2 restart showoff-api     # Restart server
pm2 stop showoff-api        # Stop server
pm2 start showoff-api       # Start server
```

## Update .env
```bash
ssh -i showoff-key.pem ec2-user@3.110.103.187
nano ~/showoff-server/server/.env
# Edit and save (Ctrl+X, Y, Enter)
pm2 restart showoff-api
```

## View Nginx Logs
```bash
ssh -i showoff-key.pem ec2-user@3.110.103.187
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Flutter App Config
```dart
// apps/lib/config/api_config.dart
static String get baseUrl => 'http://3.110.103.187/api';
static String get wsUrl => 'http://3.110.103.187';
```

## AuthKey Setup
1. Go to https://console.authkey.io
2. Get API Key
3. Create SMS template with {#2fa#}
4. Get Template SID
5. Update .env:
   ```
   AUTHKEY_API_KEY=your_key
   AUTHKEY_TEMPLATE_ID=your_template_id
   ```
6. Restart server

## Status Check
```bash
# Server running?
curl http://3.110.103.187/health

# PM2 process?
ssh -i showoff-key.pem ec2-user@3.110.103.187 "pm2 list"

# Nginx running?
ssh -i showoff-key.pem ec2-user@3.110.103.187 "sudo systemctl status nginx"
```

## Emergency Restart
```bash
ssh -i showoff-key.pem ec2-user@3.110.103.187
pm2 restart showoff-api
pm2 logs showoff-api
```

## Key Files
- Server: `server/aws-server.js`
- Config: `server/.env`
- OTP Service: `server/services/authkeyService.js`
- Flutter Config: `apps/lib/config/api_config.dart`
- Nginx: `/etc/nginx/conf.d/showoff.conf`
- SSL: `/etc/ssl/certs/server.crt` & `/etc/ssl/private/server.key`

## Credentials
- **AWS Key:** `C:\Users\coddy\showoff-key.pem`
- **Server IP:** `3.110.103.187`
- **Region:** `ap-south-1` (Mumbai)
- **Instance ID:** `i-04dcb82f3e2050956`

## Ports
- HTTP: 80 (Nginx)
- HTTPS: 443 (Nginx)
- Node.js HTTP: 3000
- Node.js HTTPS: 3443
- SSH: 22

## Monitoring
- **Health:** http://3.110.103.187/health
- **Logs:** `pm2 logs showoff-api`
- **Status:** `pm2 list`
- **Nginx:** `sudo systemctl status nginx`

## Common Issues
| Issue | Fix |
|-------|-----|
| Server not responding | `pm2 restart showoff-api` |
| HTTPS not working | Check certificate: `openssl x509 -in /etc/ssl/certs/server.crt -text` |
| OTP not sending | Check AuthKey API key in .env |
| 404 on endpoints | Check Nginx config: `/etc/nginx/conf.d/showoff.conf` |

## Documentation
- Complete Setup: `COMPLETE_SETUP_SUMMARY.md`
- HTTPS Guide: `HTTPS_HTTP_SETUP_COMPLETE.md`
- OTP Guide: `AUTHKEY_OTP_HTTPS_GUIDE.md`
- OTP Setup: `AUTHKEY_OTP_SETUP_SUMMARY.md`

---

**Status:** 🟢 ONLINE & SECURE
**Protocol:** HTTP ✅ HTTPS ✅
**OTP:** AuthKey.io ✅
