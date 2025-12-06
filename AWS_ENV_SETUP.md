# AWS Environment Variables Setup Guide

## Complete .env Configuration for Production

### 1. Server Configuration

```env
# Server Port
PORT=3000

# Environment
NODE_ENV=production

# Max file size (100MB)
MAX_FILE_SIZE=104857600

# Allowed file types
ALLOWED_IMAGE_TYPES=image/jpeg,image/png,image/jpg,image/webp
ALLOWED_VIDEO_TYPES=video/mp4,video/mpeg,video/quicktime,video/x-msvideo
```

---

## 2. Database Configuration

### Option A: MongoDB Atlas (Recommended)

```env
# MongoDB Atlas Connection String
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/showoff_life?retryWrites=true&w=majority
```

**Steps to get connection string:**
1. Go to https://www.mongodb.com/cloud/atlas
2. Create account and cluster
3. Click "Connect"
4. Choose "Connect your application"
5. Copy connection string
6. Replace `<password>` with your password
7. Replace `showoff_life` with your database name

### Option B: MongoDB on EC2

```env
# Local MongoDB
MONGODB_URI=mongodb://localhost:27017/showoff_life
```

---

## 3. JWT Configuration

```env
# JWT Secret (generate a strong random string)
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production_12345

# JWT Expiration
JWT_EXPIRE=30d
```

**Generate strong JWT secret:**
```bash
# On Linux/Mac
openssl rand -base64 32

# On Windows PowerShell
[Convert]::ToBase64String((1..32 | ForEach-Object {Get-Random -Maximum 256}))
```

---

## 4. AWS S3 Configuration

### Get AWS Credentials

1. Go to AWS Console → IAM → Users
2. Create user: `showoff-s3-user`
3. Attach policy: `AmazonS3FullAccess`
4. Create access key
5. Download CSV with credentials

### Add to .env

```env
# AWS S3 Configuration
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_REGION=ap-south-1
AWS_S3_BUCKET=showoff-life-bucket-unique-name

# S3 Endpoint (optional, for custom S3-compatible services)
AWS_S3_ENDPOINT=https://s3.ap-south-1.amazonaws.com
```

---

## 5. Wasabi Configuration (Alternative to S3)

```env
# Wasabi S3-Compatible Storage
WASABI_ACCESS_KEY_ID=your_wasabi_access_key
WASABI_SECRET_ACCESS_KEY=your_wasabi_secret_key
WASABI_BUCKET_NAME=showoff-bucket
WASABI_REGION=ap-southeast-1
WASABI_ENDPOINT=https://s3.ap-southeast-1.wasabisys.com
```

**Get Wasabi credentials:**
1. Go to https://wasabi.com
2. Create account
3. Create bucket
4. Generate API credentials
5. Copy to .env

---

## 6. Payment Gateway Configuration

### Razorpay (India)

```env
# Razorpay Configuration
RAZORPAY_KEY_ID=rzp_live_XXXXXXXXXXXXXXXX
RAZORPAY_KEY_SECRET=XXXXXXXXXXXXXXXXXXXXXXXX
```

**Get Razorpay credentials:**
1. Go to https://razorpay.com
2. Create account
3. Go to Settings → API Keys
4. Copy Key ID and Secret

### Stripe (International)

```env
# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_live_XXXXXXXXXXXXXXXXXXXXXXXX
STRIPE_SECRET_KEY=sk_live_XXXXXXXXXXXXXXXXXXXXXXXX
STRIPE_WEBHOOK_SECRET=whsec_XXXXXXXXXXXXXXXXXXXXXXXX
```

**Get Stripe credentials:**
1. Go to https://stripe.com
2. Create account
3. Go to Developers → API Keys
4. Copy Publishable and Secret keys
5. Create webhook endpoint for your server

---

## 7. Google OAuth Configuration

