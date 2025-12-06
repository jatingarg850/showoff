# AWS Deployment Guide for ShowOff.life Server

## Overview
This guide covers deploying your Node.js/Express server on AWS using EC2, RDS for MongoDB, and S3 for storage.

---

## PART 1: AWS Account Setup

### Step 1.1: Create AWS Account
1. Go to https://aws.amazon.com
2. Click "Create an AWS Account"
3. Enter email, password, and account name
4. Add payment method
5. Verify phone number
6. Choose support plan (Basic is free)

### Step 1.2: Create IAM User (for security)
1. Go to AWS Console → IAM
2. Click "Users" → "Create user"
3. Username: `showoff-deployment`
4. Check "Provide user access to AWS Management Console"
5. Set password
6. Click "Next"
7. Attach policies:
   - `AmazonEC2FullAccess`
   - `AmazonRDSFullAccess`
   - `AmazonS3FullAccess`
   - `AmazonVPCFullAccess`
8. Click "Create user"
9. Save the login credentials

### Step 1.3: Create Access Keys
1. Go to IAM → Users → showoff-deployment
2. Click "Security credentials" tab
3. Click "Create access key"
4. Choose "Application running outside AWS"
5. Click "Next"
6. Download CSV file (save securely)
7. You'll need these for AWS CLI

---

## PART 2: Set Up AWS CLI

### Step 2.1: Install AWS CLI
**Windows:**
```bash
# Download from: https://awscli.amazonaws.com/AWSCLIV2.msi
# Or use PowerShell:
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

**Mac:**
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscliv2.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Step 2.2: Configure AWS CLI
```bash
aws configure
```

When prompted, enter:
- AWS Access Key ID: (from CSV file)
- AWS Secret Access Key: (from CSV file)
- Default region: `ap-south-1` (Mumbai - closest to India)
- Default output format: `json`

Verify:
```bash
aws sts get-caller-identity
```

---

## PART 3: Create EC2 Instance (Server)

### Step 3.1: Launch EC2 Instance
1. Go to AWS Console → EC2 → Instances
2. Click "Launch instances"
3. **Name:** `showoff-server`
4. **AMI:** Ubuntu Server 22.04 LTS (free tier eligible)
5. **Instance type:** `t2.micro` (free tier) or `t3.small` (recommended)
6. **Key pair:** 
   - Click "Create new key pair"
   - Name: `showoff-key`
   - Type: RSA
   - Format: .pem
   - Click "Create key pair"
   - Save the .pem file securely

### Step 3.2: Configure Security Group
1. Click "Create security group"
2. Name: `showoff-sg`
3. Add inbound rules:
   - Type: SSH, Port: 22, Source: My IP (your IP)
   - Type: HTTP, Port: 80, Source: 0.0.0.0/0
   - Type: HTTPS, Port: 443, Source: 0.0.0.0/0
   - Type: Custom TCP, Port: 3000, Source: 0.0.0.0/0
   - Type: Custom TCP, Port: 9092, Source: 0.0.0.0/0 (Kafka)
4. Click "Launch instance"

### Step 3.3: Get Instance Details
1. Wait for instance to be "Running"
2. Copy the "Public IPv4 address" (e.g., 54.123.45.67)
3. This is your server IP

---

## PART 4: Connect to EC2 Instance

### Step 4.1: Connect via SSH (Windows)
```bash
# Navigate to where you saved showoff-key.pem
cd C:\path\to\key

# Connect
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP
# Example: ssh -i showoff-key.pem ubuntu@54.123.45.67
```

### Step 4.2: Connect via SSH (Mac/Linux)
```bash
# Set permissions
chmod 400 showoff-key.pem

# Connect
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP
```

---

## PART 5: Set Up Server Environment

### Step 5.1: Update System
```bash
sudo apt update
sudo apt upgrade -y
```

### Step 5.2: Install Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node --version
npm --version
```

### Step 5.3: Install Git
```bash
sudo apt install -y git
git --version
```

### Step 5.4: Install PM2 (Process Manager)
```bash
sudo npm install -g pm2
pm2 --version
```

### Step 5.5: Install Nginx (Reverse Proxy)
```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

## PART 6: Deploy Your Server Code

### Step 6.1: Clone Repository
```bash
cd /home/ubuntu
git clone https://github.com/YOUR_USERNAME/showoff-server.git
cd showoff-server
```

### Step 6.2: Install Dependencies
```bash
npm install
```

### Step 6.3: Create .env File
```bash
nano .env
```

Paste your environment variables (update with AWS values):
```env
PORT=3000
NODE_ENV=production

