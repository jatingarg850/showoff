const Withdrawal = require('../models/Withdrawal');
const User = require('../models/User');
const Transaction = require('../models/Transaction');

// @desc    Request withdrawal
// @route   POST /api/withdrawal/request
// @access  Private
exports.requestWithdrawal = async (req, res) => {
  try {
    console.log('📥 Withdrawal Request Body:', req.body);
    console.log('📎 Withdrawal Request Files:', req.files);
    
    // Parse coinAmount to integer (comes as string from multipart form)
    const coinAmount = parseInt(req.body.coinAmount);
    const { method, bankDetails, sofftAddress, upiId } = req.body;

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

    // KYC will be verified manually by admin after withdrawal request
    // No need to check KYC status here

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
    
    // Convert INR to USD (1 USD ≈ 83 INR)
    const inrToUsdRate = 1 / 83;
    const usdAmount = inrAmount * inrToUsdRate;
    
    // Local currency is INR
    const exchangeRates = {
      INR: 1,
      EUR: 0.012,
      GBP: 0.010,
    };
    const localAmount = inrAmount * (exchangeRates[user.currency || 'INR'] || 1);

    // Handle ID document uploads from request files
    const idDocuments = [];
    if (req.files && req.files.length > 0) {
      console.log('📎 Processing files:', req.files.length);
      req.files.forEach((file, index) => {
        console.log(`📎 File ${index}:`, {
          fieldname: file.fieldname,
          originalname: file.originalname,
          mimetype: file.mimetype,
          location: file.location,
          filename: file.filename,
          key: file.key
        });
        
        // For S3/Wasabi uploads
        if (file.location) {
          const docObj = {
            url: String(file.location),
            type: String('idDocuments'),
          };
          console.log(`✅ Adding S3 document ${index}:`, docObj);
          idDocuments.push(docObj);
        } 
        // For local uploads
        else if (file.filename) {
          // Determine the folder (images or videos)
          const folder = file.mimetype.startsWith('video/') ? 'videos' : 'images';
          const docObj = {
            url: String(`/uploads/${folder}/${file.filename}`),
            type: String('idDocuments'),
          };
          console.log(`✅ Adding local document ${index}:`, docObj);
          idDocuments.push(docObj);
        }
      });
    }

    console.log('📄 Final ID Documents array:', JSON.stringify(idDocuments, null, 2));
    console.log('📄 ID Documents array length:', idDocuments.length);
    console.log('📄 ID Documents array type:', Array.isArray(idDocuments));

    // Prepare withdrawal data
    const withdrawalData = {
      user: user._id,
      coinAmount,
      inrAmount,
      usdAmount,
      localAmount,
      currency: user.currency || 'INR',
      method,
      bankDetails: method === 'bank_transfer' ? bankDetails : undefined,
      sofftAddress: method === 'sofft_address' ? sofftAddress : undefined,
      upiId: method === 'upi' ? upiId : undefined,
    };

    // Only add idDocuments if there are any
    if (idDocuments.length > 0) {
      withdrawalData.idDocuments = idDocuments;
    }

    console.log('💾 Withdrawal data to save:', JSON.stringify(withdrawalData, null, 2));

    const withdrawal = await Withdrawal.create(withdrawalData);

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
    console.error('❌ Withdrawal Error:', error);
    console.error('❌ Error Stack:', error.stack);
    if (error.name === 'ValidationError') {
      console.error('❌ Validation Errors:', error.errors);
    }
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
