# CloudShell Commands - Run These Now

## You're Currently In: `/home/cloudshell-user/showoff-server/server`

---

## Step 1: Install PM2 Globally

```bash
npm install -g pm2
```

**Wait for it to complete**

---

## Step 2: Start Server with PM2

```bash
pm2 start server.js --name "showoff-api"
```

**You should see:**
```
[PM2] Spawning /home/cloudshell-user/showoff-server/server/server.js
[PM2] App [showoff-api] started
```

---

## Step 3: Save PM2 Configuration

```bash
pm2 save
```

---

## Step 4: Enable PM2 Startup

```bash
sudo pm2 startup
```

---

## Step 5: View Logs

```bash
pm2 logs showoff-api
```

**You should see:**
```
✅ Server running on port 3000
✅ Connected to MongoDB
✅ WebSocket server started
```

---

## Step 6: Configure Nginx

**Copy and paste this entire block:**

```bash
sudo tee /etc/nginx/conf.d/showoff.conf > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /socket.io {
        proxy_pass http://localhost:3000/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
EOF

sudo nginx -t
sudo systemctl restart nginx
```

---

## Step 7: Test Your Server

**From your local machine (PowerShell):**

```bash
curl http://3.110.103.187:3000/api/health
```

**Expected response:**
```json
{"status": "ok"}
```

---

## Step 8: Update Flutter App

**Edit file:** `apps/lib/config/api_config.dart`

**Replace these methods:**

```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://3.110.103.187:3000/api';
  } else if (Platform.isIOS) {
    return 'http://3.110.103.187:3000/api';
  } else {
    return 'http://localhost:3000/api';
  }
}

static String get wsUrl {
  if (Platform.isAndroid) {
    return 'http://3.110.103.187:3000';
  } else if (Platform.isIOS) {
    return 'http://3.110.103.187:3000';
  } else {
    return 'http://localhost:3000';
  }
}
```

---

## 🎉 Done!

Your server is now live at: **http://3.110.103.187:3000**

---

## 📋 Useful Commands

### View Logs
```bash
pm2 logs showoff-api
```

### Restart Server
```bash
pm2 restart showoff-api
```

### Stop Server
```bash
pm2 stop showoff-api
```

### Check Status
```bash
pm2 list
```

### Monitor Server
```bash
pm2 monit
```

### View Nginx Logs
```bash
sudo tail -f /var/log/nginx/error.log
```

### Restart Nginx
```bash
sudo systemctl restart nginx
```

### Check Nginx Status
```bash
sudo systemctl status nginx
```

### Edit .env File
```bash
nano .env
```

### Restart After .env Changes
```bash
pm2 restart showoff-api
```

---

## ✅ Verification Checklist

- [ ] PM2 installed globally
- [ ] Server started with PM2
- [ ] PM2 configuration saved
- [ ] Nginx configured
- [ ] API responding at http://3.110.103.187:3000/api/health
- [ ] Flutter app updated with server IP
- [ ] Logs showing no errors

---

## 🆘 Troubleshooting

### Server not starting?
```bash
pm2 logs showoff-api
```

### Port 3000 already in use?
```bash
sudo lsof -i :3000
```

### Nginx not working?
```bash
sudo nginx -t
sudo systemctl status nginx
```

### Need to restart everything?
```bash
pm2 restart showoff-api
sudo systemctl restart nginx
```

---

## Your Server Details

- **IP:** 3.110.103.187
- **Port:** 3000
- **API URL:** http://3.110.103.187:3000/api
- **WebSocket:** ws://3.110.103.187:3000
- **Region:** ap-south-1 (Mumbai)
- **Instance:** t2.micro (free tier)

---

**Your server is ready to go!** 🚀