```env
# Google OAuth
GOOGLE_CLIENT_ID=559878476466-sgciou78aphmp7irtmvc61hl9tgmua12.apps.googleusercontent.com
GOOGLE_PROJECT_ID=dev-inscriber-479305-u8
GOOGLE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
GOOGLE_TOKEN_URI=https://oauth2.googleapis.com/token
GOOGLE_REDIRECT_URI=https://your-domain.com/api/auth/google/callback
```

**Get Google OAuth credentials:**
1. Go to https://console.cloud.google.com
2. Create project
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs
6. Copy credentials

---

## 8. SMS/OTP Services

### AuthKey.io (SMS OTP)

```env
# AuthKey Configuration
AUTHKEY_API_KEY=4e51b96379db3b83
AUTHKEY_SENDER_ID=SHOWOFF
AUTHKEY_TEMPLATE_ID=your_template_id
AUTHKEY_PE_ID=your_dlt_entity_id
```

**Get AuthKey credentials:**
1. Go to https://console.authkey.io
2. Create account
3. Create API key
4. Create SMS template
5. Copy credentials

### Phone.Email (OTP)

```env
# Phone.Email Configuration
PHONE_EMAIL_CLIENT_ID=16687983578815655151
PHONE_EMAIL_API_KEY=I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf
```

---

## 9. Coin System Configuration

```env
# Coin Rewards
UPLOAD_REWARD_COINS=5
UPLOAD_BONUS_COINS=10
VIEW_REWARD_PER_1000=10
AD_WATCH_COINS=10
REFERRAL_COINS_FIRST_100=5
REFERRAL_COINS_AFTER=5

# Coin Limits
DAILY_COIN_CAP=5000
MONTHLY_COIN_CAP=100000

# Conversion Rate
COIN_TO_INR_RATE=1

# Withdrawal
MIN_WITHDRAWAL_AMOUNT=100
MAX_UPLOAD_POSTS=10
```

---

## 10. Kafka Configuration (Optional)

```env
# Kafka Configuration
KAFKA_ENABLED=false
KAFKA_BROKERS=localhost:9092
KAFKA_CONSUMER_GROUP=showoff-life-consumer-group
```

**Enable Kafka:**
1. Set `KAFKA_ENABLED=true`
2. Install Kafka on EC2 or use AWS MSK
3. Update broker addresses

---

## 11. Gemini AI Configuration

```env
# Gemini API (for AI features)
GEMINI_API_KEY=AIzaSyCoFlnT5VNn-mMLNAVQ6CHkejWAGjIe9AA
```

**Get Gemini API key:**
1. Go to https://makersuite.google.com/app/apikey
2. Create API key
3. Copy to .env

---

## Complete Production .env Template

