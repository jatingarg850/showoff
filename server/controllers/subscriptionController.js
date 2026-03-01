const { SubscriptionPlan, UserSubscription } = require('../models/Subscription');
const User = require('../models/User');
const Transaction = require('../models/Transaction');

// @desc    Get all subscription plans
// @route   GET /api/subscriptions/plans
// @access  Public
exports.getPlans = async (req, res) => {
  try {
    const plans = await SubscriptionPlan.find({ isActive: true })
      .sort({ displayOrder: 1 });

    res.status(200).json({
      success: true,
      data: plans
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Create Razorpay order for subscription
// @route   POST /api/subscriptions/create-order
// @access  Private
exports.createSubscriptionOrder = async (req, res) => {
  try {
    const { planId } = req.body;

    if (!planId) {
      return res.status(400).json({
        success: false,
        message: 'Plan ID is required'
      });
    }

    const plan = await SubscriptionPlan.findById(planId);
    if (!plan || !plan.isActive) {
      return res.status(404).json({
        success: false,
        message: 'Plan not found or inactive'
      });
    }

    // Validate Razorpay configuration
    if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
      return res.status(500).json({
        success: false,
        message: 'Payment gateway not configured'
      });
    }

    // Create Razorpay order
    const Razorpay = require('razorpay');
    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });

    // Generate receipt
    const timestamp = Date.now().toString().slice(-8);
    const userIdShort = req.user.id.slice(-8);
    const receipt = `s_${userIdShort}_${timestamp}`; // s_ prefix for subscription

    const options = {
      amount: Math.round(plan.price * 100), // Convert to paise
      currency: 'INR',
      receipt: receipt,
      notes: {
        userId: req.user.id,
        type: 'subscription',
        planId: plan._id,
      },
    };

    const order = await razorpay.orders.create(options);

    res.status(201).json({
      success: true,
      data: order
    });
  } catch (error) {
    console.error('Error creating subscription order:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Subscribe to a plan
// @route   POST /api/subscriptions/subscribe
// @access  Private
exports.subscribe = async (req, res) => {
  try {
    const { planId, paymentMethod, transactionId } = req.body;

    const plan = await SubscriptionPlan.findById(planId);
    if (!plan || !plan.isActive) {
      return res.status(404).json({
        success: false,
        message: 'Plan not found or inactive'
      });
    }

    // Check if user already has active subscription
    const existingSubscription = await UserSubscription.findOne({
      user: req.user.id,
      status: 'active'
    });

    if (existingSubscription) {
      return res.status(400).json({
        success: false,
        message: 'You already have an active subscription'
      });
    }

    // Calculate amount and end date
    const amount = plan.price;
    const duration = plan.duration || 30;
    const endDate = new Date(Date.now() + duration * 24 * 60 * 60 * 1000);
    const nextBillingDate = new Date(endDate);

    // Create subscription
    const subscription = await UserSubscription.create({
      user: req.user.id,
      plan: planId,
      status: 'active',
      billingCycle: 'monthly',
      startDate: new Date(),
      endDate,
      nextBillingDate,
      amountPaid: amount,
      currency: plan.currency,
      paymentMethod,
      transactionId,
      autoRenew: true
    });

    // Update user subscription tier
    await User.findByIdAndUpdate(req.user.id, {
      subscriptionTier: plan.tier,
      subscriptionExpiry: endDate
    });

    // Create transaction record
    await Transaction.create({
      user: req.user.id,
      type: 'subscription',
      amount: -amount,
      description: `Subscription to ${plan.name}`,
      status: 'completed',
      metadata: {
        subscriptionId: subscription._id,
        planId: plan._id
      }
    });

    res.status(201).json({
      success: true,
      message: 'Subscription activated successfully',
      data: subscription
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get user's subscription
// @route   GET /api/subscriptions/my-subscription
// @access  Private
exports.getMySubscription = async (req, res) => {
  try {
    const subscription = await UserSubscription.findOne({
      user: req.user.id,
      status: 'active'
    }).populate('plan');

    if (!subscription) {
      return res.status(404).json({
        success: false,
        message: 'No active subscription found'
      });
    }

    res.status(200).json({
      success: true,
      data: subscription
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Cancel subscription
// @route   PUT /api/subscriptions/cancel
// @access  Private
exports.cancelSubscription = async (req, res) => {
  try {
    const subscription = await UserSubscription.findOne({
      user: req.user.id,
      status: 'active'
    });

    if (!subscription) {
      return res.status(404).json({
        success: false,
        message: 'No active subscription found'
      });
    }

    subscription.status = 'cancelled';
    subscription.cancelledAt = new Date();
    subscription.autoRenew = false;
    await subscription.save();

    res.status(200).json({
      success: true,
      message: 'Subscription cancelled. You can use it until the end date.',
      data: subscription
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// ============ ADMIN ROUTES ============

// @desc    Get all subscription plans (Admin)
// @route   GET /api/admin/subscriptions/plans
// @access  Private (Admin)
exports.getAllPlans = async (req, res) => {
  try {
    const plans = await SubscriptionPlan.find().sort({ displayOrder: 1 });

    // Get subscriber counts
    const subscriberCounts = await UserSubscription.aggregate([
      { $match: { status: 'active' } },
      { $group: { _id: '$plan', count: { $sum: 1 } } }
    ]);

    const plansWithCounts = plans.map(plan => ({
      ...plan.toObject(),
      subscriberCount: subscriberCounts.find(s => s._id.equals(plan._id))?.count || 0
    }));

    res.status(200).json({
      success: true,
      data: plansWithCounts
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Create subscription plan (Admin)
// @route   POST /api/admin/subscriptions/plans
// @access  Private (Admin)
exports.createPlan = async (req, res) => {
  try {
    const plan = await SubscriptionPlan.create(req.body);

    res.status(201).json({
      success: true,
      message: 'Plan created successfully',
      data: plan
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update subscription plan (Admin)
// @route   PUT /api/admin/subscriptions/plans/:id
// @access  Private (Admin)
exports.updatePlan = async (req, res) => {
  try {
    const plan = await SubscriptionPlan.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Plan not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Plan updated successfully',
      data: plan
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete subscription plan (Admin)
// @route   DELETE /api/admin/subscriptions/plans/:id
// @access  Private (Admin)
exports.deletePlan = async (req, res) => {
  try {
    // Check if any active subscriptions exist
    const activeSubscriptions = await UserSubscription.countDocuments({
      plan: req.params.id,
      status: 'active'
    });

    if (activeSubscriptions > 0) {
      return res.status(400).json({
        success: false,
        message: `Cannot delete plan with ${activeSubscriptions} active subscriptions`
      });
    }

    await SubscriptionPlan.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Plan deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get all subscriptions (Admin)
// @route   GET /api/admin/subscriptions
// @access  Private (Admin)
exports.getAllSubscriptions = async (req, res) => {
  try {
    const { page = 1, limit = 20, status, planId } = req.query;

    let query = {};
    if (status) query.status = status;
    if (planId) query.plan = planId;

    const subscriptions = await UserSubscription.find(query)
      .populate('user', 'username displayName email profilePicture')
      .populate('plan', 'name tier')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await UserSubscription.countDocuments(query);

    // Get revenue stats
    const revenueStats = await UserSubscription.aggregate([
      { $match: { status: 'active' } },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$amountPaid' },
          count: { $sum: 1 }
        }
      }
    ]);

    // Calculate churn rate (cancelled subscriptions in last 30 days)
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const churnedCount = await UserSubscription.countDocuments({
      status: 'cancelled',
      updatedAt: { $gte: thirtyDaysAgo }
    });

    const totalSubscriptions = await UserSubscription.countDocuments();
    const churnRate = totalSubscriptions > 0 ? ((churnedCount / totalSubscriptions) * 100).toFixed(2) : 0;

    res.status(200).json({
      success: true,
      data: subscriptions,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      },
      stats: {
        totalRevenue: revenueStats[0]?.totalRevenue || 0,
        count: revenueStats[0]?.count || 0,
        churnRate: parseFloat(churnRate)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Cancel user subscription (Admin)
// @route   PUT /api/admin/subscriptions/:id/cancel
// @access  Private (Admin)
exports.adminCancelSubscription = async (req, res) => {
  try {
    const { reason } = req.body;

    const subscription = await UserSubscription.findById(req.params.id);
    if (!subscription) {
      return res.status(404).json({
        success: false,
        message: 'Subscription not found'
      });
    }

    subscription.status = 'cancelled';
    subscription.cancelledAt = new Date();
    subscription.autoRenew = false;
    await subscription.save();

    // Update user tier to free
    await User.findByIdAndUpdate(subscription.user, {
      subscriptionTier: 'free'
    });

    res.status(200).json({
      success: true,
      message: 'Subscription cancelled by admin',
      data: subscription
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Subscribe using coins
// @route   POST /api/subscriptions/subscribe-with-coins
// @access  Private
exports.subscribeWithCoins = async (req, res) => {
  try {
    const { planId } = req.body;

    if (!planId) {
      return res.status(400).json({
        success: false,
        message: 'Plan ID is required'
      });
    }

    // Get the subscription plan
    const plan = await SubscriptionPlan.findById(planId);
    if (!plan || !plan.isActive) {
      return res.status(404).json({
        success: false,
        message: 'Subscription plan not found or inactive'
      });
    }

    // Get user
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Convert price to coins (1 INR = 1 coin)
    const coinsRequired = Math.round(plan.price);

    // Check if user has enough coins
    if (user.coinBalance < coinsRequired) {
      return res.status(400).json({
        success: false,
        message: `Insufficient coins. You need ${coinsRequired} coins but have ${user.coinBalance} coins.`,
        coinsRequired,
        coinsAvailable: user.coinBalance,
        coinsShortfall: coinsRequired - user.coinBalance
      });
    }

    // Check if user already has active subscription
    const existingSubscription = await UserSubscription.findOne({
      user: req.user.id,
      status: 'active'
    });

    if (existingSubscription) {
      return res.status(400).json({
        success: false,
        message: 'You already have an active subscription'
      });
    }

    // Deduct coins from user
    user.coinBalance -= coinsRequired;
    await user.save();

    // Create subscription
    const duration = plan.duration || 30;
    const endDate = new Date(Date.now() + duration * 24 * 60 * 60 * 1000);
    const subscription = await UserSubscription.create({
      user: req.user.id,
      plan: plan._id,
      status: 'active',
      billingCycle: 'monthly',
      startDate: new Date(),
      endDate,
      nextBillingDate: endDate,
      amountPaid: plan.price,
      currency: plan.currency,
      paymentMethod: 'coins',
      transactionId: `coins_${Date.now()}`,
      autoRenew: false // Don't auto-renew for coin purchases
    });

    // Update user subscription tier and add verified badge
    await User.findByIdAndUpdate(req.user.id, {
      subscriptionTier: plan.tier,
      subscriptionExpiry: endDate,
      isVerified: true // Add verified badge
    });

    // Create transaction record
    await Transaction.create({
      user: req.user.id,
      type: 'subscription',
      amount: -coinsRequired,
      balanceAfter: user.coinBalance,
      description: `Subscription to ${plan.name} (paid with coins)`,
      status: 'completed',
      metadata: {
        subscriptionId: subscription._id,
        planId: plan._id,
        paymentMethod: 'coins',
        coinsSpent: coinsRequired
      }
    });

    res.status(201).json({
      success: true,
      message: 'Subscription activated successfully with coins',
      data: subscription,
      coinsSpent: coinsRequired,
      remainingCoins: user.coinBalance
    });
  } catch (error) {
    console.error('Error subscribing with coins:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Verify subscription payment via Razorpay
// @route   POST /api/subscriptions/verify-payment
// @access  Private
exports.verifySubscriptionPayment = async (req, res) => {
  try {
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature, planId } = req.body;

    // Verify signature with Razorpay
    const crypto = require('crypto');
    const hmac = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET);
    hmac.update(razorpayOrderId + '|' + razorpayPaymentId);
    const generated_signature = hmac.digest('hex');

    if (generated_signature !== razorpaySignature) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment signature'
      });
    }

    // Get the subscription plan
    const plan = await SubscriptionPlan.findById(planId);
    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Subscription plan not found'
      });
    }

    // Check if user already has active subscription
    const existingSubscription = await UserSubscription.findOne({
      user: req.user.id,
      status: 'active'
    });

    if (existingSubscription) {
      return res.status(400).json({
        success: false,
        message: 'You already have an active subscription'
      });
    }

    // Create subscription
    const duration = plan.duration || 30;
    const endDate = new Date(Date.now() + duration * 24 * 60 * 60 * 1000);
    const subscription = await UserSubscription.create({
      user: req.user.id,
      plan: plan._id,
      status: 'active',
      billingCycle: 'monthly',
      startDate: new Date(),
      endDate,
      nextBillingDate: endDate,
      amountPaid: plan.price,
      currency: plan.currency,
      paymentMethod: 'razorpay',
      transactionId: razorpayPaymentId,
      autoRenew: true
    });

    // Update user subscription tier and add verified badge
    await User.findByIdAndUpdate(req.user.id, {
      subscriptionTier: plan.tier,
      subscriptionExpiry: endDate,
      isVerified: true // Add verified badge
    });

    // Create transaction record
    const user = await User.findById(req.user.id);
    await Transaction.create({
      user: req.user.id,
      type: 'subscription',
      amount: -plan.price,
      balanceAfter: user.coinBalance,
      description: `Subscription to ${plan.name}`,
      status: 'completed',
      metadata: {
        subscriptionId: subscription._id,
        planId: plan._id,
        razorpayPaymentId
      }
    });

    res.status(201).json({
      success: true,
      message: 'Subscription activated successfully',
      data: subscription
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

module.exports = exports;
