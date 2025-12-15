# AWS Deployment Checklist

## Pre-Deployment
- [ ] AWS account created with payment method
- [ ] Billing alerts configured
- [ ] Domain name purchased (optional)
- [ ] Server code ready and tested locally
- [ ] MongoDB connection string ready
- [ ] Firebase credentials ready
- [ ] All API keys collected

## EC2 Setup
- [ ] EC2 instance launched (t3.medium recommended)
- [ ] Security group created with proper rules
- [ ] Key pair downloaded and secured
- [ ] Elastic IP assigned (optional but recommended)
- [ ] Instance tags added for organization

## Server Installation
- [ ] SSH connection verified
- [ ] System updated (apt update/upgrade)
- [ ] Node.js 18 installed
- [ ] Git installed
- [ ] PM2 installed globally
- [ ] Nginx installed

## Code Deployment
- [ ] Repository cloned
- [ ] Dependencies installed (npm install)
- [ ] .env file created with all variables
- [ ] Server started with PM2
- [ ] PM2 configured to start on boot
- [ ] Server logs checked for errors

## Nginx Configuration
- [ ] Nginx config file created
- [ ] Reverse proxy configured for port 3000
- [ ] Nginx syntax tested
- [ ] Nginx restarted successfully

## SSL Certificate
- [ ] Certbot installed
- [ ] SSL certificate obtained from Let's Encrypt
- [ ] Nginx config updated with SSL paths
- [ ] HTTPS working (test with browser)
- [ ] Auto-renewal configured

## Monitoring & Alerts
- [ ] CloudWatch dashboard created
- [ ] CPU alarm configured
- [ ] Network alarm configured
- [ ] SNS email notifications working
- [ ] PM2 monitoring enabled

## Database
- [ ] MongoDB connection verified
- [ ] Automatic backups enabled
- [ ] Backup retention set to 30+ days
- [ ] Manual backup tested

## App Configuration
- [ ] API endpoint updated in Flutter app
- [ ] App rebuilt with new endpoint
- [ ] API calls tested from app
- [ ] All endpoints responding correctly

## Security
- [ ] Security group rules reviewed
- [ ] SSH key secured (chmod 400)
- [ ] Fail2Ban installed
- [ ] Automatic updates enabled
- [ ] Firewall rules configured

## Testing
- [ ] Server health check: GET /api/health
- [ ] Authentication endpoints tested
- [ ] Database queries working
- [ ] File uploads working
- [ ] Notifications sending
- [ ] Load testing completed

## Documentation
- [ ] Server IP/domain documented
- [ ] SSH key location documented
- [ ] Database credentials documented
- [ ] API keys documented
- [ ] Deployment steps documented

## Post-Deployment
- [ ] Monitor costs daily for first week
- [ ] Check logs regularly
- [ ] Test backup restoration
- [ ] Setup monitoring dashboard
- [ ] Create runbook for common issues
- [ ] Schedule regular maintenance

## Estimated Timeline
- AWS Setup: 15 minutes
- EC2 Launch: 5 minutes
- Server Installation: 20 minutes
- Code Deployment: 10 minutes
- SSL Setup: 10 minutes
- Testing: 30 minutes
- **Total: ~90 minutes**

## Quick Commands Reference

```bash
# SSH into server
ssh -i showoff-life-key.pem ubuntu@YOUR_IP

# Check server status
pm2 status

# View logs
pm2 logs showoff-server

# Restart server
pm2 restart showoff-server

# Check Nginx
sudo systemctl status nginx

# View SSL certificate
sudo certbot certificates

# Monitor resources
pm2 monit
```

## Cost Monitoring

**Monthly Estimate:**
- EC2 (t3.medium): $30
- Data Transfer: $5-15
- Storage: $3
- **Total: $40-50/month**

**Cost Optimization Tips:**
1. Use Reserved Instances for 30% savings
2. Enable auto-scaling to handle traffic spikes
3. Use CloudFront for static content
4. Monitor and stop unused resources
5. Set up billing alerts

## Support Contacts

- AWS Support: https://console.aws.amazon.com/support/
- Your Domain Registrar: [Your registrar]
- MongoDB Support: https://support.mongodb.com/
- Firebase Support: https://firebase.google.com/support/

## Important Notes

⚠️ **SECURITY:**
- Never commit .env file to git
- Keep SSH key secure
- Rotate API keys regularly
- Enable MFA on AWS account

⚠️ **BACKUPS:**
- Test backup restoration monthly
- Keep backups in multiple regions
- Document backup procedures

⚠️ **MONITORING:**
- Check logs daily
- Review costs weekly
- Monitor performance metrics
- Set up alerts for anomalies

---

**Deployment Status: Ready to Deploy** ✅
