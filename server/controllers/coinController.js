const User = require('../models/User');
const Transaction = require('../models/Transaction');
const { awardCoins } = require('../utils/coinSystem');
const Razorpay = require('razorpay');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const crypto = require('crypto');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// @desc    Watch ad and earn coins
// @route   POST /api/coins/watch-ad
// @access  Private
exports.watchAd = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    // Check daily limit based on subscription
    const dailyLimits = {
      free: 5,
      basic: 10,
      pro: 15,
      vip: 50,
    };

    const limit = dailyLimits[user.subscriptionTier];

    // Reset daily count if new day
    const today = new Date().setHours(0, 0, 0, 0);
    const lastAdDate = user.lastAdWatchTime ? new Date(user.lastAdWatchTime).setHours(0, 0, 0, 0) : 0;

    if (today > lastAdDate) {
      user.dailyAdsWatched = 0;
    }

    // Check if limit reached
    if (user.dailyAdsWatched >= limit) {
      return res.status(400).json({
        success: false,
        message: 'Daily ad watch limit reached',
      });
    }

    // Check cooldown (15 minutes after every 3 ads)
    if (user.adCooldownUntil && Date.now() < user.adCooldownUntil) {
      const remainingTime = Math.ceil((user.adCooldownUntil - Date.now()) / 60000);
      return res.status(400).json({
        success: false,
        message: `Please wait ${remainingTime} minutes before watching another ad`,
      });
    }

    // Award coins
    const adCoins = parseInt(process.env.AD_WATCH_COINS);
    await awardCoins(user._id, adCoins, 'ad_watch', 'Watched rewarded ad');

    // Update user
    user.dailyAdsWatched += 1;
    user.lastAdWatchTime = Date.now();

    // Set cooldown after every 3 ads
    if (user.dailyAdsWatched % 3 === 0) {
      user.adCooldownUntil = Date.now() + (15 * 60 * 1000); // 15 minutes
    }

    await user.save();

    res.status(200).json({
      success: true,
      coinsEarned: adCoins,
      dailyAdsWatched: user.dailyAdsWatched,
      dailyLimit: limit,
      cooldownUntil: user.adCooldownUntil,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Spin wheel
// @route   POST /api/coins/spin-wheel
// @access  Private
exports.spinWheel = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    // Check if already spun today
    if (user.lastSpinDate) {
      const lastSpin = new Date(user.lastSpinDate).setHours(0, 0, 0, 0);
      const today = new Date().setHours(0, 0, 0, 0);

      if (lastSpin === today) {
        return res.status(400).json({
          success: false,
          message: 'You have already spun the wheel today',
        });
      }
    }

    // Random coins between 5 and 50
    const coinsWon = Math.floor(Math.random() * 46) + 5;

    await awardCoins(user._id, coinsWon, 'spin_wheel', 'Daily spin wheel reward');

    user.lastSpinDate = Date.now();
    await user.save();

    res.status(200).json({
      success: true,
      coinsWon,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get transaction history
// @route   GET /api/coins/transactions
// @access  Private
exports.getTransactions = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const transactions = await Transaction.find({ user: req.user.id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('relatedUser', 'username displayName');

    const total = await Transaction.countDocuments({ user: req.user.id });

    res.status(200).json({
      success: true,
      data: transactions,
      pagination: {
        page,
        limit,
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

// @desc    Send gift coins
// @route   POST /api/coins/gift
// @access  Private
exports.sendGift = async (req, res) => {
  try {
    const { recipientId, amount, message } = req.body;

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid amount',
      });
    }

    const sender = await User.findById(req.user.id);
    const recipient = await User.findById(recipientId);

    if (!recipient) {
      return res.status(404).json({
        success: false,
        message: 'Recipient not found',
      });
    }

    if (sender.coinBalance < amount) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient coin balance',
      });
    }

    // Deduct from sender
    sender.coinBalance -= amount;
    await sender.save();

    await Transaction.create({
      user: sender._id,
      type: 'gift_sent',
      amount: -amount,
      balanceAfter: sender.coinBalance,
      description: `Gift sent to ${recipient.username}`,
      relatedUser: recipient._id,
    });

    // Add to recipient
    recipient.coinBalance += amount;
    recipient.withdrawableBalance += amount;
    await recipient.save();

    await Transaction.create({
      user: recipient._id,
      type: 'gift_received',
      amount: amount,
      balanceAfter: recipient.coinBalance,
      description: `Gift received from ${sender.username}${message ? ': ' + message : ''}`,
      relatedUser: sender._id,
    });

    res.status(200).json({
      success: true,
      message: 'Gift sent successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get coin balance
// @route   GET /api/coins/balance
// @access  Private
exports.getBalance = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: {
        coinBalance: user.coinBalance,
        withdrawableBalance: user.withdrawableBalance,
        totalCoinsEarned: user.totalCoinsEarned,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Create coin purchase order
// @route   POST /api/coins/create-purchase-order
// @access  Private
exports.createCoinPurchaseOrder = async (req, res) => {
  try {
    const { packageId, amount, coins } = req.body;

    // Validate package
    const coinPackages = {
      'package_1': { coins: 100, price: 99 }, // ₹0.99
      'package_2': { coins: 500, price: 499 }, // ₹4.99
      'package_3': { coins: 1000, price: 999 }, // ₹9.99
      'package_4': { coins: 2500, price: 1999 }, // ₹19.99
      'package_5': { coins: 5000, price: 4999 }, // ₹49.99
      'package_6': { coins: 10000, price: 9999 }, // ₹99.99
      'add_money': { coins: coins || 0, price: amount || 0 }, // Dynamic for add money
    };

    const selectedPackage = coinPackages[packageId];
    if (!selectedPackage) {
      return res.status(400).json({
        success: false,
        message: 'Invalid package selected',
      });
    }

    // Create Razorpay order
    const options = {
      amount: selectedPackage.price, // amount in paise
      currency: 'INR',
      receipt: `coin_${req.user.id}_${Date.now()}`,
      notes: {
        userId: req.user.id,
        packageId,
        coins: selectedPackage.coins,
      },
    };

    const order = await razorpay.orders.create(options);

    res.status(200).json({
      success: true,
      data: {
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        coins: selectedPackage.coins,
        packageId,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Purchase coins after payment verification
// @route   POST /api/coins/purchase
// @access  Private
exports.purchaseCoins = async (req, res) => {
  try {
    const { 
      razorpayOrderId, 
      razorpayPaymentId, 
      razorpaySignature, 
      packageId 
    } = req.body;

    // Verify payment signature
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

    // Get package details
    const coinPackages = {
      'package_1': { coins: 100, price: 99 },
      'package_2': { coins: 500, price: 499 },
      'package_3': { coins: 1000, price: 999 },
      'package_4': { coins: 2500, price: 1999 },
      'package_5': { coins: 5000, price: 4999 },
      'package_6': { coins: 10000, price: 9999 },
    };

    const selectedPackage = coinPackages[packageId];
    if (!selectedPackage) {
      return res.status(400).json({
        success: false,
        message: 'Invalid package',
      });
    }

    // Award coins to user
    await awardCoins(
      req.user.id, 
      selectedPackage.coins, 
      'purchase', 
      `Purchased ${selectedPackage.coins} coins for ₹${selectedPackage.price/100}`,
      {
        razorpayOrderId,
        razorpayPaymentId,
        razorpaySignature,
        packageId,
        amountPaid: selectedPackage.price,
      }
    );

    res.status(200).json({
      success: true,
      message: 'Coins purchased successfully',
      coinsAdded: selectedPackage.coins,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Create Stripe payment intent
// @route   POST /api/coins/create-stripe-intent
// @access  Private
exports.createStripePaymentIntent = async (req, res) => {
  try {
    const { amount, currency = 'usd' } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid amount',
      });
    }

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency,
      metadata: {
        userId: req.user.id,
        type: 'add_money',
      },
    });

    res.status(200).json({
      success: true,
      data: {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Confirm Stripe payment and add money
// @route   POST /api/coins/confirm-stripe-payment
// @access  Private
exports.confirmStripePayment = async (req, res) => {
  try {
    const { paymentIntentId } = req.body;

    // Retrieve payment intent from Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status !== 'succeeded') {
      return res.status(400).json({
        success: false,
        message: 'Payment not completed',
      });
    }

    // Check if payment belongs to this user
    if (paymentIntent.metadata.userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized payment',
      });
    }

    // Convert amount to coins (1 USD = 100 coins)
    const amountInUSD = paymentIntent.amount / 100;
    const coinsToAdd = Math.floor(amountInUSD * 100);

    // Award coins to user
    await awardCoins(
      req.user.id,
      coinsToAdd,
      'purchase',
      `Added money via Stripe: $${amountInUSD}`,
      {
        stripePaymentIntentId: paymentIntentId,
        amountPaid: amountInUSD,
        currency: paymentIntent.currency,
      }
    );

    res.status(200).json({
      success: true,
      message: 'Money added successfully',
      coinsAdded: coinsToAdd,
      amountPaid: amountInUSD,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Add money (generic endpoint for both gateways)
// @route   POST /api/coins/add-money
// @access  Private
exports.addMoney = async (req, res) => {
  try {
    const { 
      amount, 
      gateway, 
      paymentData 
    } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid amount',
      });
    }

    if (!gateway || !['stripe', 'razorpay'].includes(gateway)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment gateway',
      });
    }

    let coinsToAdd = 0;
    let description = '';
    let transactionData = {};

    if (gateway === 'stripe') {
      // Handle Stripe payment
      const { paymentIntentId } = paymentData;
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

      if (paymentIntent.status !== 'succeeded') {
        return res.status(400).json({
          success: false,
          message: 'Payment not completed',
        });
      }

      const amountInUSD = paymentIntent.amount / 100;
      coinsToAdd = Math.floor(amountInUSD * 100); // 1 USD = 100 coins
      description = `Added money via Stripe: $${amountInUSD}`;
      transactionData = {
        stripePaymentIntentId: paymentIntentId,
        amountPaid: amountInUSD,
        currency: paymentIntent.currency,
      };
    } else if (gateway === 'razorpay') {
      // Handle Razorpay payment
      const { razorpayOrderId, razorpayPaymentId, razorpaySignature } = paymentData;
      
      // Verify payment signature
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

      const amountInINR = amount;
      coinsToAdd = Math.floor(amountInINR * 1.2); // 1 INR = 1.2 coins
      description = `Added money via Razorpay: ₹${amountInINR}`;
      transactionData = {
        razorpayOrderId,
        razorpayPaymentId,
        razorpaySignature,
        amountPaid: amountInINR,
        currency: 'INR',
      };
    }

    // Award coins to user
    await awardCoins(
      req.user.id,
      coinsToAdd,
      'add_money',
      description,
      transactionData
    );

    res.status(200).json({
      success: true,
      message: 'Money added successfully',
      coinsAdded: coinsToAdd,
      gateway,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
