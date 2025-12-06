# Start Server - Simple Method (No PM2)

## You're in CloudShell - Let's Start the Server Directly

### Step 1: Install PM2 Globally

```bash
npm install -g pm2
```

### Step 2: Start Server with PM2

```bash
pm2 start server.js --name "showoff-api"
```

### Step 3: Save PM2 Configuration

```bash
pm2 save
sudo pm2 startup
```

### Step 4: View Logs

```bash
pm2 logs showoff-api
```

---

## Alternative: Start Without PM2

If PM2 doesn't work, start directly:

```bash
node server.js
```

---

## Configure Nginx

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

## Test Server

```bash
curl http://3.110.103.187:3000/api/health
```

Should return: `{"status": "ok"}`

---

## Quick Commands

```bash
# View logs
pm2 logs showoff-api

# Restart
pm2 restart showoff-api

# Stop
pm2 stop showoff-api

# Status
pm2 list

# Monitor
pm2 monit
```

---

## If You're on Local Machine

You need to SSH into EC2 first:

```bash
ssh -i C:\Users\coddy\showoff-key.pem ec2-user@3.110.103.187
```

Then run the commands above.

---

## Your Server Details

- **IP:** 3.110.103.187
- **Port:** 3000
- **API URL:** http://3.110.103.187:3000/api
- **WebSocket:** ws://3.110.103.187:3000

---

## Next: Update Flutter App

Edit `apps/lib/config/api_config.dart`:

```dart
static String get baseUrl {
  return 'http://3.110.103.187:3000/api';
}

static String get wsUrl {
  return 'http://3.110.103.187:3000';
}
```

---

## Done! 🎉

Your server is now running on AWS!
