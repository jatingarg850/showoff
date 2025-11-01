const express = require('express');
const router = express.Router();
const {
  addPaymentCard,
  getPaymentCards,
  deletePaymentCard,
  setDefaultCard,
  updateBillingInfo,
  getBillingInfo,
} = require('../controllers/paymentController');
const { protect } = require('../middleware/auth');

router.post('/cards', protect, addPaymentCard);
router.get('/cards', protect, getPaymentCards);
router.delete('/cards/:cardId', protect, deletePaymentCard);
router.put('/cards/:cardId/default', protect, setDefaultCard);
router.put('/billing', protect, updateBillingInfo);
router.get('/billing', protect, getBillingInfo);

module.exports = router;