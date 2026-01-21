const express = require('express');
const router = express.Router();
const {
  createPost,
  createPostWithUrl,
  getFeed,
  getUserPosts,
  getUserLikedPosts,
  toggleLike,
  addComment,
  getComments,
  incrementView,
  toggleBookmark,
  sharePost,
  getUserBookmarks,
  getPostStats,
  deletePost,
} = require('../controllers/postController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Create post with direct URL (no file upload)
router.post('/create-with-url', protect, createPostWithUrl);

// Create post (with file upload)
router.post('/', protect, upload.fields([
  { name: 'media', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 }
]), createPost);
router.get('/feed', getFeed);
router.get('/user/:userId', getUserPosts);
router.get('/user/:userId/liked', getUserLikedPosts);
router.post('/:id/like', protect, toggleLike);
router.post('/:id/comment', protect, addComment);
router.get('/:id/comments', getComments);
router.post('/:id/view', incrementView);
router.post('/:id/bookmark', protect, toggleBookmark);
router.post('/:id/share', protect, sharePost);
router.get('/bookmarks', protect, getUserBookmarks);
router.get('/:id/stats', protect, getPostStats);
router.delete('/:id', protect, deletePost);

module.exports = router;
