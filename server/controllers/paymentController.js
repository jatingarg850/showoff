const PaymentCard = require('../models/PaymentCard');
const User = require('../models/User');

// @desc    Add payment card
// @route   POST /api/payments/cards
// @access  Private
exports.addPaymentCard = async (req, res) => {
  try {
    const {
      cardNumber,
      expiryMonth,
      expiryYear,
      cvv,
      cardholderName,
      isDefault = false,
    } = req.body;

    // Validate card number (basic validation)
    if (!cardNumber || cardNumber.length < 13 || cardNumber.length > 19) {
      return res.status(400).json({
        success: false,
        message: 'Invalid card number',
      });
    }

    // Determine card type based on first digits
    let cardType = 'unknown';
    const firstDigit = cardNumber.charAt(0);
    const firstTwoDigits = cardNumber.substring(0, 2);
    const firstFourDigits = cardNumber.substring(0, 4);

    if (firstDigit === '4') {
      cardType = 'visa';
    } else if (['51', '52', '53', '54', '55'].includes(firstTwoDigits) || 
               (parseInt(firstFourDigits) >= 2221 && parseInt(firstFourDigits) <= 2720)) {
      cardType = 'mastercard';
    } else if (['34', '37'].includes(firstTwoDigits)) {
      cardType = 'amex';
    } else if (firstFourDigits === '6011' || firstTwoDigits === '65') {
      cardType = 'discover';
    }

    if (cardType === 'unknown') {
      return res.status(400).json({
        success: false,
        message: 'Unsupported card type',
      });
    }

    // Get last 4 digits
    const lastFourDigits = cardNumber.slice(-4);

    // Check if card already exists
    const existingCard = await PaymentCard.findOne({
      user: req.user.id,
      lastFourDigits,
      cardType,
    });

    if (existingCard) {
      return res.status(400).json({
        success: false,
        message: 'This card is already added',
      });
    }

    // In production, you would:
    // 1. Tokenize the card with your payment processor (Razorpay, Stripe, etc.)
    // 2. Store only the token, not the card details
    // For this demo, we'll simulate tokenization

    const paymentCard = await PaymentCard.create({
      user: req.user.id,
      cardType,
      lastFourDigits,
      expiryMonth: expiryMonth.padStart(2, '0'),
      expiryYear,
      cardholderName,
      isDefault,
      // In production, store actual tokens from payment processor
      razorpayCustomerId: `cust_${req.user.id}_${Date.now()}`,
      razorpayTokenId: `token_${Date.now()}`,
    });

    res.status(201).json({
      success: true,
      message: 'Payment card added successfully',
      data: {
        id: paymentCard._id,
        cardType: paymentCard.cardType,
        lastFourDigits: paymentCard.lastFourDigits,
        expiryMonth: paymentCard.expiryMonth,
        expiryYear: paymentCard.expiryYear,
        cardholderName: paymentCard.cardholderName,
        isDefault: paymentCard.isDefault,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get user's payment cards
// @route   GET /api/payments/cards
// @access  Private
exports.getPaymentCards = async (req, res) => {
  try {
    const cards = await PaymentCard.find({
      user: req.user.id,
      isActive: true,
    }).select('-razorpayCustomerId -razorpayTokenId').sort({ isDefault: -1, createdAt: -1 });

    res.status(200).json({
      success: true,
      data: cards,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Delete payment card
// @route   DELETE /api/payments/cards/:cardId
// @access  Private
exports.deletePaymentCard = async (req, res) => {
  try {
    const card = await PaymentCard.findOne({
      _id: req.params.cardId,
      user: req.user.id,
    });

    if (!card) {
      return res.status(404).json({
        success: false,
        message: 'Payment card not found',
      });
    }

    // If this was the default card, make another card default
    if (card.isDefault) {
      const otherCard = await PaymentCard.findOne({
        user: req.user.id,
        _id: { $ne: card._id },
        isActive: true,
      });

      if (otherCard) {
        otherCard.isDefault = true;
        await otherCard.save();
      }
    }

    // Soft delete
    card.isActive = false;
    await card.save();

    res.status(200).json({
      success: true,
      message: 'Payment card deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Set default payment card
// @route   PUT /api/payments/cards/:cardId/default
// @access  Private
exports.setDefaultCard = async (req, res) => {
  try {
    const card = await PaymentCard.findOne({
      _id: req.params.cardId,
      user: req.user.id,
      isActive: true,
    });

    if (!card) {
      return res.status(404).json({
        success: false,
        message: 'Payment card not found',
      });
    }

    // Remove default from other cards
    await PaymentCard.updateMany(
      { user: req.user.id, _id: { $ne: card._id } },
      { isDefault: false }
    );

    // Set this card as default
    card.isDefault = true;
    await card.save();

    res.status(200).json({
      success: true,
      message: 'Default payment card updated successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Update billing information
// @route   PUT /api/payments/billing
// @access  Private
exports.updateBillingInfo = async (req, res) => {
  try {
    const {
      fullName,
      email,
      phone,
      address,
      city,
      state,
      zipCode,
      country,
    } = req.body;

    const user = await User.findById(req.user.id);

    // Update billing info
    user.billingInfo = {
      fullName: fullName || user.billingInfo?.fullName || user.displayName,
      email: email || user.billingInfo?.email || user.email,
      phone: phone || user.billingInfo?.phone,
      address: address || user.billingInfo?.address,
      city: city || user.billingInfo?.city,
      state: state || user.billingInfo?.state,
      zipCode: zipCode || user.billingInfo?.zipCode,
      country: country || user.billingInfo?.country || 'India',
    };

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Billing information updated successfully',
      data: user.billingInfo,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get billing information
// @route   GET /api/payments/billing
// @access  Private
exports.getBillingInfo = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    const billingInfo = user.billingInfo || {
      fullName: user.displayName,
      email: user.email,
      phone: '',
      address: '',
      city: '',
      state: '',
      zipCode: '',
      country: 'India',
    };

    res.status(200).json({
      success: true,
      data: billingInfo,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};