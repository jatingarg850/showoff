# AWS Deployment - Quick Start (5 Minutes)

## Prerequisites
- AWS Account
- AWS CLI installed and configured
- Your server code ready

---

## Step 1: Launch EC2 Instance (2 min)

```bash
# Using AWS CLI
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro \
  --key-name showoff-key \
  --security-groups showoff-sg \
  --region ap-south-1

# Or use AWS Console:
# 1. Go to EC2 → Launch instances
# 2. Choose Ubuntu 22.04 LTS
# 3. Select t2.micro (free tier)
# 4. Create security group with ports: 22, 80, 443, 3000
# 5. Launch
```

---

## Step 2: Get Instance IP

```bash
# Get your instance IP
aws ec2 describe-instances \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --region ap-south-1
```

Save this IP as `YOUR_PUBLIC_IP`

---

## Step 3: Connect to Instance

```bash
# SSH into your instance
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP
```

---

## Step 4: Run Deployment Script

```bash
# Download and run deployment script
curl -O https://raw.githubusercontent.com/YOUR_REPO/aws-deploy.sh
chmod +x aws-deploy.sh
./aws-deploy.sh
```

Or manually:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo apt install -y nginx
sudo systemctl start nginx

# Clone your repo
cd /home/ubuntu
git clone YOUR_REPO_URL showoff-server
cd showoff-server

# Install dependencies
npm install

# Create .env file
nano .env
# Paste your environment variables

# Start server
pm2 start server.js --name "showoff-api"
pm2 save
sudo pm2 startup
```

---

## Step 5: Configure Nginx

```bash
# Create Nginx config
sudo nano /etc/nginx/sites-available/showoff
```

Paste:
```nginx
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
```

Enable:
```bash
sudo ln -s /etc/nginx/sites-available/showoff /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

---

## Step 6: Update Flutter App

Edit `apps/lib/config/api_config.dart`:

```dart
static String get baseUrl {
  return 'http://YOUR_PUBLIC_IP:3000/api';
}

static String get wsUrl {
  return 'http://YOUR_PUBLIC_IP:3000';
}
```

---

## Step 7: Test

```bash
# From your local machine
curl http://YOUR_PUBLIC_IP:3000/api/health

# Or open in browser
# http://YOUR_PUBLIC_IP:3000
```

---

## Useful Commands

```bash
# SSH into server
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP

# View logs
pm2 logs showoff-api

# Restart server
pm2 restart showoff-api

# Stop server
pm2 stop showoff-api

# Check status
pm2 list

# View Nginx logs
sudo tail -f /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx
```

---

## Troubleshooting

### Server not responding
```bash
# Check if running
pm2 list

# Restart
pm2 restart showoff-api

# Check logs
pm2 logs showoff-api
```

### Port 3000 not accessible
```bash
# Check security group in AWS Console
# Add inbound rule: TCP 3000 from 0.0.0.0/0

# Or via CLI:
aws ec2 authorize-security-group-ingress \
  --group-name showoff-sg \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0 \
  --region ap-south-1
```

### Nginx not working
```bash
# Test config
sudo nginx -t

# Restart
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx
```

---

## Cost Estimate

- **EC2 t2.micro**: Free (first 12 months)
- **Data transfer**: ~$0.09 per GB
- **Total**: ~$0-10/month

---

## Next Steps

1. ✅ Set up domain (Route 53 or external)
2. ✅ Install SSL certificate (Let's Encrypt)
3. ✅ Set up monitoring (CloudWatch)
4. ✅ Configure backups
5. ✅ Set up auto-scaling

---

## Support

For detailed guide, see: `AWS_DEPLOYMENT_GUIDE.md`

For issues, check logs:
```bash
pm2 logs showoff-api
sudo tail -f /var/log/nginx/error.log
```
