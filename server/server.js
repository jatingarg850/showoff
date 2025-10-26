require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const connectDatabase = require('./config/database');

// Initialize express app
const app = express();

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
app.use('/api/coins', require('./routes/coinRoutes'));
app.use('/api/withdrawal', require('./routes/withdrawalRoutes'));
app.use('/api/products', require('./routes/productRoutes'));
app.use('/api/cart', require('./routes/cartRoutes'));
app.use('/api/orders', require('./routes/orderRoutes'));

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
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

app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           ShowOff.life API Server                         ║
║                                                           ║
║   Server running on port ${PORT}                          ║  
║   Environment: ${process.env.NODE_ENV || 'development'}   ║       
║                                                           ║
║   API Documentation: http://localhost:${PORT}/            ║  
║   Health Check: http://localhost:${PORT}/health           ║ 
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
  `);
});

module.exports = app;
