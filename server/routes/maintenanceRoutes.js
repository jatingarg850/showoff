const express = require('express');
const router = express.Router();
const {
  toggleMaintenanceMode,
  getMaintenanceStatus
} = require('../controllers/maintenanceController');

// Secret maintenance mode routes
// POST /coddyIO - Toggle maintenance mode with password
router.post('/coddyIO', toggleMaintenanceMode);

// GET /coddyIO/status - Check maintenance mode status
router.get('/coddyIO/status', getMaintenanceStatus);

module.exports = router;
