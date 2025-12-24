# System Integration Testing Guide

## Overview
The System Integration Testing section in the admin panel provides comprehensive testing capabilities for all major system components and integrations. This allows admins to verify system health, diagnose issues, and ensure all services are operational.

## Accessing System Testing

### URL
`http://localhost:3000/admin/system-testing`

### Authentication
- Login with admin credentials: `admin@showofflife.com` / `admin123`
- Navigate to "System Testing" in the sidebar

## Test Categories

### 1. Database Tests

#### Database Connection
- **Purpose**: Verify MongoDB connection
- **Tests**: Connection status, response time, host, database name
- **Success Criteria**: Connection state = 1 (Connected)

#### Users Collection
- **Purpose**: Test users collection accessibility
- **Tests**: Document count, sample user retrieval
- **Success Criteria**: Can read user documents

#### Posts Collection
- **Purpose**: Test posts collection accessibility
- **Tests**: Document count, sample post retrieval
- **Success Criteria**: Can read post documents

#### Transactions Collection
- **Purpose**: Test transactions collection accessibility
- **Tests**: Document count, total coins calculation
- **Success Criteria**: Can read and aggregate transaction data

#### Database Indexes
- **Purpose**: Verify all database indexes are created
- **Tests**: Index count for each collection
- **Success Criteria**: All expected indexes present

### 2. API Endpoint Tests

#### Health Check
- **Purpose**: Verify API is responding
- **Tests**: Server status, uptime, timestamp
- **Success Criteria**: API responds with 200 status

#### Users API
- **Purpose**: Test user endpoints
- **Tests**: User retrieval, response time
- **Success Criteria**: Can fetch user data

#### Posts API
- **Purpose**: Test post endpoints
- **Tests**: Post retrieval, response time
- **Success Criteria**: Can fetch post data

#### Coins API
- **Purpose**: Test coin/transaction endpoints
- **Tests**: Transaction retrieval, response time
- **Success Criteria**: Can fetch transaction data

#### Auth API
- **Purpose**: Test authentication endpoints
- **Tests**: Auth methods availability
- **Success Criteria**: Auth endpoints operational

### 3. Authentication Tests

#### User Registration
- **Purpose**: Verify registration endpoint
- **Tests**: Endpoint availability, POST method support
- **Success Criteria**: Endpoint operational

#### User Login
- **Purpose**: Verify login endpoint
- **Tests**: Endpoint availability, authentication flow
- **Success Criteria**: Endpoint operational

#### Token Validation
- **Purpose**: Verify JWT token validation
- **Tests**: Token presence, validity
- **Success Criteria**: Token validation working

#### Token Refresh
- **Purpose**: Verify token refresh mechanism
- **Tests**: Refresh endpoint availability
- **Success Criteria**: Endpoint operational

#### User Logout
- **Purpose**: Verify logout functionality
- **Tests**: Logout endpoint availability
- **Success Criteria**: Endpoint operational

### 4. Notification Tests

#### FCM Connection
- **Purpose**: Verify Firebase Cloud Messaging setup
- **Tests**: Firebase configuration, service availability
- **Success Criteria**: FCM configured and ready

#### Send Notification
- **Purpose**: Verify notification sending capability
- **Tests**: Endpoint availability, notification delivery
- **Success Criteria**: Can send notifications

#### Receive Notification
- **Purpose**: Verify notification receiving capability
- **Tests**: Listener setup, message reception
- **Success Criteria**: Can receive notifications

#### Topic Subscriptions
- **Purpose**: Verify FCM topic subscriptions
- **Tests**: Topic subscription capability
- **Success Criteria**: Topics working

### 5. Payment Tests

#### Stripe Integration
- **Purpose**: Verify Stripe payment gateway
- **Tests**: API key configuration, gateway availability
- **Success Criteria**: Stripe configured and ready

#### Razorpay Integration
- **Purpose**: Verify Razorpay payment gateway
- **Tests**: API key configuration, gateway availability
- **Success Criteria**: Razorpay configured and ready

#### Payment Webhooks
- **Purpose**: Verify webhook handling
- **Tests**: Webhook endpoint availability
- **Success Criteria**: Webhooks operational

#### Payment Verification
- **Purpose**: Verify payment verification process
- **Tests**: Verification endpoint availability
- **Success Criteria**: Can verify payments

### 6. Storage Tests

#### Wasabi Connection
- **Purpose**: Verify Wasabi S3 storage connection
- **Tests**: Access key configuration, connection status
- **Success Criteria**: Wasabi configured and ready

#### File Upload
- **Purpose**: Verify file upload capability
- **Tests**: Upload endpoint availability
- **Success Criteria**: Can upload files

#### File Download
- **Purpose**: Verify file download capability
- **Tests**: Download endpoint availability
- **Success Criteria**: Can download files

#### File Deletion
- **Purpose**: Verify file deletion capability
- **Tests**: Delete endpoint availability
- **Success Criteria**: Can delete files

### 7. Cache Tests

#### Redis Connection
- **Purpose**: Verify Redis cache connection
- **Tests**: Redis URL configuration, connection status
- **Success Criteria**: Redis configured and ready

#### Cache Set
- **Purpose**: Verify cache write operations
- **Tests**: SET operation functionality
- **Success Criteria**: Can write to cache

