const express = require('express');
const router = express.Router();
const {
  submitKYC,
  getKYCStatus,
  getAllKYC,
  getKYCById,
  approveKYC,
  rejectKYC,
  requestResubmission
} = require('../controllers/kycController');
const { protect, adminOnly } = require('../middleware/auth');

// User routes
router.post('/submit', protect, submitKYC);
router.get('/status', protect, getKYCStatus);

// Admin routes
router.get('/admin/all', protect, adminOnly, getAllKYC);
router.get('/admin/:id', protect, adminOnly, getKYCById);
router.put('/admin/:id/approve', protect, adminOnly, approveKYC);
router.put('/admin/:id/reject', protect, adminOnly, rejectKYC);
router.put('/admin/:id/resubmit', protect, adminOnly, requestResubmission);

module.exports = router;
