# 🚀 START HERE - AWS Deployment Guide

## Welcome! 👋

You're about to deploy your ShowOff.life server on AWS. This guide will help you get it running in the cloud.

---

## ⏱️ How Long Will This Take?

- **Quick Setup:** 50 minutes (experienced developers)
- **Standard Setup:** 2 hours (most people)
- **Complete Setup:** 3-4 hours (with domain & SSL)

---

## 🎯 What You'll Get

After following this guide:
- ✅ Server running on AWS EC2
- ✅ Database connected (MongoDB)
- ✅ File storage working (S3/Wasabi)
- ✅ Reverse proxy configured (Nginx)
- ✅ Process manager running (PM2)
- ✅ Your Flutter app connected to the server

---

## 🤔 Choose Your Path

### Path 1: "Just Tell Me What To Do" 👶
**For:** First-time AWS users who want clear instructions

**Read:** `AWS_STEP_BY_STEP.md`
- 20 numbered steps
- Visual diagrams
- Verification checklist
- **Time:** 30 minutes to read, 1-2 hours to execute

### Path 2: "I Know What I'm Doing" 👨‍💻
**For:** Experienced developers who want to move fast

**Read:** `AWS_QUICK_START.md`
- 7 quick steps
- Command-line focused
- Minimal explanation
- **Time:** 5 minutes to read, 30-50 minutes to execute

### Path 3: "I Need Everything Explained" 📚
**For:** Production deployment with all details

**Read:** `AWS_DEPLOYMENT_GUIDE.md`
- 18 comprehensive parts
- Complete explanations
- Troubleshooting included
- **Time:** 60 minutes to read, 2-3 hours to execute

---

## 📋 Before You Start

Make sure you have:

1. **AWS Account**
   - Go to https://aws.amazon.com
   - Create account (takes 10 minutes)

2. **Your Server Code**
   - GitHub repository ready
   - All code committed

3. **Credentials Ready**
   - MongoDB connection string
   - JWT secret
   - AWS access keys
   - Payment gateway keys (Razorpay/Stripe)
   - Google OAuth credentials
   - SMS service credentials

4. **Time Available**
   - 2-3 hours uninterrupted

---

## 🚀 Quick Start (5 Steps)

If you're in a hurry, here's the absolute minimum:

### Step 1: Create AWS Account & Get Keys
```
1. Go to https://aws.amazon.com
2. Create account
3. Create IAM user
4. Download access keys
5. Install AWS CLI: aws configure
```

### Step 2: Launch EC2 Instance
```
1. Go to EC2 → Launch instances
2. Choose Ubuntu 22.04 LTS
3. Select t2.micro (free tier)
4. Create security group (ports: 22, 80, 443, 3000)
5. Launch and save the public IP
```

### Step 3: Connect & Deploy
```bash
# SSH into your instance
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP

# Run deployment script
curl -O https://raw.githubusercontent.com/YOUR_REPO/aws-deploy.sh
chmod +x aws-deploy.sh
./aws-deploy.sh
```

### Step 4: Configure Environment
```bash
# Edit .env file
nano /home/ubuntu/showoff-server/.env

# Add your credentials:
# - MONGODB_URI
# - JWT_SECRET
# - AWS keys
# - Payment keys
# - etc.

# Restart server
pm2 restart showoff-api
```

### Step 5: Update Flutter App
```dart
// Edit: apps/lib/config/api_config.dart
static String get baseUrl {
  return 'http://YOUR_PUBLIC_IP:3000/api';
}

static String get wsUrl {
  return 'http://YOUR_PUBLIC_IP:3000';
}
```

**Done!** Your server is now live! 🎉

---

## 📚 Full Documentation

| Document | Purpose | Read Time |
|----------|---------|-----------|
| `AWS_STEP_BY_STEP.md` | Visual step-by-step guide | 30 min |
| `AWS_QUICK_START.md` | Quick reference | 5 min |
| `AWS_DEPLOYMENT_GUIDE.md` | Complete guide | 60 min |
| `AWS_ENV_SETUP.md` | Environment variables | 20 min |
| `AWS_DEPLOYMENT_SUMMARY.md` | Overview & checklist | 15 min |
| `AWS_DEPLOYMENT_INDEX.md` | Documentation index | 10 min |
| `aws-deploy.sh` | Automated script | - |

---

## 💰 Cost

### Free Tier (First 12 Months)
- EC2 t2.micro: Free
- MongoDB Atlas: Free (512MB)
- S3: Free (5GB)
- **Total: $0/month**

### After Free Tier
- EC2 t3.small: ~$10/month
- MongoDB Atlas: Free or ~$57/month
- S3: ~$0.023/GB
- **Total: ~$10-70/month**

---

## ✅ Verification

After deployment, test:

```bash
# From your local machine
curl http://YOUR_PUBLIC_IP:3000/api/health

# Should return:
# {"status": "ok"}
```

---

## 🆘 Something Wrong?

### Server not responding
```bash
# SSH into server
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP

# Check logs
pm2 logs showoff-api

# Restart
pm2 restart showoff-api
```

### Database connection failed
- Check MONGODB_URI in .env
- Verify IP whitelist in MongoDB Atlas
- Test connection manually

### S3 upload failing
- Verify AWS credentials
- Check bucket exists
- Check bucket policy

### WebSocket not connecting
- Check port 3000 is open
- Check Nginx config
- Restart Nginx: `sudo systemctl restart nginx`

---

## 📞 Need Help?

1. **Check the relevant guide** based on your issue
2. **Search troubleshooting section** in `AWS_DEPLOYMENT_GUIDE.md`
3. **Check server logs:** `pm2 logs showoff-api`
4. **Check Nginx logs:** `sudo tail -f /var/log/nginx/error.log`

---

## 🎯 Next Steps After Deployment

1. **Set up monitoring** - CloudWatch alarms
2. **Configure backups** - Daily database backups
3. **Add domain** - Route 53 or external DNS
4. **Install SSL** - Let's Encrypt certificate
5. **Optimize costs** - Review AWS bill

---

## 🚀 Ready?

### Choose Your Path:

**👶 I'm new to AWS**
→ Read `AWS_STEP_BY_STEP.md` first

**👨‍💻 I know AWS**
→ Read `AWS_QUICK_START.md` first

**🏢 Production setup**
→ Read `AWS_DEPLOYMENT_GUIDE.md` first

---

## 📊 Deployment Checklist

- [ ] AWS account created
- [ ] IAM user created
- [ ] Access keys downloaded
- [ ] AWS CLI installed
- [ ] EC2 instance launched
- [ ] Security group configured
- [ ] SSH connection working
- [ ] Repository cloned
- [ ] Dependencies installed
- [ ] .env file created
- [ ] Server started with PM2
- [ ] Nginx configured
- [ ] API responding
- [ ] Flutter app updated
- [ ] Logs showing no errors

---

## 🎉 You're All Set!

Your ShowOff.life server is ready to deploy on AWS!

**Start with:** `AWS_STEP_BY_STEP.md` or `AWS_QUICK_START.md`

**Questions?** Check `AWS_DEPLOYMENT_INDEX.md` for documentation index

**Happy deploying!** 🚀

---

## 📝 Quick Reference

### SSH into Server
```bash
ssh -i showoff-key.pem ubuntu@YOUR_PUBLIC_IP
```

### View Logs
```bash
pm2 logs showoff-api
```

### Restart Server
```bash
pm2 restart showoff-api
```

### Check Status
```bash
pm2 list
```

### Monitor
```bash
pm2 monit
```

### Restart Nginx
```bash
sudo systemctl restart nginx
```

---

**Let's get your server live!** 🌍
