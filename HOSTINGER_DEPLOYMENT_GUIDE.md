# Hostinger Shared Hosting Deployment Guide (hPanel)

## Prerequisites
- Hostinger shared hosting account with Node.js support
- Access to hPanel
- Your server code ready in the `server` folder
- MongoDB Atlas account (for database)

## Step 1: Prepare Your Server for Deployment

### 1.1 Update package.json
Make sure your `server/package.json` has a start script:
```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
```

### 1.2 Update Environment Variables
Create a production `.env` file with your production settings:
```env
PORT=3000
NODE_ENV=production
MONGODB_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your_production_jwt_secret
AUTHKEY_API_KEY=your_authkey_api_key
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY=your_firebase_private_key
FIREBASE_CLIENT_EMAIL=your_firebase_client_email
```

### 1.3 Create .htaccess for Node.js
Create a `.htaccess` file in your server root:
```apache
# Enable Node.js application
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ /[your-app-name]/server.js [L]

# Set Node.js version (if needed)
AddHandler application/x-httpd-ea-nodejs .js
```

## Step 2: Setup MongoDB Atlas (Database)

### 2.1 Create MongoDB Atlas Cluster
1. Go to https://www.mongodb.com/cloud/atlas
2. Sign up or log in
3. Create a new cluster (Free tier available)
4. Click "Connect" → "Connect your application"
5. Copy the connection string
6. Replace `<password>` with your database password
7. Add your Hostinger server IP to IP whitelist (or use 0.0.0.0/0 for all IPs)

### 2.2 Update Connection String
Update your `.env` file with the MongoDB Atlas connection string:
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/showoff?retryWrites=true&w=majority
```

## Step 3: Access hPanel

1. Log in to your Hostinger account
2. Go to hPanel dashboard
3. Navigate to your hosting plan

## Step 4: Enable Node.js Application

### 4.1 Setup Node.js in hPanel
1. In hPanel, go to **Advanced** → **Node.js**
2. Click **Create Application**
3. Configure:
   - **Node.js version**: Select latest (18.x or higher)
   - **Application mode**: Production
   - **Application root**: `/public_html/api` (or your preferred path)
   - **Application URL**: `yourdomain.com/api` or `api.yourdomain.com`
   - **Application startup file**: `server.js`

### 4.2 Set Environment Variables
1. In the Node.js application settings
2. Click **Environment Variables**
3. Add all variables from your `.env` file:
   - PORT=3000
   - NODE_ENV=production
   - MONGODB_URI=your_connection_string
   - JWT_SECRET=your_secret
   - etc.

## Step 5: Upload Server Files

### Method 1: Using File Manager (Recommended for beginners)

1. In hPanel, go to **Files** → **File Manager**
2. Navigate to your application root (e.g., `/public_html/api`)
3. Upload your server files:
   - Upload `server.js`
   - Upload `package.json`
   - Upload all folders: `controllers`, `models`, `routes`, `utils`, `middleware`, `public`
   - **DO NOT** upload `node_modules` folder
   - **DO NOT** upload `.env` file (use environment variables in hPanel)

### Method 2: Using FTP/SFTP

1. In hPanel, go to **Files** → **FTP Accounts**
2. Create or use existing FTP account
3. Note the FTP credentials:
   - Host: ftp.yourdomain.com
   - Username: your_ftp_username
   - Password: your_ftp_password
   - Port: 21 (FTP) or 22 (SFTP)

4. Use FileZilla or any FTP client:
   - Connect to your server
   - Navigate to `/public_html/api`
   - Upload all server files (except node_modules and .env)

### Method 3: Using Git (Advanced)

1. In hPanel, go to **Advanced** → **SSH Access**
2. Enable SSH access
3. Connect via SSH:
```bash
ssh username@yourdomain.com
```

4. Navigate to your app directory:
```bash
cd public_html/api
```

5. Clone your repository:
```bash
git clone https://github.com/yourusername/your-repo.git .
```

## Step 6: Install Dependencies

### Via hPanel Node.js Manager
1. Go to **Advanced** → **Node.js**
2. Click on your application
3. Click **Run NPM Install**
4. Wait for installation to complete

### Via SSH (Alternative)
```bash
cd public_html/api
npm install --production
```

## Step 7: Start the Application

### Via hPanel
1. Go to **Advanced** → **Node.js**
2. Click on your application
3. Click **Start Application** or **Restart Application**
4. Check status - should show "Running"

### Via SSH
```bash
cd public_html/api
npm start
```

## Step 8: Configure Domain/Subdomain

### Option 1: Subdomain (Recommended)
1. In hPanel, go to **Domains** → **Subdomains**
2. Create subdomain: `api.yourdomain.com`
3. Point it to your application root: `/public_html/api`

### Option 2: Main Domain Path
1. Use: `yourdomain.com/api`
2. Already configured if you set application root to `/public_html/api`

## Step 9: Update Flutter App Configuration

Update your Flutter app's API configuration:

```dart
// apps/lib/config/api_config.dart
class ApiConfig {
  // Production URL
  static const String baseUrl = 'https://api.yourdomain.com';
  // or
  // static const String baseUrl = 'https://yourdomain.com/api';
  
  static const String socketUrl = baseUrl;
}
```

## Step 10: Test Your Deployment

### 10.1 Test API Endpoints
```bash
# Test health endpoint
curl https://api.yourdomain.com/health