#### Cache Get
- **Purpose**: Verify cache read operations
- **Tests**: GET operation functionality
- **Success Criteria**: Can read from cache

#### Cache Clear
- **Purpose**: Verify cache clearing
- **Tests**: CLEAR operation functionality
- **Success Criteria**: Can clear cache

### 8. Email Tests

#### SMTP Connection
- **Purpose**: Verify email SMTP connection
- **Tests**: SMTP host configuration, connection status
- **Success Criteria**: SMTP configured and ready

#### Send Email
- **Purpose**: Verify email sending capability
- **Tests**: Email endpoint availability
- **Success Criteria**: Can send emails

#### OTP Email
- **Purpose**: Verify OTP email sending
- **Tests**: OTP email endpoint availability
- **Success Criteria**: Can send OTP emails

#### Email Verification
- **Purpose**: Verify email verification process
- **Tests**: Verification endpoint availability
- **Success Criteria**: Can verify emails

## Running Tests

### Run Individual Test
1. Select a test category
2. Click the **Run** button next to a specific test
3. View results in the modal window

### Run All Tests in Category
1. Select a test category
2. Click **Run All Tests** button
3. Tests execute sequentially with 1-second intervals

### Test Results

#### Passed Test
- Status: Green badge with checkmark
- Shows success message
- Displays test details

#### Failed Test
- Status: Red badge with X
- Shows error message
- Displays error details

#### Pending Test
- Status: Yellow badge with circle
- Test not yet executed
- Ready to run

#### Running Test
- Status: Blue badge with spinner
- Test currently executing
- Wait for completion

## Test Results Interpretation

### Success Indicators
- ✓ Green status badge
- "Test passed" message
- Relevant details displayed
- No error messages

### Failure Indicators
- ✗ Red status badge
- Error message displayed
- Error details in log
- Troubleshooting suggestions

### Common Issues

#### Database Connection Failed
- **Cause**: MongoDB not running or connection string incorrect
- **Solution**: 
  1. Verify MongoDB is running
  2. Check connection string in .env
  3. Verify network connectivity

#### API Endpoint Failed
- **Cause**: Server not running or endpoint not implemented
- **Solution**:
  1. Verify server is running
  2. Check endpoint implementation
  3. Review server logs

#### Payment Gateway Failed
- **Cause**: API keys not configured
- **Solution**:
  1. Add API keys to .env
  2. Verify key format
  3. Check gateway account status

#### Storage Connection Failed
- **Cause**: Wasabi credentials not configured
- **Solution**:
  1. Add Wasabi credentials to .env
  2. Verify access key and secret
  3. Check bucket configuration

#### Cache Connection Failed
- **Cause**: Redis not running or URL incorrect
- **Solution**:
  1. Verify Redis is running
  2. Check Redis URL in .env
  3. Verify network connectivity

#### Email Connection Failed
- **Cause**: SMTP credentials not configured
- **Solution**:
  1. Add SMTP credentials to .env
  2. Verify SMTP host and port
  3. Check email account settings

## Test Logs

### Log Format
```
[HH:MM:SS] [Level] Message
```

### Log Levels
- **INFO** (Blue): Informational messages
- **SUCCESS** (Green): Successful operations
- **WARNING** (Orange): Warning messages
- **ERROR** (Red): Error messages

### Reading Logs
1. Logs appear in real-time during test execution
2. Scroll to see all log entries
3. Use log details to diagnose issues

## Best Practices

### Regular Testing
- Run tests daily to monitor system health
- Run tests after deployments
- Run tests after configuration changes

### Troubleshooting
1. Run individual tests to isolate issues
2. Check test logs for error details
3. Review system logs for more information
4. Verify environment configuration

### Performance Monitoring
- Monitor test response times
- Track test execution duration
- Identify slow components

### Documentation
- Document test results
- Track recurring issues
- Maintain test history

## API Endpoints

### Test Execution
```
POST /api/admin/system-tests/{testId}
Authorization: Bearer {token}
```

### Response Format
```json
{
  "success": true/false,
  "message": "Test result message",
  "details": {
    "key": "value"
  },
  "error": "Error message if failed"
}
```

## Environment Configuration

### Required Environment Variables

#### Database
```
MONGODB_URI=mongodb://localhost:27017/showofflife
```

#### Firebase/FCM
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
```

#### Payments
```
STRIPE_SECRET_KEY=sk_test_...
RAZORPAY_KEY_ID=rzp_test_...
RAZORPAY_KEY_SECRET=...
```

#### Storage
```
WASABI_ACCESS_KEY=your-access-key
WASABI_SECRET_KEY=your-secret-key
WASABI_BUCKET=your-bucket
WASABI_REGION=us-east-1
```

#### Cache
```
REDIS_URL=redis://localhost:6379
```

#### Email
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
```

## Troubleshooting Guide

### All Tests Failing
1. Check server is running
2. Verify database connection
3. Check environment variables
4. Review server logs

### Intermittent Failures
1. Check network connectivity
2. Monitor system resources
3. Check service availability
4. Review error logs

### Slow Tests
1. Check system resources
2. Monitor network latency
3. Check database performance
4. Review service logs

## Support

For issues or questions:
1. Check this documentation
2. Review test logs
3. Check system logs
4. Contact development team

---

**Last Updated**: December 2024
**Version**: 1.0
**Status**: Production Ready
