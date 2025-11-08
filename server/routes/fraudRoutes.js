const express = require('express');
const router = express.Router();
const {
  getFraudDashboard,
  getFraudLogs,
  getUserRiskProfile,
  reviewFraudIncident,
  manuallyLogFraud,
  getSuspiciousIPs,
  blockIP
} = require('../controllers/fraudController');
const { protect, adminOnly } = require('../middleware/auth');

// All routes are admin-only
router.use(protect, adminOnly);

router.get('/dashboard', getFraudDashboard);
router.get('/logs', getFraudLogs);
router.get('/user/:userId', getUserRiskProfile);
router.put('/:id/review', reviewFraudIncident);
router.post('/log', manuallyLogFraud);
router.get('/suspicious-ips', getSuspiciousIPs);
router.put('/ip/:ipAddress/block', blockIP);

module.exports = router;
