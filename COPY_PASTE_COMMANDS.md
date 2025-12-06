# Copy-Paste Commands for AWS Deployment

## Your Server IP: 3.110.103.187

---

## 1️⃣ SSH into Your Server

```bash
ssh -i C:\Users\coddy\showoff-key.pem ec2-user@3.110.103.187
```

---

## 2️⃣ Clone Repository

```bash
cd /home/ec2-user
git clone https://github.com/YOUR_USERNAME/showoff-server.git showoff-server
cd showoff-server
```

**⚠️ Replace `YOUR_USERNAME` with your GitHub username**

---

## 3️⃣ Install Dependencies

```bash
npm install
```

---

## 4️⃣ Create .env File

```bash
nano .env
```

**Copy and paste this entire block:**

```env
PORT=3000
NODE_ENV=production

# MongoDB Configuration
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/showoff_life

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=30d

# AWS S3 Configuration
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=ap-south-1
AWS_S3_BUCKET=showoff-life-bucket

# Wasabi Configuration
WASABI_ACCESS_KEY_ID=your_wasabi_key
WASABI_SECRET_ACCESS_KEY=your_wasabi_secret
WASABI_BUCKET_NAME=showoff-bucket
WASABI_REGION=ap-southeast-1
WASABI_ENDPOINT=https://s3.ap-southeast-1.wasabisys.com

# Payment Keys
RAZORPAY_KEY_ID=your_razorpay_key
RAZORPAY_KEY_SECRET=your_razorpay_secret
STRIPE_PUBLISHABLE_KEY=your_stripe_pub_key
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=your_webhook_secret

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id

# AuthKey
AUTHKEY_API_KEY=your_authkey_api_key

# Phone.Email
PHONE_EMAIL_CLIENT_ID=your_phone_email_id
PHONE_EMAIL_API_KEY=your_phone_email_key

# Kafka (optional)
KAFKA_ENABLED=false
KAFKA_BROKERS=localhost:9092
```

**Save:** `Ctrl+X` → `Y` → `Enter`

---

## 5️⃣ Start Server with PM2

```bash
pm2 start server.js --name "showoff-api"
pm2 save
sudo pm2 startup
pm2 logs showoff-api
```

---

## 6️⃣ Configure Nginx

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

## 7️⃣ Test Your Server

**From your local machine (PowerShell):**

```bash
curl http://3.110.103.187:3000/api/health
```

**Expected response:**
```json
{"status": "ok"}
```

---

## 8️⃣ Update Flutter App

**Edit file:** `apps/lib/config/api_config.dart`

**Replace the baseUrl and wsUrl methods:**

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

## 🔧 Useful Commands

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
nano /home/ec2-user/showoff-server/.env
```

### Restart After .env Changes
```bash
pm2 restart showoff-api
```

---

## 🆘 Troubleshooting Commands

### Server not responding?
```bash
pm2 logs showoff-api
pm2 restart showoff-api
```

### Check if port 3000 is open
```bash
sudo netstat -tlnp | grep 3000
```

### Check if Nginx is running
```bash
sudo systemctl status nginx
```

### Test Nginx config
```bash
sudo nginx -t
```

### Check disk space
```bash
df -h
```

### Check memory
```bash
free -h
```

### Check running processes
```bash
ps aux | grep node
```

---

## 📋 Step-by-Step Summary

1. SSH into server
2. Clone repository
3. Install dependencies
4. Create .env file
5. Start server with PM2
6. Configure Nginx
7. Test API endpoint
8. Update Flutter app

---

## ✅ Verification

After each step, verify:

**After Step 5 (PM2):**
```bash
pm2 list
pm2 logs showoff-api
```

**After Step 6 (Nginx):**
```bash
sudo nginx -t
sudo systemctl status nginx
```

**After Step 7 (Test):**
```bash
curl http://3.110.103.187:3000/api/health
```

---

## 🎉 Done!

Your server is now live at: **http://3.110.103.187:3000**

API endpoint: **http://3.110.103.187:3000/api**

WebSocket: **ws://3.110.103.187:3000**