# Test API
curl https://api.yourdomain.com/api/health
```

### 10.2 Check Application Logs
1. In hPanel → **Advanced** → **Node.js**
2. Click on your application
3. View **Application Logs**
4. Check for errors

### 10.3 Test from Flutter App
1. Update API URL in Flutter app
2. Rebuild the app
3. Test all features:
   - User registration/login
   - Post creation
   - Notifications
   - File uploads

## Step 11: Setup SSL Certificate (HTTPS)

1. In hPanel, go to **Security** → **SSL/TLS**
2. Enable **Free SSL Certificate** (Let's Encrypt)
3. Wait for activation (5-15 minutes)
4. Force HTTPS redirect:
   - Go to **Advanced** → **Force HTTPS**
   - Enable for your domain

## Common Issues & Solutions

### Issue 1: Application Won't Start
**Solution:**
- Check Node.js version compatibility
- Verify all environment variables are set
- Check application logs for errors
- Ensure `server.js` is in the correct location

### Issue 2: Database Connection Failed
**Solution:**
- Verify MongoDB Atlas connection string
- Check IP whitelist in MongoDB Atlas
- Add Hostinger server IP or use 0.0.0.0/0
- Test connection string locally first

### Issue 3: File Upload Not Working
**Solution:**
- Check folder permissions (755 for folders, 644 for files)
- Ensure `uploads` folder exists and is writable
- Update file paths in your code to use absolute paths

### Issue 4: Port Already in Use
**Solution:**
- Hostinger assigns ports automatically
- Don't hardcode port in server.js
- Use: `const PORT = process.env.PORT || 3000;`

### Issue 5: Module Not Found
**Solution:**
- Run `npm install` again
- Check `package.json` dependencies
- Clear npm cache: `npm cache clean --force`

### Issue 6: WebSocket Connection Failed
**Solution:**
- Ensure WebSocket support is enabled
- Use Socket.IO with polling fallback
- Check firewall settings

## File Structure on Server

```
/public_html/api/
├── server.js
├── package.json
├── package-lock.json
├── controllers/
├── models/
├── routes/
├── middleware/
├── utils/
├── public/
├── uploads/
└── node_modules/ (auto-generated)
```

## Performance Optimization

### 1. Enable Compression
Add to your server.js:
```javascript
const compression = require('compression');
app.use(compression());
```

### 2. Use PM2 for Process Management (if available)
```bash
npm install -g pm2
pm2 start server.js --name showoff-api
pm2 save
pm2 startup
```

### 3. Enable Caching
Add caching headers for static files in your server.js

### 4. Optimize Database Queries
- Use indexes in MongoDB
- Limit query results
- Use pagination

## Monitoring & Maintenance

### Check Application Status
1. hPanel → **Advanced** → **Node.js**
2. View application status and logs

### Update Application
1. Upload new files via FTP/File Manager
2. Or pull latest code via Git
3. Run `npm install` if dependencies changed
4. Restart application in hPanel

### Backup
1. Regular database backups via MongoDB Atlas
2. Backup server files via hPanel File Manager
3. Keep Git repository updated

## Security Checklist

- ✅ Use HTTPS (SSL certificate)
- ✅ Set strong JWT_SECRET
- ✅ Enable CORS with specific origins
- ✅ Validate all user inputs
- ✅ Use environment variables for secrets
- ✅ Keep dependencies updated
- ✅ Implement rate limiting
- ✅ Use helmet.js for security headers
- ✅ Sanitize file uploads
- ✅ Regular security audits

## Support Resources

- **Hostinger Support**: https://www.hostinger.com/tutorials
- **Node.js Documentation**: https://nodejs.org/docs
- **MongoDB Atlas**: https://docs.atlas.mongodb.com
- **Hostinger Community**: https://www.hostinger.com/forum

## Quick Commands Reference

```bash
# SSH into server
ssh username@yourdomain.com

# Navigate to app
cd public_html/api

# Install dependencies
npm install --production

# Start application
npm start

# View logs
tail -f logs/app.log

# Restart application (via PM2)
pm2 restart showoff-api

# Check application status
pm2 status
```

## Troubleshooting Checklist

- [ ] Node.js version is compatible (18.x+)
- [ ] All environment variables are set in hPanel
- [ ] MongoDB Atlas connection string is correct
- [ ] IP whitelist includes server IP in MongoDB Atlas
- [ ] All files uploaded correctly (no node_modules)
- [ ] npm install completed successfully
- [ ] Application is started in hPanel
- [ ] SSL certificate is active
- [ ] Domain/subdomain points to correct directory
- [ ] Firewall allows HTTP/HTTPS traffic
- [ ] Application logs show no errors

## Next Steps After Deployment

1. **Test thoroughly** - Test all API endpoints
2. **Monitor performance** - Check response times and errors
3. **Setup monitoring** - Use tools like UptimeRobot
4. **Configure backups** - Regular database and file backups
5. **Update Flutter app** - Point to production API
6. **Submit to app stores** - Deploy Flutter app to Play Store/App Store

---

**Note**: Hostinger shared hosting has limitations. For better performance and scalability, consider upgrading to VPS or cloud hosting (AWS, DigitalOcean, etc.) as your app grows.
