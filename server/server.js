require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const http = require('http');
const socketIo = require('socket.io');
const jwt = require('jsonwebtoken');
const connectDatabase = require('./config/database');

// Initialize express app
const app = express();
const server = http.createServer(app);

// Trust proxy - needed when behind Nginx/load balancer
app.set('trust proxy', 1);

// Initialize Socket.IO
const io = socketIo(server, {
  cors: {
    origin: "*", // In production, specify your client URL
    methods: ["GET", "POST"]
  }
});

// Connect to database
connectDatabase();

// Session setup
const session = require('express-session');
app.use(session({
  secret: process.env.JWT_SECRET || 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: { 
    secure: false, 
    httpOnly: true,
    sameSite: 'lax',
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

// View engine setup
app.set('view engine', 'ejs');
app.set('views', './views');

// Middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://cdnjs.cloudflare.com", "https://fonts.googleapis.com"],
      scriptSrc: ["'self'", "'unsafe-inline'", "https://cdn.jsdelivr.net", "https://cdnjs.cloudflare.com", "https://www.phone.email"],
      scriptSrcAttr: ["'unsafe-inline'"], // Allow inline event handlers for admin panel
      fontSrc: ["'self'", "https://fonts.gstatic.com", "https://cdnjs.cloudflare.com"],
      imgSrc: ["'self'", "data:", "https:", "http:", "https://s3.ap-southeast-1.wasabisys.com", "https://via.placeholder.com"],
      mediaSrc: ["'self'", "https:", "http:", "https://s3.ap-southeast-1.wasabisys.com"],
      connectSrc: ["'self'", "https:", "http:", "ws:", "wss:", "https://www.phone.email", "https://user.phone.email"],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: []
    }
  }
}));
app.use(cors({
  origin: ['http://localhost:3000', 'https://s3.ap-southeast-1.wasabisys.com'],
  credentials: true
}));
app.use(compression());
// Increase body parser limits for large file uploads (500MB)
app.use(express.json({ limit: '500mb' }));
app.use(express.urlencoded({ extended: true, limit: '500mb' }));

// Increase request timeout for large uploads (10 minutes)
app.use((req, res, next) => {
  // Set timeout to 10 minutes for upload routes
  if (req.path.includes('/upload') || req.path.includes('/submit') || req.path.includes('/posts')) {
    req.setTimeout(600000); // 10 minutes
    res.setTimeout(600000);
  }
  next();
});

// Serve static files from uploads directory
app.use('/uploads', express.static('uploads'));

// Logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Rate limiting - More lenient for development
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: process.env.NODE_ENV === 'production' ? 100 : 1000, // 1000 requests in dev, 100 in production
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

// WebSocket Authentication Middleware
const authenticateSocket = async (socket, next) => {
  try {
    const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return next(new Error('No token provided'));
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const User = require('./models/User');
    const user = await User.findById(decoded.id).select('-password');
    
    if (!user) {
      return next(new Error('User not found'));
    }

    socket.userId = user._id.toString();
    socket.user = user;
    next();
  } catch (error) {
    next(new Error('Invalid token'));
  }
};

// WebSocket Connection Handling
io.use(authenticateSocket);

