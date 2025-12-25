const express = require('express');
const router = express.Router();

// Public Ad Routes (for mobile app - NO AUTHENTICATION REQUIRED)
router.get('/rewarded-ads', require('../controllers/adminController').getAdsForApp);
router.post('/rewarded-ads/:adNumber/click', require('../controllers/adminController').trackAdClick);
router.post('/rewarded-ads/:adNumber/conversion', require('../controllers/adminController').trackAdConversion);

module.exports = router;
