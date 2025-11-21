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

    if (!quantity || quantity < 1) {
      return res.status(400).json({
        success: false,
        message: 'Quantity must be at least 1',
      });
    }

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

    item.quantity = quantity;

    await cart.save();
    await cart.populate('items.product');

    res.status(200).json({
      success: true,
      data: cart,
      message: 'Quantity updated',
    });
  } catch (error) {
    console.error('Update cart item error:', error);
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

    // Find the item
    const item = cart.items.id(itemId);
    
    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Item not found in cart',
      });
    }

    // Remove the item using pull
    cart.items.pull(itemId);
    await cart.save();
    await cart.populate('items.product');

    res.status(200).json({
      success: true,
      data: cart,
      message: 'Item removed from cart',
    });
  } catch (error) {
    console.error('Remove from cart error:', error);
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
// @desc    Checkout cart (handle mixed payments - 50% cash + 50% coins)
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

    const User = require('../models/User');
    const user = await User.findById(req.user.id);

    // Calculate totals with 50/50 split for ALL products
    let totalCash = 0;
    let totalCoins = 0;
    const itemsBreakdown = [];

    cart.items.forEach(item => {
      const product = item.product;
      const quantity = item.quantity;
      const basePrice = product.price;

      // Calculate 50% cash and 50% coins for each item
      const cashAmount = (basePrice * 0.5) * quantity;
      const coinAmount = Math.ceil((basePrice * 0.5) * 100) * quantity; // Convert to coins (1 USD = 100 coins)

      totalCash += cashAmount;
      totalCoins += coinAmount;

      itemsBreakdown.push({
        productName: product.name,
        quantity,
        basePrice,
        cashAmount: cashAmount.toFixed(2),
        coinAmount,
      });
    });

    // Check if user has enough coins
    const hasEnoughCoins = user.coinBalance >= totalCoins;

    res.status(200).json({
      success: true,
      data: {
        items: itemsBreakdown,
        totalCash: totalCash.toFixed(2),
        totalCoins,
        userCoinBalance: user.coinBalance,
        coinsNeeded: totalCoins,
        coinsShortage: hasEnoughCoins ? 0 : totalCoins - user.coinBalance,
        canProceed: hasEnoughCoins,
      },
      message: hasEnoughCoins 
        ? 'Checkout summary prepared - Ready to proceed' 
        : `Insufficient coins. You need ${totalCoins} coins but have ${user.coinBalance}`,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Process payment (complete checkout with 50/50 split)
// @route   POST /api/cart/process-payment
// @access  Private
exports.processPayment = async (req, res) => {
  try {
    const { paymentMethod, razorpayOrderId, razorpayPaymentId, razorpaySignature } = req.body;
    
    const cart = await Cart.findOne({ user: req.user.id }).populate('items.product');

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Cart is empty',
      });
    }

    const User = require('../models/User');
    const Transaction = require('../models/Transaction');
    const user = await User.findById(req.user.id);

    // Calculate totals with 50/50 split
    let totalCash = 0;
    let totalCoins = 0;

    cart.items.forEach(item => {
      const product = item.product;
      const quantity = item.quantity;
      const basePrice = product.price;

      // 50% cash and 50% coins
      totalCash += (basePrice * 0.5) * quantity;
      totalCoins += Math.ceil((basePrice * 0.5) * 100) * quantity;
    });

    // Verify user has enough coins
    if (user.coinBalance < totalCoins) {
      return res.status(400).json({
        success: false,
        message: `Insufficient coins. You need ${totalCoins} coins but have ${user.coinBalance}`,
      });
    }

    // Verify Razorpay payment signature
    if (!razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
      return res.status(400).json({
        success: false,
        message: 'Payment verification required',
      });
    }

    // Verify signature
    const crypto = require('crypto');
    const sign = razorpayOrderId + '|' + razorpayPaymentId;
    const expectedSign = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(sign.toString())
      .digest('hex');

    if (razorpaySignature !== expectedSign) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment signature',
      });
    }

    // Deduct coins
    user.coinBalance -= totalCoins;
    await user.save();

    // Create transaction record
    await Transaction.create({
      user: user._id,
      type: 'product_purchase',
      amount: -totalCoins,
      balanceAfter: user.coinBalance,
      description: `Store purchase - ${cart.items.length} item(s) - Mixed payment: $${totalCash.toFixed(2)} + ${totalCoins} coins`,
      status: 'completed',
    });

    // Clear cart
    await Cart.findOneAndUpdate(
      { user: req.user.id },
      { items: [] }
    );

    res.status(200).json({
      success: true,
      data: {
        cashAmount: totalCash.toFixed(2),
        coinsDeducted: totalCoins,
        remainingCoins: user.coinBalance,
        razorpayPaymentId,
      },
      message: 'Payment processed successfully! 50% paid with cash, 50% with coins.',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Create Razorpay order for cart checkout
// @route   POST /api/cart/create-razorpay-order
// @access  Private
exports.createCartRazorpayOrder = async (req, res) => {
  try {
    const Razorpay = require('razorpay');
    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });

    const cart = await Cart.findOne({ user: req.user.id }).populate('items.product');

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Cart is empty',
      });
    }

    // Calculate total cash amount (50% of total)
    let totalCash = 0;
    cart.items.forEach(item => {
      const product = item.product;
      const quantity = item.quantity;
      const basePrice = product.price;
      totalCash += (basePrice * 0.5) * quantity;
    });

    // Convert to paise (Razorpay uses smallest currency unit)
    const amountInPaise = Math.round(totalCash * 100);

    // Generate short receipt (max 40 chars)
    const timestamp = Date.now().toString().slice(-8); // Last 8 digits
    const userIdShort = req.user.id.toString().slice(-8); // Last 8 chars of user ID
    const receipt = `cart_${userIdShort}_${timestamp}`; // Format: cart_12345678_12345678 (max 27 chars)

    const options = {
      amount: amountInPaise,
      currency: 'INR',
      receipt: receipt,
      notes: {
        userId: req.user.id.toString(),
        itemCount: cart.items.length,
        paymentType: 'cart_checkout',
      },
    };

    const order = await razorpay.orders.create(options);

    res.status(200).json({
      success: true,
      data: {
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: process.env.RAZORPAY_KEY_ID,
      },
    });
  } catch (error) {
    console.error('Razorpay order creation error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
