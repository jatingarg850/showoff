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

// @desc    Subscribe to a plan
// @route   POST /api/subscriptions/subscribe
// @access  Private
exports.subscribe = async (req, res) => {
  try {
    const { planId, billingCycle, paymentMethod, transactionId } = req.body;

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
    const amount = billingCycle === 'yearly' ? plan.price.yearly : plan.price.monthly;
    const duration = billingCycle === 'yearly' ? 365 : 30;
    const endDate = new Date(Date.now() + duration * 24 * 60 * 60 * 1000);
    const nextBillingDate = new Date(endDate);

    // Create subscription
    const subscription = await UserSubscription.create({
      user: req.user.id,
      plan: planId,
      status: 'active',
      billingCycle,
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
      description: `Subscription to ${plan.name} (${billingCycle})`,
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

    res.status(200).json({
      success: true,
      data: subscriptions,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      },
      stats: revenueStats[0] || { totalRevenue: 0, count: 0 }
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

module.exports = exports;
