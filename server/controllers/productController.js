const Product = require('../models/Product');

// @desc    Get all products
// @route   GET /api/products
// @access  Public
exports.getProducts = async (req, res) => {
  try {
    const { category, badge, search, page = 1, limit = 20 } = req.query;
    
    const query = { isActive: true };
    
    if (category) query.category = category;
    if (badge) query.badge = badge;
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (page - 1) * limit;
    
    const products = await Product.find(query)
      .skip(skip)
      .limit(parseInt(limit))
      .sort({ createdAt: -1 });

    const total = await Product.countDocuments(query);

    res.status(200).json({
      success: true,
      data: products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get single product
// @route   GET /api/products/:id
// @access  Public
exports.getProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
      });
    }

    res.status(200).json({
      success: true,
      data: product,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get new products
// @route   GET /api/products/section/new
// @access  Public
exports.getNewProducts = async (req, res) => {
  try {
    const products = await Product.find({ isActive: true })
      .sort({ createdAt: -1 })
      .limit(10);

    res.status(200).json({
      success: true,
      data: products,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get popular products
// @route   GET /api/products/section/popular
// @access  Public
exports.getPopularProducts = async (req, res) => {
  try {
    const products = await Product.find({ isActive: true })
      .sort({ rating: -1, reviewCount: -1 })
      .limit(10);

    res.status(200).json({
      success: true,
      data: products,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get products by category
// @route   GET /api/products/category/:category
// @access  Public
exports.getProductsByCategory = async (req, res) => {
  try {
    const category = req.params.category;
    let products;

    // Handle special categories
    if (category === 'new') {
      // Get new products (created in last 30 days)
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      products = await Product.find({
        isActive: true,
        createdAt: { $gte: thirtyDaysAgo }
      }).sort({ createdAt: -1 });
    } else if (category === 'popular') {
      // Get popular products (sorted by views or purchases)
      products = await Product.find({
        isActive: true
      }).sort({ views: -1, purchases: -1 }).limit(20);
    } else {
      // Regular category
      products = await Product.find({
        category: category,
        isActive: true,
      });
    }

    const count = products.length;

    res.status(200).json({
      success: true,
      data: products,
      count,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
