const User = require('../models/User');
const Transaction = require('../models/Transaction');
const { awardCoins } = require('../utils/coinSystem');
const Razorpay = require('razorpay');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const crypto = require('crypto');

// Initialize Razorpay
let razorpay;
try {
  if (process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET) {
    razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
    console.log('✅ Razorpay initialized successfully');
  } else {
    console.log('⚠️ Razorpay credentials not found in environment variables');
  }
} catch (error) {
  console.error('❌ Error initializing Razorpay:', error);
}

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
    console.log('💰 Creating coin purchase order...');
    console.log('Request body:', JSON.stringify(req.body, null, 2));
    console.log('User ID:', req.user.id);
    console.log('Request headers:', req.headers['content-type']);

    const { packageId, amount, coins } = req.body;
    
    // Log individual values
    console.log('Parsed values:', { packageId, amount, coins });

    // Validate required fields
    if (!packageId) {
      console.log('❌ Missing packageId');
      return res.status(400).json({
        success: false,
        message: 'Package ID is required',
      });
    }

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
      console.log('❌ Invalid package selected:', packageId);
      return res.status(400).json({
        success: false,
        message: 'Invalid package selected',
      });
    }

    console.log('✅ Selected package:', selectedPackage);

    // Validate Razorpay configuration
    if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
      console.log('❌ Razorpay credentials not configured');
      return res.status(500).json({
        success: false,
        message: 'Payment gateway not configured',
      });
    }

    // For add_money, validate amount
    if (packageId === 'add_money') {
      if (!amount || amount <= 0) {
        console.log('❌ Invalid amount for add_money:', amount);
        return res.status(400).json({
          success: false,
          message: 'Valid amount is required for adding money',
        });
      }
      // Convert amount to paise and calculate coins
      selectedPackage.price = Math.round(amount * 100); // Convert to paise
      selectedPackage.coins = Math.round(amount * 1); // 1 INR = 1 coin
      console.log('💰 Add money - Amount:', amount, 'Price in paise:', selectedPackage.price, 'Coins:', selectedPackage.coins);
    }

    // Create Razorpay order
    // Generate shorter receipt (max 40 chars)
    const timestamp = Date.now().toString().slice(-8); // Last 8 digits
    const userIdShort = req.user.id.slice(-8); // Last 8 chars of user ID
    const receipt = `c_${userIdShort}_${timestamp}`; // Format: c_12345678_87654321 (max 21 chars)
    
    const options = {
      amount: selectedPackage.price, // amount in paise
      currency: 'INR',
      receipt: receipt,
      notes: {
        userId: req.user.id,
        packageId,
        coins: selectedPackage.coins.toString(),
      },
    };
    
    console.log('📝 Receipt generated:', receipt, '(length:', receipt.length, ')');
    
    // Validate receipt length (Razorpay requirement: max 40 chars)
    if (receipt.length > 40) {
      console.log('❌ Receipt too long:', receipt.length, 'chars');
      return res.status(500).json({
        success: false,
        message: 'Receipt generation error',
      });
    }

    console.log('🔄 Creating Razorpay order with options:', options);

    const order = await razorpay.orders.create(options);
    console.log('✅ Razorpay order created:', order.id);

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
    console.error('❌ Error creating coin purchase order:', error);
    console.error('Error details:', {
      message: error.message,
      stack: error.stack,
      razorpayError: error.error || null,
    });
    
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create purchase order',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
    });
  }
};

