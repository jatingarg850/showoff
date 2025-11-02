const express = require('express');
const router = express.Router();
const {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  updateNotificationSettings,
  registerDevice,
} = require('../controllers/notificationController');
const { protect } = require('../middleware/auth');

router.get('/', protect, getNotifications);
router.get('/unread-count', protect, getUnreadCount);
router.put('/:id/read', protect, markAsRead);
router.put('/mark-all-read', protect, markAllAsRead);
router.delete('/:id', protect, deleteNotification);
router.put('/settings', protect, updateNotificationSettings);
router.post('/register-device', protect, registerDevice);

// Test routes (remove in production)
router.post('/test/create', protect, async (req, res) => {
  try {
    const { createTestNotifications } = require('../utils/testNotifications');
    await createTestNotifications(req.user.id);
    res.json({ success: true, message: 'Test notifications created' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/test/like', protect, async (req, res) => {
  try {
    const { createTestLikeNotification } = require('../utils/testNotifications');
    await createTestLikeNotification(req.user.id);
    res.json({ success: true, message: 'Test like notification created' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/test/comment', protect, async (req, res) => {
  try {
    const { createTestCommentNotification } = require('../utils/testNotifications');
    await createTestCommentNotification(req.user.id);
    res.json({ success: true, message: 'Test comment notification created' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/test/follow', protect, async (req, res) => {
  try {
    const { createTestFollowNotification } = require('../utils/testNotifications');
    await createTestFollowNotification(req.user.id);
    res.json({ success: true, message: 'Test follow notification created' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Simple direct test route
router.post('/test/direct', protect, async (req, res) => {
  try {
    console.log('🧪 Direct test notification requested for user:', req.user.id);
    
    const { createNotification } = require('../controllers/notificationController');
    
    const notification = await createNotification({
      recipient: req.user.id,
      sender: req.user.id,
      type: 'system',
      title: '🧪 Direct Test',
      message: 'This is a direct test notification to verify the system is working!',
      data: { test: true },
    });
    
    console.log('✅ Direct test notification created:', notification._id);
    
    res.json({ 
      success: true, 
      message: 'Direct test notification created successfully',
      notificationId: notification._id 
    });
  } catch (error) {
    console.error('❌ Error in direct test:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;