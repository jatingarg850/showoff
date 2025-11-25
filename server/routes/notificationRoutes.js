const express = require('express');
const router = express.Router();
const {
  sendCustomNotification,
  getAdminNotifications,
  getNotificationStats,
  deleteNotification,
  getRecipientCount,
  getUserNotifications,
  markNotificationAsRead,
  markAllAsRead,
  deleteUserNotification,
  getUnreadCount,
} = require('../controllers/notificationController');
const { protect, adminOnly, checkAdminSession } = require('../middleware/auth');

// User routes (for Flutter app)
router.get('/', protect, getUserNotifications);
router.get('/unread-count', protect, getUnreadCount);
router.put('/:id/read', protect, markNotificationAsRead);
router.put('/mark-all-read', protect, markAllAsRead);
router.delete('/:id', protect, deleteUserNotification);

// Admin routes (JWT-based for API)
router.post('/admin/send', protect, adminOnly, sendCustomNotification);
router.get('/admin/list', protect, adminOnly, getAdminNotifications);
router.get('/admin/:id/stats', protect, adminOnly, getNotificationStats);
router.delete('/admin/:id', protect, adminOnly, deleteNotification);
router.post('/admin/preview-count', protect, adminOnly, getRecipientCount);

// Admin routes (Session-based for web admin panel)
router.post('/admin-web/send', checkAdminSession, sendCustomNotification);
router.get('/admin-web/list', checkAdminSession, getAdminNotifications);
router.get('/admin-web/:id/stats', checkAdminSession, getNotificationStats);
router.delete('/admin-web/:id', checkAdminSession, deleteNotification);
router.post('/admin-web/preview-count', checkAdminSession, getRecipientCount);

module.exports = router;