# MongoDB Atlas (Cloud)
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/showoff_life

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=30d

# AWS S3 Configuration
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=ap-south-1
AWS_S3_BUCKET=showoff-life-bucket

# Wasabi (if using instead of S3)
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

# Other Services
GOOGLE_CLIENT_ID=your_google_client_id
AUTHKEY_API_KEY=your_authkey_api_key
PHONE_EMAIL_CLIENT_ID=your_phone_email_id
PHONE_EMAIL_API_KEY=your_phone_email_key

# Kafka (optional)
KAFKA_ENABLED=false
KAFKA_BROKERS=localhost:9092
```

Press `Ctrl+X`, then `Y`, then `Enter` to save.

---

## PART 7: Set Up MongoDB

### Option A: MongoDB Atlas (Recommended - Cloud)
1. Go to https://www.mongodb.com/cloud/atlas
2. Create account
3. Create cluster (free tier available)
4. Get connection string
5. Add to .env as `MONGODB_URI`

### Option B: MongoDB on EC2 (Self-hosted)
```bash
# Install MongoDB
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Verify
mongo --version
```

---

## PART 8: Set Up S3 Bucket (for file storage)

### Step 8.1: Create S3 Bucket
1. Go to AWS Console → S3
2. Click "Create bucket"
3. Name: `showoff-life-bucket-YOUR_ID` (must be globally unique)
4. Region: `ap-south-1`
5. Uncheck "Block all public access" (for public files)
6. Click "Create bucket"

### Step 8.2: Configure Bucket Policy
1. Click on bucket → "Permissions" tab
2. Click "Bucket policy"
3. Paste:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::showoff-life-bucket-YOUR_ID/*"
    }
  ]
}
```
4. Click "Save"

### Step 8.3: Enable CORS
1. Click "CORS" in Permissions
2. Paste:
```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedOrigins": ["*"],
    "ExposeHeaders": ["ETag"]
  }
]
```
3. Click "Save"

---

## PART 9: Start Server with PM2

### Step 9.1: Start Application
```bash
cd /home/ubuntu/showoff-server
pm2 start server.js --name "showoff-api"
```

### Step 9.2: Save PM2 Configuration
```bash
pm2 save
sudo pm2 startup
```

### Step 9.3: Verify Server is Running
```bash
pm2 list
pm2 logs showoff-api
```

---

## PART 10: Configure Nginx (Reverse Proxy)

### Step 10.1: Create Nginx Config
```bash
sudo nano /etc/nginx/sites-available/showoff
```

Paste:
```nginx
server {
    listen 80;
    server_name YOUR_PUBLIC_IP;

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

    # WebSocket support
    location /socket.io {
        proxy_pass http://localhost:3000/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
```

### Step 10.2: Enable Config
```bash
sudo ln -s /etc/nginx/sites-available/showoff /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## PART 11: Set Up SSL Certificate (HTTPS)

### Step 11.1: Install Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### Step 11.2: Get SSL Certificate
```bash
sudo certbot certonly --nginx -d YOUR_DOMAIN.com
# If no domain, skip this and use HTTP for now
```

### Step 11.3: Update Nginx Config (if SSL obtained)
```bash
sudo nano /etc/nginx/sites-available/showoff
```

Add:
```nginx
server {
    listen 443 ssl http2;
    server_name YOUR_DOMAIN.com;

    ssl_certificate /etc/letsencrypt/live/YOUR_DOMAIN.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/YOUR_DOMAIN.com/privkey.pem;

    # ... rest of config
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name YOUR_DOMAIN.com;
    return 301 https://$server_name$request_uri;
}
```

---

## PART 12: Update Flutter App Configuration

### Step 12.1: Update API Config
Edit `apps/lib/config/api_config.dart`:

```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://YOUR_PUBLIC_IP:3000/api';
    // Or if using domain: 'https://your-domain.com/api';
  } else if (Platform.isIOS) {
    return 'http://YOUR_PUBLIC_IP:3000/api';
  } else {
    return 'http://localhost:3000/api';
  }
}

static String get wsUrl {
  if (Platform.isAndroid) {
    return 'http://YOUR_PUBLIC_IP:3000';
  } else if (Platform.isIOS) {
    return 'http://YOUR_PUBLIC_IP:3000';
  } else {
    return 'http://localhost:3000';
  }
}
```

---

## PART 13: Testing & Verification

### Step 13.1: Test API Endpoints
```bash
# From your local machine
curl http://YOUR_PUBLIC_IP:3000/api/health

# Or use Postman
# GET http://YOUR_PUBLIC_IP:3000/api/health
```

### Step 13.2: Check Server Logs
```bash
# SSH into EC2
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP

