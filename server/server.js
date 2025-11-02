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

// Initialize Socket.IO
const io = socketIo(server, {
  cors: {
    origin: "*", // In production, specify your client URL
    methods: ["GET", "POST"]
  }
});

// Connect to database
connectDatabase();

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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

// Make io available to other modules
module.exports.io = io;

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

// Root route
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'ShowOff.life API Server',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      posts: '/api/posts',
      profile: '/api/profile',
      follow: '/api/follow',
      syt: '/api/syt',
      dailyselfie: '/api/dailyselfie',
      achievements: '/api/achievements',
      coins: '/api/coins',
      withdrawal: '/api/withdrawal',
    },
  });
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

server.listen(PORT, async () => {
  console.log(`
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           ShowOff.life API Server                         ║
║                                                           ║
║   Server running on port ${PORT}                          ║  
║   Environment: ${process.env.NODE_ENV || 'development'}   ║       
║   WebSocket: ✅ Enabled                                   ║
║                                                           ║
║   API Documentation: http://localhost:${PORT}/            ║  
║   Health Check: http://localhost:${PORT}/health           ║ 
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
  `);

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

module.exports = app;
