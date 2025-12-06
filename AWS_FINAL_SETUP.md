# AWS Final Setup - Your Server IP: 3.110.103.187

## ✅ What's Done

- ✅ Node.js 18.20.8 installed
- ✅ PM2 installed
- ✅ Nginx 1.28.0 installed
- ✅ Git installed
- ✅ EC2 instance running

---

## 🚀 Next Steps (Do These Now)

### Step 1: SSH into Your Server

```bash
ssh -i C:\Users\coddy\showoff-key.pem ec2-user@3.110.103.187
```

### Step 2: Clone Your Repository

```bash
cd /home/ec2-user
git clone https://github.com/YOUR_USERNAME/showoff-server.git showoff-server
cd showoff-server
```

**Replace `YOUR_USERNAME` with your actual GitHub username**

### Step 3: Install Dependencies

```bash
npm install
```

### Step 4: Create .env File

```bash
nano .env
```

Paste this and update with your credentials:

```env
PORT=3000
NODE_ENV=production

# MongoDB
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/showoff_life

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=30d

# AWS S3
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=ap-south-1
AWS_S3_BUCKET=showoff-life-bucket

# Wasabi
WASABI_ACCESS_KEY_ID=your_wasabi_key
WASABI_SECRET_ACCESS_KEY=your_wasabi_secret
WASABI_BUCKET_NAME=showoff-bucket
WASABI_REGION=ap-southeast-1
WASABI_ENDPOINT=https://s3.ap-southeast-1.wasabisys.com

# Payment
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

# Kafka
KAFKA_ENABLED=false
KAFKA_BROKERS=localhost:9092
```

Save: `Ctrl+X` → `Y` → `Enter`

### Step 5: Start Server

```bash
pm2 start server.js --name "showoff-api"
pm2 save
sudo pm2 startup
pm2 logs showoff-api
```

### Step 6: Configure Nginx

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

### Step 7: Test

From your local machine:

```bash
curl http://3.110.103.187:3000/api/health
```

Should return: `{"status": "ok"}`

### Step 8: Update Flutter App

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

## 📋 Quick Commands

```bash
# SSH into server
ssh -i C:\Users\coddy\showoff-key.pem ec2-user@3.110.103.187

# View logs
pm2 logs showoff-api

# Restart server
pm2 restart showoff-api

# Stop server
pm2 stop showoff-api

# Check status
pm2 list

# Monitor
pm2 monit

# View Nginx logs
sudo tail -f /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx
```

---

## ✅ Verification Checklist

- [ ] SSH connection successful
- [ ] Repository cloned
- [ ] Dependencies installed
- [ ] .env file created with credentials
- [ ] Server started with PM2
- [ ] Nginx configured
- [ ] API responding at http://3.110.103.187:3000/api/health
- [ ] Flutter app updated with server IP
- [ ] Logs showing no errors

---

## 🎉 You're Done!

Your server is now live at: **http://3.110.103.187:3000**

---

## 🆘 Troubleshooting

### Server not responding?
```bash
pm2 logs showoff-api
pm2 restart showoff-api
```

### Database connection failed?
- Check MONGODB_URI in .env
- Verify IP whitelist in MongoDB Atlas

### Port 3000 not accessible?
- Check security group allows port 3000
- Check Nginx is running: `sudo systemctl status nginx`

### WebSocket not connecting?
- Check Nginx config: `sudo nginx -t`
- Restart Nginx: `sudo systemctl restart nginx`

---

## 📞 Support

For detailed guides, see:
- `AWS_DEPLOYMENT_GUIDE.md` - Complete reference
- `AWS_ENV_SETUP.md` - Environment configuration
- `AWS_DEPLOYMENT_SUMMARY.md` - Overview & checklist
