const express = require('express');
const router = express.Router();
const {
  createGroup,
  getGroups,
  getGroup,
  joinGroup,
  leaveGroup,
  sendMessage,
  getMessages,
  getMyGroups,
  checkMembership,
} = require('../controllers/groupController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Public routes
router.get('/', getGroups);
router.get('/:id', getGroup);

// Protected routes
router.post('/', protect, upload.fields([
  { name: 'banner', maxCount: 1 },
  { name: 'logo', maxCount: 1 }
]), createGroup);
router.get('/my/groups', protect, getMyGroups);
router.get('/:id/membership', protect, checkMembership);
router.post('/:id/join', protect, joinGroup);
router.post('/:id/leave', protect, leaveGroup);
router.post('/:id/messages', protect, sendMessage);
router.get('/:id/messages', protect, getMessages);

module.exports = router;
