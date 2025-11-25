const express = require('express');
const router = express.Router();
const { 
  searchUsers,
  updatePrivacySettings,
  updateNotificationSettings,
  deleteAccount,
  downloadUserData,
  updateFCMToken
} = require('../controllers/userController');
const { protect } = require('../middleware/auth');

router.get('/search', protect, searchUsers);
router.put('/privacy-settings', protect, updatePrivacySettings);
router.put('/notification-settings', protect, updateNotificationSettings);
router.delete('/delete-account', protect, deleteAccount);
router.get('/download-data', protect, downloadUserData);
router.post('/fcm-token', protect, updateFCMToken);

module.exports = router;
