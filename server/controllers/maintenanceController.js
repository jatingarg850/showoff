// Global maintenance mode state
let maintenanceMode = false;

// @desc    Toggle maintenance mode (SECRET ROUTE)
// @route   POST /coddyIO
// @access  Secret (password protected)
exports.toggleMaintenanceMode = async (req, res) => {
  try {
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password required'
      });
    }

    // Check password
    if (password === 'jatingarg') {
      // Turn ON maintenance mode
      maintenanceMode = true;
      console.log('🔧 MAINTENANCE MODE ENABLED');
      
      return res.status(200).json({
        success: true,
        message: 'Maintenance mode ENABLED',
        maintenanceMode: true,
        timestamp: new Date().toISOString()
      });
    } else if (password === 'paid') {
      // Turn OFF maintenance mode
      maintenanceMode = false;
      console.log('✅ MAINTENANCE MODE DISABLED');
      
      return res.status(200).json({
        success: true,
        message: 'Maintenance mode DISABLED',
        maintenanceMode: false,
        timestamp: new Date().toISOString()
      });
    } else {
      // Invalid password
      console.warn('⚠️ Invalid maintenance mode password attempt');
      
      return res.status(401).json({
        success: false,
        message: 'Invalid password'
      });
    }
  } catch (error) {
    console.error('❌ Maintenance mode error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get maintenance mode status (SECRET ROUTE)
// @route   GET /coddyIO/status
// @access  Secret
exports.getMaintenanceStatus = async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      maintenanceMode: maintenanceMode,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Middleware to check maintenance mode
exports.checkMaintenanceMode = (req, res, next) => {
  // Allow maintenance mode endpoints themselves
  if (req.path === '/coddyIO' || req.path === '/coddyIO/status') {
    return next();
  }

  // Allow admin routes even in maintenance mode
  if (req.path.startsWith('/admin')) {
    return next();
  }

  // If maintenance mode is ON, block all other requests
  if (maintenanceMode) {
    // For API requests, return JSON
    if (req.path.startsWith('/api')) {
      return res.status(503).json({
        success: false,
        message: 'Site is under maintenance. Please try again later.',
        maintenanceMode: true
      });
    }
    
    // For web requests, render maintenance page
    return res.status(503).render('maintenance', {
      title: 'Under Maintenance',
      message: 'We are currently performing scheduled maintenance. Please check back soon!'
    });
  }

  next();
};

// Export maintenance mode state getter
exports.isMaintenanceMode = () => maintenanceMode;

module.exports = exports;
