# AWS Paid Tier Deployment Guide - Full Setup

## Overview
This guide covers deploying your ShowOff.life Node.js server to AWS EC2 (paid tier) with proper security, monitoring, and scalability.

## Prerequisites
- AWS Account with payment method added
- Node.js server code ready
- MongoDB connection string (Atlas or self-hosted)
- Firebase credentials
- Domain name (optional but recommended)
- SSH key pair

---

## STEP 1: Create AWS Account & Setup Billing

### 1.1 Create AWS Account
1. Go to https://aws.amazon.com
2. Click "Create an AWS Account"
3. Enter email, password, and account name
4. Add payment method (credit/debit card)
5. Verify phone number
6. Choose support plan (Basic is free)

### 1.2 Setup Billing Alerts
1. Go to AWS Console → Billing Dashboard
2. Click "Billing Preferences"
3. Enable "Receive Billing Alerts"
4. Set alert threshold (e.g., $10, $50, $100)
5. Confirm email

---

## STEP 2: Create EC2 Instance

### 2.1 Launch EC2 Instance
1. Go to AWS Console → EC2 Dashboard
2. Click "Launch Instances"
3. Choose AMI:
   - Select "Ubuntu Server 22.04 LTS" (free tier eligible, but we'll use paid)
   - Architecture: 64-bit (x86)

### 2.2 Choose Instance Type
**For Production (Recommended):**
- **t3.medium** ($0.0416/hour) - Good for small to medium apps
- **t3.large** ($0.0832/hour) - Better performance
- **t3.xlarge** ($0.1664/hour) - High traffic

**For Development:**
- **t3.micro** ($0.0104/hour) - Minimal cost
- **t3.small** ($0.0208/hour) - Light workload

**Recommendation for ShowOff.life:**
- Start with **t3.medium** (2 vCPU, 4GB RAM)
- Upgrade to t3.large if needed

### 2.3 Configure Instance Details
1. Number of instances: 1
2. Network: Default VPC
3. Subnet: Default
4. Auto-assign Public IP: Enable
5. IAM role: None (or create one for S3 access)
6. Monitoring: Enable detailed CloudWatch monitoring
7. Tenancy: Default

### 2.4 Add Storage
1. Size: 30 GB (minimum for production)
2. Volume type: gp3 (General Purpose SSD)
3. Delete on termination: Yes
4. Encrypted: Yes (recommended)

### 2.5 Add Tags
```
Key: Name
Value: showoff-life-server

Key: Environment
Value: production

Key: Project
Value: ShowOff.life
```

### 2.6 Configure Security Group
1. Create new security group: `showoff-life-sg`
2. Add inbound rules:

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | Your IP (or 0.0.0.0/0 for anywhere) |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| HTTPS | TCP | 443 | 0.0.0.0/0 |
| Custom TCP | TCP | 3000 | 0.0.0.0/0 |
| Custom TCP | TCP | 5000 | 0.0.0.0/0 |

3. Outbound: Allow all (default)

### 2.7 Review and Launch
1. Review all settings
2. Click "Launch"
3. Create new key pair:
   - Name: `showoff-life-key`
   - Format: `.pem` (for Mac/Linux) or `.ppk` (for Windows PuTTY)
4. Download key pair (save securely!)
5. Click "Launch Instances"

---

## STEP 3: Connect to EC2 Instance

### 3.1 Get Instance Details
1. Go to EC2 Dashboard → Instances
2. Select your instance
3. Copy "Public IPv4 address" (e.g., 54.123.45.67)

### 3.2 Connect via SSH (Mac/Linux)
```bash
# Change permissions
chmod 400 showoff-life-key.pem

# Connect
ssh -i showoff-life-key.pem ubuntu@54.123.45.67
```

### 3.3 Connect via SSH (Windows - PuTTY)
1. Download PuTTY and PuTTYgen
2. Convert .pem to .ppk using PuTTYgen
3. Open PuTTY
4. Host: 54.123.45.67
5. Auth → Private key file: select .ppk
6. Click Open

---

## STEP 4: Setup Server Environment

### 4.1 Update System
```bash
sudo apt update
sudo apt upgrade -y
```

### 4.2 Install Node.js
```bash
# Install Node.js 18 (LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node --version
npm --version
```

### 4.3 Install Git
```bash
sudo apt install -y git
```

### 4.4 Install PM2 (Process Manager)
```bash
sudo npm install -g pm2

# Setup PM2 to start on boot
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
```

### 4.5 Install Nginx (Reverse Proxy)
```bash
sudo apt install -y nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

## STEP 5: Deploy Server Code

### 5.1 Clone Repository
```bash
cd /home/ubuntu
git clone https://github.com/your-repo/showoff-life-server.git
cd showoff-life-server
```

### 5.2 Install Dependencies
```bash
npm install
```

### 5.3 Setup Environment Variables
```bash
# Create .env file
nano .env

# Add your environment variables:
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/showoff
JWT_SECRET=your-secret-key
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-email@firebase.iam.gserviceaccount.com
AUTHKEY_API_KEY=your-authkey-key
RESEND_API_KEY=your-resend-key
GOOGLE_CLIENT_ID=your-google-id
GOOGLE_CLIENT_SECRET=your-google-secret

# Save: Ctrl+X, Y, Enter
```

### 5.4 Start Server with PM2
```bash
# Start server
pm2 start server/start-server.js --name "showoff-server"

# Save PM2 config
pm2 save

# Check status
pm2 status
pm2 logs
```

---

## STEP 6: Configure Nginx Reverse Proxy

### 6.1 Create Nginx Config
```bash
sudo nano /etc/nginx/sites-available/showoff-life
```

### 6.2 Add Configuration
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # SSL certificates (we'll add these later with Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;

    # Proxy settings
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 6.3 Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/showoff-life /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test config
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

---

## STEP 7: Setup SSL Certificate (Let's Encrypt)

### 7.1 Install Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 7.2 Get SSL Certificate
```bash
sudo certbot certonly --nginx -d your-domain.com -d www.your-domain.com

# Follow prompts:
# - Enter email
# - Agree to terms
# - Choose redirect option
```

### 7.3 Auto-Renew Certificate
```bash
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

---

## STEP 8: Setup Monitoring & Logging

### 8.1 CloudWatch Monitoring
1. Go to AWS Console → CloudWatch
2. Create dashboard for your instance
3. Add metrics:
   - CPU Utilization
   - Network In/Out
   - Disk Read/Write

### 8.2 Setup Alarms
1. CloudWatch → Alarms → Create Alarm
2. Select EC2 instance
3. Set conditions:
   - CPU > 80% for 5 minutes
   - Network In > 1GB
4. Add SNS notification (email alert)

### 8.3 View Logs
```bash
# PM2 logs
pm2 logs showoff-server

# System logs
sudo journalctl -u nginx -f

# Application logs
tail -f /home/ubuntu/showoff-life-server/logs/app.log
```

---

## STEP 9: Setup Database Backups

### 9.1 MongoDB Atlas Backups
1. Go to MongoDB Atlas → Backups
2. Enable automatic backups
3. Set backup frequency (daily recommended)
4. Configure retention (30 days minimum)

### 9.2 Database Snapshots
```bash
# Create manual backup
mongodump --uri "mongodb+srv://user:pass@cluster.mongodb.net/showoff" --out /backups/showoff-$(date +%Y%m%d)

# Schedule with cron
crontab -e

# Add line:
0 2 * * * mongodump --uri "mongodb+srv://user:pass@cluster.mongodb.net/showoff" --out /backups/showoff-$(date +\%Y\%m\%d)
```

---

## STEP 10: Update App Configuration

### 10.1 Update API Endpoint
In Flutter app (`apps/lib/config/api_config.dart`):

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-domain.com';
  // or
  static const String baseUrl = 'https://54.123.45.67';
}
```

### 10.2 Rebuild App
```bash
cd apps
flutter clean
flutter pub get
flutter run --release
```

---

## STEP 11: Maintenance & Scaling

### 11.1 Monitor Costs
- Check AWS Billing Dashboard weekly
- Set up cost alerts
- Review unused resources

### 11.2 Scale Up if Needed
```bash
# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Change instance type (t3.medium → t3.large)
aws ec2 modify-instance-attribute --instance-id i-1234567890abcdef0 --instance-type "{\"Value\": \"t3.large\"}"