// @desc    Purchase coins after payment verification
// @route   POST /api/coins/purchase
// @access  Private
exports.purchaseCoins = async (req, res) => {
  try {
    console.log('💳 Processing coin purchase...');
    console.log('Request body:', JSON.stringify(req.body, null, 2));
    
    const { 
      razorpayOrderId, 
      razorpayPaymentId, 
      razorpaySignature, 
      packageId,
      amount, // For add_money
      coins   // For add_money
    } = req.body;

    console.log('🔐 Verifying payment signature...');
    console.log('Order ID:', razorpayOrderId);
    console.log('Payment ID:', razorpayPaymentId);
    console.log('Signature:', razorpaySignature);

    // Verify payment signature
    const sign = razorpayOrderId + '|' + razorpayPaymentId;
    const expectedSign = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(sign.toString())
      .digest('hex');

    console.log('Expected signature:', expectedSign);
    console.log('Received signature:', razorpaySignature);
    console.log('Signatures match:', razorpaySignature === expectedSign);

    if (razorpaySignature !== expectedSign) {
      console.log('❌ Payment signature verification failed');
      return res.status(400).json({
        success: false,
        message: 'Invalid payment signature',
      });
    }

    console.log('✅ Payment signature verified successfully');

    // Get package details
    const coinPackages = {
      'package_1': { coins: 100, price: 99 },
      'package_2': { coins: 500, price: 499 },
      'package_3': { coins: 1000, price: 999 },
      'package_4': { coins: 2500, price: 1999 },
      'package_5': { coins: 5000, price: 4999 },
      'package_6': { coins: 10000, price: 9999 },
      'add_money': { coins: coins || 0, price: amount || 0 }, // Dynamic for add money
    };

    const selectedPackage = coinPackages[packageId];
    if (!selectedPackage) {
      console.log('❌ Invalid package:', packageId);
      return res.status(400).json({
        success: false,
        message: 'Invalid package',
      });
    }

    console.log('📦 Selected package:', selectedPackage);

    // For add_money, calculate coins from amount
    if (packageId === 'add_money') {
      if (!amount || amount <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Invalid amount for add money',
        });
      }
      selectedPackage.coins = Math.round(amount * 1); // 1 INR = 1 coin
      selectedPackage.price = amount;
      console.log('💰 Add money calculated - Amount:', amount, 'Coins:', selectedPackage.coins);
    }

    // Award coins to user
    console.log('🎁 Awarding coins to user...');
    await awardCoins(
      req.user.id, 
      selectedPackage.coins, 
      packageId === 'add_money' ? 'add_money' : 'purchase', 
      packageId === 'add_money' 
        ? `Added money: ₹${selectedPackage.price}` 
        : `Purchased ${selectedPackage.coins} coins for ₹${selectedPackage.price/100}`,
      {
        razorpayOrderId,
        razorpayPaymentId,
        razorpaySignature,
        packageId,
        amountPaid: selectedPackage.price,
      }
    );

    console.log('✅ Coins awarded successfully');

    res.status(200).json({
      success: true,
      message: packageId === 'add_money' ? 'Money added successfully' : 'Coins purchased successfully',
      coinsAdded: selectedPackage.coins,
      amountPaid: packageId === 'add_money' ? selectedPackage.price : selectedPackage.price / 100,
    });
  } catch (error) {
    console.error('❌ Error in purchaseCoins:', error);
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

    // Convert amount to coins (1 INR = 1 coin)
    const amountInUSD = paymentIntent.amount / 100;
    let coinsToAdd;
    if (currency.toLowerCase() === 'inr') {
      coinsToAdd = Math.floor(amountInUSD); // 1 INR = 1 coin
    } else {
      coinsToAdd = Math.floor(amountInUSD * 83); // 1 USD ≈ 83 INR ≈ 83 coins
    }

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
    console.log('💰 Add money endpoint called...');
    console.log('Request body:', JSON.stringify(req.body, null, 2));
    console.log('User ID:', req.user.id);
    
    const { 
      amount, 
      gateway, 
      paymentData,
      // Also accept direct payment fields (for Flutter app compatibility)
      razorpayOrderId,
      razorpayPaymentId, 
      razorpaySignature
    } = req.body;

    console.log('Parsed values:', { amount, gateway, paymentData, razorpayOrderId, razorpayPaymentId, razorpaySignature });

    if (!amount || amount <= 0) {
      console.log('❌ Invalid amount:', amount);
      return res.status(400).json({
        success: false,
        message: 'Invalid amount',
      });
    }

    // Auto-detect gateway if not provided but payment data is available
    let detectedGateway = gateway;
    if (!detectedGateway && (razorpayOrderId || paymentData?.razorpayOrderId)) {
      detectedGateway = 'razorpay';
      console.log('🔍 Auto-detected gateway: razorpay');
    }

    if (!detectedGateway || !['stripe', 'razorpay'].includes(detectedGateway)) {
      console.log('❌ Invalid gateway:', detectedGateway);
      return res.status(400).json({
        success: false,
        message: 'Invalid payment gateway. Please specify "stripe" or "razorpay"',
      });
    }

    console.log('✅ Basic validation passed, gateway:', detectedGateway);

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
      coinsToAdd = Math.floor(amountInUSD * 83); // 1 USD ≈ 83 INR ≈ 83 coins
      description = `Added money via Stripe: $${amountInUSD}`;
      transactionData = {
        stripePaymentIntentId: paymentIntentId,
        amountPaid: amountInUSD,
        currency: paymentIntent.currency,
      };
    } else if (detectedGateway === 'razorpay') {
      // Handle Razorpay payment - support both formats
      let orderIdValue, paymentIdValue, signatureValue;
      
      if (paymentData) {
        // Format 1: Nested in paymentData
        orderIdValue = paymentData.razorpayOrderId;
        paymentIdValue = paymentData.razorpayPaymentId;
        signatureValue = paymentData.razorpaySignature;
      } else {
        // Format 2: Direct fields (Flutter app format)
        orderIdValue = razorpayOrderId;
        paymentIdValue = razorpayPaymentId;
        signatureValue = razorpaySignature;
      }
      
      console.log('🔐 Razorpay payment verification...');
      console.log('Order ID:', orderIdValue);
      console.log('Payment ID:', paymentIdValue);
      console.log('Signature:', signatureValue);
      
      if (!orderIdValue || !paymentIdValue || !signatureValue) {
        console.log('❌ Missing Razorpay payment data');
        return res.status(400).json({
          success: false,
          message: 'Missing Razorpay payment data (orderId, paymentId, signature)',
        });
      }
      
      // Verify payment signature
      const sign = orderIdValue + '|' + paymentIdValue;
      const expectedSign = crypto
        .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
        .update(sign.toString())
        .digest('hex');

      console.log('Expected signature:', expectedSign);
      console.log('Received signature:', signatureValue);
      console.log('Signatures match:', signatureValue === expectedSign);

      // Check if this is a demo/test payment
      const isDemoPayment = paymentIdValue.includes('demo') || 
                           signatureValue === 'demo_signature' ||
                           paymentIdValue.startsWith('pay_demo_');
      
      console.log('Is demo payment:', isDemoPayment);

      if (isDemoPayment) {
        // Handle demo payments in development
        if (process.env.NODE_ENV === 'development') {
          console.log('⚠️ Demo payment detected - allowing in development mode');
        } else {
          console.log('❌ Demo payments not allowed in production');
          return res.status(400).json({
            success: false,
            message: 'Demo payments not allowed in production',
          });
        }
      } else {
        // Verify real payment signature
        if (signatureValue !== expectedSign) {
          console.log('❌ Payment signature verification failed');
          return res.status(400).json({
            success: false,
            message: 'Invalid payment signature',
          });
        }
      }

      console.log('✅ Payment signature verified successfully');

      const amountInINR = amount;
      
      // Validate amount (should match the order amount)
      if (!isDemoPayment) {
        // For real payments, you might want to fetch the order from Razorpay to verify amount
        // For now, we'll trust the amount from the request
        console.log('💰 Real payment - Amount:', amountInINR);
      } else {
        console.log('🧪 Demo payment - Amount:', amountInINR);
      }
      
      coinsToAdd = Math.floor(amountInINR * 1); // 1 INR = 1 coin
      description = isDemoPayment 
        ? `Demo payment: ₹${amountInINR}` 
        : `Added money via Razorpay: ₹${amountInINR}`;
      
      transactionData = {
        razorpayOrderId: orderIdValue,
        razorpayPaymentId: paymentIdValue,
        razorpaySignature: signatureValue,
        amountPaid: amountInINR,
        currency: 'INR',
        isDemoPayment: isDemoPayment,
      };
      
      console.log('💰 Razorpay payment processed - Amount:', amountInINR, 'Coins:', coinsToAdd, 'Demo:', isDemoPayment);
    }

    // Award coins to user
    await awardCoins(
      req.user.id,
      coinsToAdd,
      'add_money',
      description,
      transactionData
    );

    console.log('🎁 Awarding coins to user...');
    
    res.status(200).json({
      success: true,
      message: 'Money added successfully',
      coinsAdded: coinsToAdd,
      gateway: detectedGateway,
      amountPaid: amount,
    });
    
    console.log('✅ Money added successfully - Coins:', coinsToAdd);
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

