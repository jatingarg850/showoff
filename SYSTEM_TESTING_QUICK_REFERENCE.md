# System Integration Testing - Quick Reference

## Quick Start

### Access Testing Panel
```
URL: http://localhost:3000/admin/system-testing
Login: admin@showofflife.com / admin123
```

## Test Categories at a Glance

| Category | Tests | Purpose |
|----------|-------|---------|
| **Database** | 5 | MongoDB connectivity and collections |
| **API** | 5 | REST API endpoints |
| **Auth** | 5 | Authentication flows |
| **Notifications** | 4 | FCM and push notifications |
| **Payments** | 4 | Stripe & Razorpay integration |
| **Storage** | 3 | Wasabi S3 file storage |
| **Cache** | 4 | Redis caching system |
| **Email** | 4 | SMTP and email services |

## Common Test Scenarios

### Pre-Deployment Checklist
```
1. Run Database Tests → All Pass
2. Run API Tests → All Pass
3. Run Auth Tests → All Pass
4. Run Notification Tests → All Pass
5. Run Payment Tests → All Pass
```

### Daily Health Check
```
1. Database Connection
2. API Health Check
3. FCM Connection
4. Stripe Integration
5. Wasabi Connection
```

### Troubleshooting Flow
```
1. Run Health Check
2. If failed, run category tests
3. If category failed, run individual tests
4. Check error logs
5. Review environment config
```

## Test Status Meanings

| Status | Color | Meaning |
|--------|-------|---------|
| ✓ Passed | Green | Test successful |
| ✗ Failed | Red | Test failed - check error |
| ⏳ Pending | Yellow | Not yet executed |
| ⟳ Running | Blue | Currently executing |

## Quick Fixes

### Database Connection Failed
```
1. Check MongoDB is running
2. Verify MONGODB_URI in .env
3. Check network connectivity
```

### API Tests Failed
```
1. Verify server is running
2. Check server logs
3. Verify API endpoints exist
```

### Payment Tests Failed
```
1. Add STRIPE_SECRET_KEY to .env
2. Add RAZORPAY_KEY_ID to .env
3. Verify API keys are correct
```

### Storage Tests Failed
```
1. Add WASABI_ACCESS_KEY to .env
2. Add WASABI_SECRET_KEY to .env
3. Verify bucket exists
```

### Cache Tests Failed
```
1. Verify Redis is running
2. Check REDIS_URL in .env
3. Verify network connectivity
```

### Email Tests Failed
```
1. Add SMTP_HOST to .env
2. Add SMTP_USER to .env
3. Add SMTP_PASS to .env
4. Verify SMTP settings
```

## Test Execution Tips

### Run Single Test
1. Select category
2. Click "Run" button on test
3. View results in modal

### Run All Tests
1. Select category
2. Click "Run All Tests"
3. Tests run sequentially

### View Test Details
1. Click test name
2. View full log output
3. Check error details

## Environment Variables Checklist

```
✓ MONGODB_URI
✓ FIREBASE_PROJECT_ID
✓ STRIPE_SECRET_KEY
✓ RAZORPAY_KEY_ID
✓ WASABI_ACCESS_KEY
✓ REDIS_URL
✓ SMTP_HOST
```

## Performance Benchmarks

| Test | Expected Time |
|------|----------------|
| Database Connection | < 100ms |
| API Health Check | < 50ms |
| Auth Tests | < 200ms |
| Payment Tests | < 500ms |
| Storage Tests | < 1000ms |

## Troubleshooting Checklist

- [ ] Server is running
- [ ] Database is connected
- [ ] All environment variables set
- [ ] Network connectivity OK
- [ ] Services are running (Redis, Firebase, etc.)
- [ ] API keys are valid
- [ ] Firewall rules allow connections
- [ ] No rate limiting issues

## Common Error Messages

### "Database connection failed"
→ MongoDB not running or connection string wrong

### "API endpoint not found"
→ Server not running or endpoint not implemented

### "Authentication failed"
→ Invalid credentials or token expired

### "Payment gateway error"
→ API keys not configured or invalid

### "Storage connection failed"
→ Wasabi credentials not configured

### "Cache connection failed"
→ Redis not running or URL incorrect

### "Email service error"
→ SMTP credentials not configured

## Next Steps

1. **After Successful Tests**: Deploy with confidence
2. **After Failed Tests**: Fix issues before deployment
3. **Regular Monitoring**: Run tests daily
4. **Documentation**: Keep test results for audit trail

## Support Resources

- Full Guide: `SYSTEM_INTEGRATION_TESTING_GUIDE.md`
- Admin Panel: `http://localhost:3000/admin`
- Server Logs: Check `server/logs/`
- Database: MongoDB Atlas or local instance

---

**Quick Reference v1.0** | Last Updated: December 2024
