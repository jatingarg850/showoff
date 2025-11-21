const Withdrawal = require('../models/Withdrawal');
const User = require('../models/User');
const Transaction = require('../models/Transaction');

// @desc    Request withdrawal
// @route   POST /api/withdrawal/request
// @access  Private
exports.requestWithdrawal = async (req, res) => {
  try {
    const { coinAmount, method, bankDetails, sofftAddress, upiId } = req.body;

    const user = await User.findById(req.user.id);

    // Get minimum withdrawal amount from settings (default 100)
    const minWithdrawal = parseInt(process.env.MIN_WITHDRAWAL_AMOUNT) || 100;

    // Check minimum withdrawal amount
    if (coinAmount < minWithdrawal) {
      return res.status(400).json({
        success: false,
        message: `Minimum withdrawal amount is ${minWithdrawal} coins`,
      });
    }

    // Check KYC
    if (user.kycStatus !== 'verified') {
      return res.status(400).json({
        success: false,
        message: 'KYC verification required for withdrawal',
      });
    }

    // Check balance
    if (user.coinBalance < coinAmount) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient coin balance',
      });
    }

    // Calculate amounts (1 coin = 1 INR)
    const coinToInrRate = parseInt(process.env.COIN_TO_INR_RATE) || 1;
    const inrAmount = coinAmount / coinToInrRate;
    
    // Convert to USD (simplified - in production use real exchange rates)
    const usdAmount = inrAmount / 83;
    
    // Convert to local currency
    const exchangeRates = {
      USD: 1,
      INR: 83,
      EUR: 0.92,
      GBP: 0.79,
    };
    const localAmount = usdAmount * (exchangeRates[user.currency || 'INR'] || 83);

    // Handle ID document uploads from request files
    const idDocuments = [];
    if (req.files && req.files.length > 0) {
      req.files.forEach(file => {
        idDocuments.push({
          url: file.location || `/uploads/${file.filename}`,
          type: file.fieldname || 'id_document',
        });
      });
    }

    const withdrawal = await Withdrawal.create({
      user: user._id,
      coinAmount,
      usdAmount,
      localAmount,
      currency: user.currency || 'INR',
      method,
      bankDetails: method === 'bank_transfer' ? bankDetails : undefined,
      sofftAddress: method === 'sofft_address' ? sofftAddress : undefined,
      upiId: method === 'upi' ? upiId : undefined,
      idDocuments,
    });

    // Deduct from coin balance
    user.coinBalance -= coinAmount;
    await user.save();

    // Create transaction
    await Transaction.create({
      user: user._id,
      type: 'withdrawal',
      amount: -coinAmount,
      balanceAfter: user.coinBalance,
      description: `Withdrawal request - ${method}`,
      status: 'pending',
    });

    res.status(201).json({
      success: true,
      message: 'Withdrawal request submitted successfully. Your money will be processed within 24 hours.',
      data: withdrawal,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get withdrawal history
// @route   GET /api/withdrawal/history
// @access  Private
exports.getWithdrawalHistory = async (req, res) => {
  try {
    const withdrawals = await Withdrawal.find({ user: req.user.id })
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: withdrawals,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Submit KYC
// @route   POST /api/withdrawal/kyc
// @access  Private
exports.submitKYC = async (req, res) => {
  try {
    const { fullName, dateOfBirth, address, documentType, documentNumber } = req.body;

    const user = await User.findById(req.user.id);

    // Upload document images if provided
    const documentImages = req.files ? req.files.map(file => file.location) : [];

    user.kycStatus = 'submitted';
    user.kycDetails = {
      fullName,
      dateOfBirth,
      address,
      documentType,
      documentNumber,
      documentImages,
    };

    await user.save();

    res.status(200).json({
      success: true,
      message: 'KYC submitted successfully',
      data: {
        kycStatus: user.kycStatus,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get KYC status
// @route   GET /api/withdrawal/kyc-status
// @access  Private
exports.getKYCStatus = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: {
        kycStatus: user.kycStatus,
        kycDetails: user.kycDetails,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get withdrawal settings
// @route   GET /api/withdrawal/settings
// @access  Private
exports.getWithdrawalSettings = async (req, res) => {
  try {
    const settings = {
      minWithdrawal: parseInt(process.env.MIN_WITHDRAWAL_AMOUNT) || 100,
      coinToInrRate: parseInt(process.env.COIN_TO_INR_RATE) || 1,
      processingTime: '24 hours',
      supportedMethods: ['sofft_address', 'upi'],
    };

    res.status(200).json({
      success: true,
      data: settings,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
