const express = require('express');
const router = express.Router();
const {
  requestWithdrawal,
  getWithdrawalHistory,
  submitKYC,
  getKYCStatus,
} = require('../controllers/withdrawalController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.post('/request', protect, requestWithdrawal);
router.get('/history', protect, getWithdrawalHistory);
router.post('/kyc', protect, upload.array('documents', 5), submitKYC);
router.get('/kyc-status', protect, getKYCStatus);

module.exports = router;