# View logs
pm2 logs showoff-api

# View specific errors
pm2 logs showoff-api --err
```

### Step 13.3: Monitor Server
```bash
pm2 monit
```

---

## PART 14: Domain Setup (Optional)

### Step 14.1: Buy Domain
- Go to Route 53 (AWS) or GoDaddy, Namecheap, etc.
- Buy domain (e.g., showoff-api.com)

### Step 14.2: Point Domain to EC2
1. Get Elastic IP (so IP doesn't change):
   - EC2 → Elastic IPs → Allocate
   - Associate with your instance
2. Update domain DNS:
   - A record → YOUR_ELASTIC_IP
   - Wait 24-48 hours for propagation

### Step 14.3: Update Nginx Config
```bash
sudo nano /etc/nginx/sites-available/showoff
# Change: server_name YOUR_PUBLIC_IP;
# To: server_name showoff-api.com;
sudo systemctl restart nginx
```

---

## PART 15: Monitoring & Maintenance

### Step 15.1: Set Up CloudWatch Monitoring
1. EC2 Dashboard → Instances
2. Select your instance
3. Monitoring tab → Enable detailed monitoring

### Step 15.2: Set Up Alarms
1. CloudWatch → Alarms → Create alarm
2. Select EC2 instance
3. Set thresholds for CPU, memory, disk

### Step 15.3: Regular Backups
```bash
# Backup database
mongodump --uri="mongodb+srv://..." --out=/backup/

# Backup S3
aws s3 sync s3://showoff-life-bucket /backup/s3/
```

---

## PART 16: Troubleshooting

### Issue: Server not responding
```bash
# SSH into EC2
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP

# Check if Node is running
pm2 list

# Restart if needed
pm2 restart showoff-api

# Check logs
pm2 logs showoff-api
```

### Issue: Database connection error
```bash
# Check MongoDB connection string in .env
# Verify IP whitelist in MongoDB Atlas
# Test connection:
mongo "mongodb+srv://username:password@cluster.mongodb.net/showoff_life"
```

### Issue: S3 upload failing
```bash
# Verify AWS credentials
aws s3 ls

# Check bucket exists
aws s3 ls s3://showoff-life-bucket

# Check bucket policy
aws s3api get-bucket-policy --bucket showoff-life-bucket
```

### Issue: WebSocket not connecting
```bash
# Check if port 3000 is open
sudo netstat -tlnp | grep 3000

# Check Nginx config
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

---

## PART 17: Cost Optimization

### Recommended Setup (Minimal Cost):
- **EC2**: t2.micro (free tier) or t3.small (~$10/month)
- **MongoDB Atlas**: Free tier (512MB)
- **S3**: Pay-as-you-go (~$0.023 per GB)
- **Total**: ~$10-20/month

### Cost Reduction Tips:
1. Use free tier resources
2. Set up auto-scaling
3. Use CloudFront for CDN
4. Archive old data to Glacier
5. Use spot instances for non-critical workloads

---

## PART 18: Production Checklist

- [ ] Environment variables set correctly
- [ ] Database backups configured
- [ ] SSL certificate installed
- [ ] Monitoring and alarms set up
- [ ] Rate limiting enabled
- [ ] CORS configured properly
- [ ] Security groups restricted
- [ ] PM2 configured for auto-restart
- [ ] Logs being collected
- [ ] Domain pointing to server
- [ ] API tested from mobile app
- [ ] WebSocket connection verified
- [ ] File uploads working
- [ ] Payment processing tested
- [ ] Email/SMS services working

---

## Quick Reference Commands

```bash
# SSH into server
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP

# View logs
pm2 logs showoff-api

# Restart server
pm2 restart showoff-api

# Stop server
pm2 stop showoff-api

# Start server
pm2 start server.js --name "showoff-api"

# Check server status
pm2 list

# View Nginx logs
sudo tail -f /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx

# Check disk space
df -h

# Check memory
free -h

# Check running processes
ps aux | grep node
```

---

## Support & Resources

- AWS Documentation: https://docs.aws.amazon.com/
- Node.js Deployment: https://nodejs.org/en/docs/guides/nodejs-on-heroku/
- MongoDB Atlas: https://docs.atlas.mongodb.com/
- PM2 Documentation: https://pm2.keymetrics.io/docs/
- Nginx Documentation: https://nginx.org/en/docs/

---

**Deployment Complete!** 🎉

Your server is now running on AWS and accessible at:
- `http://YOUR_PUBLIC_IP:3000`
- `https://YOUR_DOMAIN.com` (if domain configured)
