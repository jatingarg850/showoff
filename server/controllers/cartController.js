const Cart = require('../models/Cart');
const Product = require('../models/Product');

// @desc    Get user cart
// @route   GET /api/cart
// @access  Private
exports.getCart = async (req, res) => {
  try {
    let cart = await Cart.findOne({ user: req.user.id }).populate('items.product');

    if (!cart) {
      cart = await Cart.create({ user: req.user.id, items: [] });
    }

    res.status(200).json({
      success: true,
      data: cart,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Add item to cart
// @route   POST /api/cart/add
// @access  Private
exports.addToCart = async (req, res) => {
  try {
    const { productId, quantity = 1, size, color } = req.body;

    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
      });
    }

    let cart = await Cart.findOne({ user: req.user.id });

    if (!cart) {
      cart = await Cart.create({ user: req.user.id, items: [] });
    }

    // Check if item already exists in cart
    const existingItemIndex = cart.items.findIndex(
      item => item.product.toString() === productId && item.size === size && item.color === color
    );

    if (existingItemIndex > -1) {
      // Update quantity
      cart.items[existingItemIndex].quantity += quantity;
    } else {
      // Add new item
      cart.items.push({
        product: productId,
        quantity,
        size,
        color,
        price: product.price,
        paymentType: product.paymentType,
        coinPrice: product.coinPrice,
      });
    }

    await cart.save();
    await cart.populate('items.product');

    res.status(200).json({
      success: true,
      data: cart,
      message: 'Item added to cart',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Update cart item quantity
// @route   PUT /api/cart/update/:itemId
// @access  Private
exports.updateCartItem = async (req, res) => {
  try {
    const { quantity } = req.body;
    const { itemId } = req.params;

    const cart = await Cart.findOne({ user: req.user.id });

    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found',
      });
    }

    const item = cart.items.id(itemId);
    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Item not found in cart',
      });
    }

    if (quantity <= 0) {
      item.remove();
    } else {
      item.quantity = quantity;
    }

    await cart.save();
    await cart.populate('items.product');

    res.status(200).json({
      success: true,
      data: cart,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Remove item from cart
// @route   DELETE /api/cart/remove/:itemId
// @access  Private
exports.removeFromCart = async (req, res) => {
  try {
    const { itemId } = req.params;

    const cart = await Cart.findOne({ user: req.user.id });

    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found',
      });
    }

    cart.items.id(itemId).remove();
    await cart.save();
    await cart.populate('items.product');

    res.status(200).json({
      success: true,
      data: cart,
      message: 'Item removed from cart',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Clear cart
// @route   DELETE /api/cart/clear
// @access  Private
exports.clearCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.id });

    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found',
      });
    }

    cart.items = [];
    await cart.save();

    res.status(200).json({
      success: true,
      data: cart,
      message: 'Cart cleared',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
// @desc    Checkout cart (handle mixed payments)
// @route   POST /api/cart/checkout
// @access  Private
exports.checkout = async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.id }).populate('items.product');

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Cart is empty',
      });
    }

    // Separate items by payment type
    const coinItems = cart.items.filter(item => item.paymentType === 'coins');
    const upiItems = cart.items.filter(item => item.paymentType === 'upi');

    // Calculate totals
    let totalCoins = 0;
    let totalUPI = 0;

    coinItems.forEach(item => {
      totalCoins += (item.coinPrice || 0) * item.quantity;
    });

    upiItems.forEach(item => {
      totalUPI += item.price * item.quantity;
    });

    // Check if user has enough coins
    const User = require('../models/User');
    const user = await User.findById(req.user.id);
    
    if (totalCoins > 0 && user.coinBalance < totalCoins) {
      return res.status(400).json({
        success: false,
        message: `Insufficient coins. You need ${totalCoins} coins but have ${user.coinBalance}`,
      });
    }

    res.status(200).json({
      success: true,
      data: {
        coinItems,
        upiItems,
        totalCoins,
        totalUPI: totalUPI.toFixed(2),
        userCoinBalance: user.coinBalance,
        canProceed: user.coinBalance >= totalCoins,
      },
      message: 'Checkout summary prepared',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Process payment (complete checkout)
// @route   POST /api/cart/process-payment
// @access  Private
exports.processPayment = async (req, res) => {
  try {
    const { paymentMethod, razorpayPaymentId, razorpaySignature } = req.body;
    
    const cart = await Cart.findOne({ user: req.user.id }).populate('items.product');

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Cart is empty',
      });
    }

    // Separate items by payment type
    const coinItems = cart.items.filter(item => item.paymentType === 'coins');
    const upiItems = cart.items.filter(item => item.paymentType === 'upi');

    // Calculate totals
    let totalCoins = 0;
    let totalUPI = 0;

    coinItems.forEach(item => {
      totalCoins += (item.coinPrice || 0) * item.quantity;
    });

    upiItems.forEach(item => {
      totalUPI += item.price * item.quantity;
    });

    const User = require('../models/User');
    const user = await User.findById(req.user.id);

    // Process coin payment
    if (totalCoins > 0) {
      if (user.coinBalance < totalCoins) {
        return res.status(400).json({
          success: false,
          message: 'Insufficient coins',
        });
      }
      
      // Deduct coins
      user.coinBalance -= totalCoins;
      await user.save();
    }

    // For UPI items, in a real app you would verify the Razorpay payment here
    // For now, we'll assume payment is successful if razorpayPaymentId is provided

    if (totalUPI > 0 && !razorpayPaymentId) {
      return res.status(400).json({
        success: false,
        message: 'UPI payment required for some items',
      });
    }

    // Create order record (you might want to create an Order model)
    // For now, just clear the cart
    await Cart.findOneAndUpdate(
      { user: req.user.id },
      { items: [] }
    );

    res.status(200).json({
      success: true,
      data: {
        coinsDeducted: totalCoins,
        upiAmount: totalUPI.toFixed(2),
        remainingCoins: user.coinBalance,
      },
      message: 'Payment processed successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};