```env
# ============================================
# SERVER CONFIGURATION
# ============================================
PORT=3000
NODE_ENV=production
MAX_FILE_SIZE=104857600
ALLOWED_IMAGE_TYPES=image/jpeg,image/png,image/jpg,image/webp
ALLOWED_VIDEO_TYPES=video/mp4,video/mpeg,video/quicktime,video/x-msvideo

# ============================================
# DATABASE
# ============================================
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/showoff_life?retryWrites=true&w=majority

# ============================================
# JWT
# ============================================
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=30d

# ============================================
# AWS S3
# ============================================
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=ap-south-1
AWS_S3_BUCKET=showoff-life-bucket-unique-name

# ============================================
# WASABI (Alternative to S3)
# ============================================
WASABI_ACCESS_KEY_ID=your_wasabi_key
WASABI_SECRET_ACCESS_KEY=your_wasabi_secret
WASABI_BUCKET_NAME=showoff-bucket
WASABI_REGION=ap-southeast-1
WASABI_ENDPOINT=https://s3.ap-southeast-1.wasabisys.com

# ============================================
# PAYMENT GATEWAYS
# ============================================
RAZORPAY_KEY_ID=rzp_live_XXXXXXXXXXXXXXXX
RAZORPAY_KEY_SECRET=XXXXXXXXXXXXXXXXXXXXXXXX
STRIPE_PUBLISHABLE_KEY=pk_live_XXXXXXXXXXXXXXXXXXXXXXXX
STRIPE_SECRET_KEY=sk_live_XXXXXXXXXXXXXXXXXXXXXXXX
STRIPE_WEBHOOK_SECRET=whsec_XXXXXXXXXXXXXXXXXXXXXXXX

# ============================================
# GOOGLE OAUTH
# ============================================
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_PROJECT_ID=your_google_project_id
GOOGLE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
GOOGLE_TOKEN_URI=https://oauth2.googleapis.com/token
GOOGLE_REDIRECT_URI=https://your-domain.com/api/auth/google/callback

# ============================================
# SMS/OTP SERVICES
# ============================================
AUTHKEY_API_KEY=your_authkey_api_key
AUTHKEY_SENDER_ID=SHOWOFF
AUTHKEY_TEMPLATE_ID=your_template_id
AUTHKEY_PE_ID=your_dlt_entity_id
PHONE_EMAIL_CLIENT_ID=your_phone_email_id
PHONE_EMAIL_API_KEY=your_phone_email_key

# ============================================
# COIN SYSTEM
# ============================================
UPLOAD_REWARD_COINS=5
UPLOAD_BONUS_COINS=10
VIEW_REWARD_PER_1000=10
AD_WATCH_COINS=10
REFERRAL_COINS_FIRST_100=5
REFERRAL_COINS_AFTER=5
DAILY_COIN_CAP=5000
MONTHLY_COIN_CAP=100000
COIN_TO_INR_RATE=1
MIN_WITHDRAWAL_AMOUNT=100
MAX_UPLOAD_POSTS=10

# ============================================
# KAFKA (Optional)
# ============================================
KAFKA_ENABLED=false
KAFKA_BROKERS=localhost:9092
KAFKA_CONSUMER_GROUP=showoff-life-consumer-group

# ============================================
# AI
# ============================================
GEMINI_API_KEY=your_gemini_api_key
```

---

## Security Best Practices

1. **Never commit .env to Git**
   ```bash
   # Add to .gitignore
   echo ".env" >> .gitignore
   ```

2. **Use AWS Secrets Manager**
   ```bash
   # Store secrets in AWS
   aws secretsmanager create-secret \
     --name showoff/production \
     --secret-string file://env.json
   ```

3. **Rotate credentials regularly**
   - Change JWT_SECRET every 3 months
   - Rotate API keys quarterly
   - Update database passwords

4. **Use strong passwords**
   - Minimum 16 characters
   - Mix of uppercase, lowercase, numbers, symbols
   - No dictionary words

5. **Restrict API key permissions**
   - S3: Only allow specific bucket access
   - Razorpay: Enable IP whitelisting
   - Stripe: Use restricted API keys

---

## Verification Checklist

- [ ] All required variables set
- [ ] No hardcoded secrets in code
- [ ] .env file in .gitignore
- [ ] Database connection tested
- [ ] S3 bucket accessible
- [ ] Payment gateways working
- [ ] OAuth credentials valid
- [ ] SMS service configured
- [ ] Coin system values correct
- [ ] Kafka enabled/disabled as needed

---

## Troubleshooting

### "Cannot find module" errors
- Run `npm install` again
- Check all dependencies in package.json

### Database connection failed
- Verify MONGODB_URI is correct
- Check IP whitelist in MongoDB Atlas
- Test connection: `mongo "mongodb+srv://..."`

### S3 upload failing
- Verify AWS credentials
- Check bucket exists: `aws s3 ls`
- Check bucket policy allows uploads

### Payment processing not working
- Verify API keys are correct
- Check webhook endpoints configured
- Test with test credentials first

---

## Support

For detailed setup, see individual service documentation:
- MongoDB: https://docs.mongodb.com/
- AWS S3: https://docs.aws.amazon.com/s3/
- Razorpay: https://razorpay.com/docs/
- Stripe: https://stripe.com/docs/
- Google OAuth: https://developers.google.com/identity/