io.on('connection', (socket) => {
  console.log(`✅ User ${socket.user.username} connected via WebSocket`);
  
  // Join user-specific room
  socket.join(`user_${socket.userId}`);
  
  // Register connection
  const { registerUserConnection, unregisterUserConnection } = require('./utils/pushNotifications');
  registerUserConnection(socket.userId, socket.id);
  
  // Handle user status updates
  socket.on('updateStatus', (status) => {
    socket.broadcast.emit('userStatusUpdate', {
      userId: socket.userId,
      status,
      timestamp: new Date().toISOString()
    });
  });
  
  // Handle typing indicators
  socket.on('typing', (data) => {
    socket.to(`user_${data.recipientId}`).emit('userTyping', {
      userId: socket.userId,
      isTyping: data.isTyping
    });
  });
  
  // Handle notification acknowledgment
  socket.on('notificationRead', async (notificationId) => {
    try {
      const Notification = require('./models/Notification');
      await Notification.findByIdAndUpdate(notificationId, {
        isRead: true,
        readAt: new Date()
      });
      
      // Send updated unread count
      const unreadCount = await Notification.countDocuments({
        recipient: socket.userId,
        isRead: false
      });
      
      socket.emit('unreadCountUpdate', { unreadCount });
    } catch (error) {
      console.error('Error marking notification as read:', error);
    }
  });
  
  // Handle disconnect
  socket.on('disconnect', () => {
    console.log(`❌ User ${socket.user.username} disconnected`);
    unregisterUserConnection(socket.userId);
    
    // Broadcast user offline status
    socket.broadcast.emit('userStatusUpdate', {
      userId: socket.userId,
      status: 'offline',
      timestamp: new Date().toISOString()
    });
  });
  
  // Send initial unread count
  socket.on('getUnreadCount', async () => {
    try {
      const Notification = require('./models/Notification');
      const unreadCount = await Notification.countDocuments({
        recipient: socket.userId,
        isRead: false
      });
      
      socket.emit('unreadCountUpdate', { unreadCount });
    } catch (error) {
      console.error('Error getting unread count:', error);
    }
  });
});

// Make io available globally for other modules to access
global.io = io;

// Maintenance mode middleware
const { checkMaintenanceMode } = require('./controllers/maintenanceController');
app.use(checkMaintenanceMode);

