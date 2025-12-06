#!/bin/bash

# AWS Deployment Script for ShowOff.life
# Run this on your EC2 instance

set -e

echo "🚀 Starting ShowOff.life Server Deployment..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Step 1: Clone Repository
echo -e "${YELLOW}[1/6] Cloning repository...${NC}"
cd /home/ec2-user
git clone https://github.com/YOUR_GITHUB_USERNAME/showoff-server.git showoff-server
cd showoff-server
echo -e "${GREEN}✓ Repository cloned${NC}"

# Step 2: Install Dependencies
echo -e "${YELLOW}[2/6] Installing dependencies...${NC}"
npm install
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Step 3: Create .env file
echo -e "${YELLOW}[3/6] Creating .env file...${NC}"
cat > .env << 'EOF'
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
EOF
echo -e "${GREEN}✓ .env file created${NC}"
echo -e "${YELLOW}⚠️  Edit .env with your actual credentials:${NC}"
echo "nano /home/ec2-user/showoff-server/.env"

# Step 4: Start Server with PM2
echo -e "${YELLOW}[4/6] Starting server with PM2...${NC}"
pm2 start server.js --name "showoff-api"
pm2 save
sudo pm2 startup
echo -e "${GREEN}✓ Server started${NC}"

# Step 5: Configure Nginx
echo -e "${YELLOW}[5/6] Configuring Nginx...${NC}"
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
echo -e "${GREEN}✓ Nginx configured${NC}"

# Step 6: Verify
echo -e "${YELLOW}[6/6] Verifying setup...${NC}"
pm2 list
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "📍 Server is running at: http://3.110.103.187:3000"
echo ""
echo "📝 Next Steps:"
echo "1. Edit .env file with your credentials:"
echo "   nano /home/ec2-user/showoff-server/.env"
echo ""
echo "2. Restart server after updating .env:"
echo "   pm2 restart showoff-api"
echo ""
echo "3. View logs:"
echo "   pm2 logs showoff-api"
echo ""
echo "4. Monitor server:"
echo "   pm2 monit"
echo ""
echo "5. Update Flutter app config with server IP:"
echo "   apps/lib/config/api_config.dart"
echo ""
