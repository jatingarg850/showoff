const express = require('express');
const router = express.Router();
const {
  getProducts,
  getProduct,
  getNewProducts,
  getPopularProducts,
  getProductsByCategory,
} = require('../controllers/productController');

router.get('/', getProducts);
router.get('/section/new', getNewProducts);
router.get('/section/popular', getPopularProducts);
router.get('/category/:category', getProductsByCategory);
router.get('/:id', getProduct);

module.exports = router;