// Secret maintenance mode routes (MUST BE BEFORE OTHER ROUTES)
app.use('/', require('./routes/maintenanceRoutes'));

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/posts', require('./routes/postRoutes'));
app.use('/api/profile', require('./routes/profileRoutes'));
app.use('/api/follow', require('./routes/followRoutes'));
app.use('/api/chat', require('./routes/chatRoutes'));
app.use('/api/groups', require('./routes/groupRoutes'));
app.use('/api/syt', require('./routes/sytRoutes'));
app.use('/api/dailyselfie', require('./routes/dailySelfieRoutes'));
app.use('/api/achievements', require('./routes/achievements'));
app.use('/api/coins', require('./routes/coinRoutes'));
app.use('/api/payments', require('./routes/paymentRoutes'));
app.use('/api/withdrawal', require('./routes/withdrawalRoutes'));
app.use('/api/products', require('./routes/productRoutes'));
app.use('/api/cart', require('./routes/cartRoutes'));
app.use('/api/orders', require('./routes/orderRoutes'));
app.use('/api/spin-wheel', require('./routes/spinWheelRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));
app.use('/api/music', require('./routes/musicRoutes'));
// Public routes (NO AUTHENTICATION REQUIRED)
app.use('/api', require('./routes/publicRoutes'));
// Admin routes (AUTHENTICATION REQUIRED)
app.use('/api/admin', require('./routes/adminRoutes'));
app.use('/api/kyc', require('./routes/kycRoutes'));
app.use('/api/fraud', require('./routes/fraudRoutes'));
app.use('/api/subscriptions', require('./routes/subscriptionRoutes'));
app.use('/api/videos', require('./routes/videoRoutes'));
app.use('/api/terms', require('./routes/termsRoutes'));
app.use('/api', require('./routes/videoAdRoutes'));

// Deep linking routes for mobile app
app.get('/reel/:postId', async (req, res) => {
  try {
    const { postId } = req.params;
    const Post = require('./models/Post');
    
    // Fetch post details
    const post = await Post.findById(postId)
      .populate('user', 'username displayName profilePicture')
      .lean();
    
    if (!post) {
      return res.status(404).render('deep-link-error', {
        title: 'Reel Not Found',
        message: 'This reel could not be found. It may have been deleted.',
        appLink: 'showofflife://app'
      });
    }
    
    // Render a page with meta tags for social sharing and deep link redirect
    res.render('deep-link-reel', {
      postId: post._id,
      title: `${post.user.displayName}'s Reel`,
      description: post.caption || 'Check out this amazing reel on ShowOff.life',
      image: post.thumbnail || 'https://via.placeholder.com/1200x630?text=ShowOff.life',
      appLink: `showofflife://reel/${postId}`,
      webLink: `https://showoff.life/reel/${postId}`
    });
  } catch (error) {
    console.error('Deep link error:', error);
    res.status(500).render('deep-link-error', {
      title: 'Error',
      message: 'An error occurred while loading this reel.',
      appLink: 'showofflife://app'
    });
  }
});

// Admin web interface routes
app.use('/admin', require('./routes/adminWebRoutes'));

// Serve admin panel static files (after authentication routes)
app.use('/admin/assets', express.static('public/admin'));

// Serve public files (for phone-login-demo.html and other static assets)
app.use('/public', express.static('public'));

// Serve app-ads.txt at root level for AdMob verification
app.use(express.static('public', {
  setHeaders: (res, path) => {
    if (path.endsWith('app-ads.txt')) {
      res.setHeader('Content-Type', 'text/plain');
      res.setHeader('Cache-Control', 'public, max-age=3600');
    }
  }
}));

// Test admin panel page
app.get('/test-admin', (req, res) => {
  res.sendFile(__dirname + '/test-admin.html');
});

// Phone.email web login demo page
app.get('/phone-login-demo', (req, res) => {
  res.sendFile(__dirname + '/public/phone-login-demo.html');
});

// Test media loading page
app.get('/test-media', async (req, res) => {
  try {
    const Post = require('./models/Post');
    const posts = await Post.find().limit(3).populate('user', 'username profilePicture');
    
    let html = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>Media Test</title>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; }
            .media-item { margin: 20px 0; padding: 20px; border: 1px solid #ccc; }
            video, img { max-width: 300px; max-height: 200px; }
        </style>
    </head>
    <body>
        <h1>Media Loading Test</h1>
    `;
    
    posts.forEach((post, index) => {
      html += `
        <div class="media-item">
          <h3>Post ${index + 1} (${post.type})</h3>
          <p>URL: ${post.mediaUrl}</p>
          ${post.type === 'video' ? 
            `<video controls><source src="${post.mediaUrl}" type="video/mp4">Video not supported</video>` :
            `<img src="${post.mediaUrl}" alt="Image" onerror="this.style.border='2px solid red'; this.alt='Failed to load'">`
          }
          <div>Status: <span id="status-${index}">Loading...</span></div>
        </div>
      `;
    });
    
    html += `
        <script>
          // Test each media URL
          ${posts.map((post, index) => `
            fetch('${post.mediaUrl}', { method: 'HEAD' })
              .then(response => {
                document.getElementById('status-${index}').textContent = 
                  response.ok ? 'Accessible ✅' : 'Failed ❌ (' + response.status + ')';
              })
              .catch(error => {
                document.getElementById('status-${index}').textContent = 'Error ❌ (' + error.message + ')';
              });
          `).join('')}
        </script>
    </body>
    </html>
    `;
    
    res.send(html);
  } catch (error) {
    res.status(500).send('Error: ' + error.message);
  }
});

// Debug media URLs
app.get('/debug-media', async (req, res) => {
  try {
    const Post = require('./models/Post');
    const posts = await Post.find().sort({ createdAt: -1 }).limit(10).populate('user', 'username profilePicture');
    const debugInfo = posts.map(post => ({
      id: post._id,
      type: post.type,
      mediaUrl: post.mediaUrl,
      fullUrl: post.mediaUrl.startsWith('http') ? post.mediaUrl : 'http://localhost:3000' + post.mediaUrl,
      userProfile: post.user?.profilePicture,
      userProfileFullUrl: post.user?.profilePicture ? (post.user.profilePicture.startsWith('http') ? post.user.profilePicture : 'http://localhost:3000' + post.user.profilePicture) : null
    }));
    res.json(debugInfo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Media proxy endpoint to serve Wasabi media with proper CORS headers
app.get('/media-proxy', async (req, res) => {
  try {
    const { url } = req.query;
    if (!url || !url.startsWith('https://s3.ap-southeast-1.wasabisys.com/')) {
      return res.status(400).json({ error: 'Invalid URL' });
    }

    const https = require('https');
    const { URL } = require('url');
    const parsedUrl = new URL(url);

    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    // Make request to Wasabi
    const options = {
      hostname: parsedUrl.hostname,
      port: 443,
      path: parsedUrl.pathname + parsedUrl.search,
      method: 'GET',
      headers: {
        'User-Agent': 'ShowOff-Admin-Panel/1.0'
      }
    };

    const proxyReq = https.request(options, (proxyRes) => {
      // Set content type based on file extension
      const contentType = proxyRes.headers['content-type'] || 
        (url.includes('.mp4') ? 'video/mp4' : 
         url.includes('.jpg') || url.includes('.jpeg') ? 'image/jpeg' :
         url.includes('.png') ? 'image/png' : 'application/octet-stream');
      
      res.setHeader('Content-Type', contentType);
      res.setHeader('Content-Length', proxyRes.headers['content-length'] || '');
      res.setHeader('Cache-Control', 'public, max-age=3600');

      proxyRes.pipe(res);
    });

    proxyReq.on('error', (error) => {
      console.error('Proxy request error:', error);
      res.status(500).json({ error: 'Failed to fetch media' });
    });

    proxyReq.end();
  } catch (error) {
    console.error('Media proxy error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  const { getActiveConnectionsCount } = require('./utils/pushNotifications');
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    websocket: {
      enabled: true,
      activeConnections: getActiveConnectionsCount(),
    },
  });
});

// Root route - Serve landing page
app.get('/', (req, res) => {
  res.render('landing');
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

const PORT = process.env.PORT || 3000;

// Set server timeout for large uploads (10 minutes)
server.timeout = 600000; // 10 minutes
server.keepAliveTimeout = 620000; // Slightly longer than timeout
server.headersTimeout = 630000; // Slightly longer than keepAliveTimeout

server.listen(PORT, async () => {
  console.log(`
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           ShowOff.life API Server                         ║
║                                                           ║
║   Server running on port ${PORT}                          ║  
║   Environment: ${process.env.NODE_ENV || 'development'}   ║       
║   WebSocket: ✅ Enabled                                   ║
║   Upload Timeout: 10 minutes                              ║
║   Max File Size: 300MB                                    ║
║                                                           ║
║   API Documentation: http://localhost:${PORT}/            ║  
║   Health Check: http://localhost:${PORT}/health           ║ 
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
  `);

  // Initialize Apache Kafka if enabled
  if (process.env.KAFKA_ENABLED === 'true') {
    try {
      const { connectProducer, connectConsumer, createTopics } = require('./config/kafka');
      const KafkaConsumerService = require('./services/kafkaConsumerService');
      
      console.log('🚀 Initializing Apache Kafka...');
      await connectProducer();
      await createTopics();
      await connectConsumer();
      await KafkaConsumerService.startConsumers();
      console.log('✅ Kafka initialized successfully');
    } catch (error) {
      console.error('❌ Kafka initialization failed:', error.message);
      console.log('⚠️  Server will continue without Kafka');
    }
  }

  // Initialize default achievements
  try {
    const { initializeAchievements } = require('./controllers/achievementController');
    await initializeAchievements(
      { user: { id: 'system' } }, 
      { 
        json: (data) => console.log('✅ Default achievements initialized:', data.message),
        status: () => ({ json: () => {} })
      }
    );
  } catch (error) {
    console.log('⚠️  Achievement initialization skipped:', error.message);
  }
});

// Export both app and io
module.exports = app;
module.exports.io = io;
