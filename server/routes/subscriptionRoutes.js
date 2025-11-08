const express = require('express');
const router = express.Router();
const {
  getPlans,
  subscribe,
  getMySubscription,
  cancelSubscription,
  getAllPlans,
  createPlan,
  updatePlan,
  deletePlan,
  getAllSubscriptions,
  adminCancelSubscription
} = require('../controllers/subscriptionController');
const { protect, adminOnly } = require('../middleware/auth');

// Public routes
router.get('/plans', getPlans);

// User routes
router.post('/subscribe', protect, subscribe);
router.get('/my-subscription', protect, getMySubscription);
router.put('/cancel', protect, cancelSubscription);

// Admin routes
router.get('/admin/plans', protect, adminOnly, getAllPlans);
router.post('/admin/plans', protect, adminOnly, createPlan);
router.put('/admin/plans/:id', protect, adminOnly, updatePlan);
router.delete('/admin/plans/:id', protect, adminOnly, deletePlan);
router.get('/admin/subscriptions', protect, adminOnly, getAllSubscriptions);
router.put('/admin/subscriptions/:id/cancel', protect, adminOnly, adminCancelSubscription);

module.exports = router;
