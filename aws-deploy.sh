#!/bin/bash

# AWS Deployment Script for ShowOff.life Server
# Run this on your EC2 instance after SSH connection

set -e

echo "🚀 Starting ShowOff.life Server Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Update System
echo -e "${YELLOW}[1/10] Updating system packages...${NC}"
sudo apt update
sudo apt upgrade -y

# Step 2: Install Node.js
echo -e "${YELLOW}[2/10] Installing Node.js...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${GREEN}✓ Node.js $(node --version) installed${NC}"

# Step 3: Install Git
echo -e "${YELLOW}[3/10] Installing Git...${NC}"
sudo apt install -y git
echo -e "${GREEN}✓ Git installed${NC}"

# Step 4: Install PM2
echo -e "${YELLOW}[4/10] Installing PM2...${NC}"
sudo npm install -g pm2
pm2 completion install
echo -e "${GREEN}✓ PM2 installed${NC}"

# Step 5: Install Nginx
echo -e "${YELLOW}[5/10] Installing Nginx...${NC}"
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo -e "${GREEN}✓ Nginx installed and started${NC}"

# Step 6: Install MongoDB (optional)
read -p "Install MongoDB locally? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[6/10] Installing MongoDB...${NC}"
    sudo apt-get install -y mongodb-org
    sudo systemctl start mongod
    sudo systemctl enable mongod
    echo -e "${GREEN}✓ MongoDB installed${NC}"
else
    echo -e "${YELLOW}[6/10] Skipping MongoDB (using MongoDB Atlas)${NC}"
fi

# Step 7: Clone Repository
echo -e "${YELLOW}[7/10] Cloning repository...${NC}"
cd /home/ubuntu
if [ ! -d "showoff-server" ]; then
    read -p "Enter GitHub repository URL: " REPO_URL
    git clone $REPO_URL showoff-server
else
    echo "Repository already exists, pulling latest changes..."
    cd showoff-server
    git pull
    cd ..
fi
echo -e "${GREEN}✓ Repository cloned${NC}"

# Step 8: Install Dependencies
echo -e "${YELLOW}[8/10] Installing Node dependencies...${NC}"
cd /home/ubuntu/showoff-server
npm install
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Step 9: Create .env file
echo -e "${YELLOW}[9/10] Creating .env file...${NC}"
if [ ! -f ".env" ]; then
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
    echo -e "${YELLOW}⚠️  .env file created. Please edit it with your credentials:${NC}"
    echo "nano /home/ubuntu/showoff-server/.env"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Step 10: Start Server with PM2
echo -e "${YELLOW}[10/10] Starting server with PM2...${NC}"
pm2 start server.js --name "showoff-api"
pm2 save
sudo pm2 startup
echo -e "${GREEN}✓ Server started with PM2${NC}"

# Configure Nginx
echo -e "${YELLOW}Configuring Nginx...${NC}"
sudo tee /etc/nginx/sites-available/showoff > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;

    # Increase max body size for large video uploads (300MB)
    client_max_body_size 300M;
    
    # Increase timeouts for large uploads (10 minutes)
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;
    send_timeout 600;

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
        
        # Disable buffering for large uploads
        proxy_request_buffering off;
        proxy_buffering off;
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

sudo ln -sf /etc/nginx/sites-available/showoff /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
echo -e "${GREEN}✓ Nginx configured${NC}"

# Get server IP
SERVER_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "📍 Server is running at: http://$SERVER_IP:3000"
echo ""
echo "📝 Next Steps:"
echo "1. Edit .env file with your credentials:"
echo "   nano /home/ubuntu/showoff-server/.env"
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
echo -e "${YELLOW}⚠️  Important: Update .env file with your actual credentials!${NC}"
echo ""