# Start instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0
```

### 11.3 Setup Auto-Scaling (Optional)
1. Create AMI from current instance
2. Create Launch Template
3. Create Auto Scaling Group
4. Set min/max instances
5. Configure scaling policies

---

## STEP 12: Security Best Practices

### 12.1 Firewall Rules
```bash
# Only allow SSH from your IP
# Update security group in AWS Console
```

### 12.2 Fail2Ban (Brute Force Protection)
```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 12.3 Regular Updates
```bash
# Schedule weekly updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

---

## Estimated Monthly Costs

| Component | Type | Cost/Month |
|-----------|------|-----------|
| EC2 (t3.medium) | Compute | ~$30 |
| Data Transfer | Network | ~$5-15 |
| EBS Storage (30GB) | Storage | ~$3 |
| **Total** | | **~$40-50** |

*Prices vary by region. Use AWS Calculator for exact pricing.*

---

## Troubleshooting

### Server Not Responding
```bash
# Check PM2 status
pm2 status

# Restart server
pm2 restart showoff-server

# Check logs
pm2 logs showoff-server
```

### SSL Certificate Issues
```bash
# Check certificate
sudo certbot certificates

# Renew manually
sudo certbot renew --force-renewal
```

### High CPU Usage
```bash
# Check processes
top

# Check Node.js memory
pm2 monit
```

---

## Support & Resources

- AWS Documentation: https://docs.aws.amazon.com/
- PM2 Documentation: https://pm2.keymetrics.io/
- Nginx Documentation: https://nginx.org/en/docs/
- Let's Encrypt: https://letsencrypt.org/

---

## Next Steps

1. ✅ Create AWS account
2. ✅ Launch EC2 instance
3. ✅ Deploy server code
4. ✅ Setup SSL certificate
5. ✅ Configure monitoring
6. ✅ Update app configuration
7. ✅ Test deployment
8. ✅ Monitor costs

**Your server is now live on AWS!**
