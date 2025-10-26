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
} = require('../controllers/groupController');
const { protect } = require('../middleware/auth');

// Public routes
router.get('/', getGroups);
router.get('/:id', getGroup);

// Protected routes
router.post('/', protect, createGroup);
router.get('/my/groups', protect, getMyGroups);
router.post('/:id/join', protect, joinGroup);
router.post('/:id/leave', protect, leaveGroup);
router.post('/:id/messages', protect, sendMessage);
router.get('/:id/messages', protect, getMessages);

module.exports = router;
