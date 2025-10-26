const Withdrawal = require('../models/Withdrawal');
const User = require('../models/User');
const Transaction = require('../models/Transaction');

// @desc    Request withdrawal
// @route   POST /api/withdrawal/request
// @access  Private
exports.requestWithdrawal = async (req, res) => {
  try {
    const { coinAmount, method, bankDetails, walletAddress } = req.body;

    const user = await User.findById(req.user.id);

    // Check KYC
    if (user.kycStatus !== 'verified') {
      return res.status(400).json({
        success: false,
        message: 'KYC verification required for withdrawal',
      });
    }

    // Check balance
    if (user.withdrawableBalance < coinAmount) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient withdrawable balance',
      });
    }

    // Calculate amounts
    const coinToUsdRate = parseInt(process.env.COIN_TO_USD_RATE);
    const usdAmount = coinAmount / coinToUsdRate;
    
    // Convert to local currency (simplified - in production use real exchange rates)
    const exchangeRates = {
      USD: 1,
      INR: 83,
      EUR: 0.92,
      GBP: 0.79,
    };
    const localAmount = usdAmount * (exchangeRates[user.currency] || 1);

    const withdrawal = await Withdrawal.create({
      user: user._id,
      coinAmount,
      usdAmount,
      localAmount,
      currency: user.currency,
      method,
      bankDetails: method === 'bank_transfer' ? bankDetails : undefined,
      walletAddress: method === 'sofft_pay' ? walletAddress : undefined,
    });

    // Deduct from withdrawable balance
    user.withdrawableBalance -= coinAmount;
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
