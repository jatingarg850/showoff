const KYC = require('../models/KYC');
const User = require('../models/User');
const { logFraudIncident } = require('../utils/fraudDetection');

// @desc    Submit KYC application
// @route   POST /api/kyc/submit
// @access  Private
exports.submitKYC = async (req, res) => {
  try {
    const {
      fullName,
      dateOfBirth,
      gender,
      address,
      documentType,
      documentNumber,
      documentFrontImage,
      documentBackImage,
      selfieImage,
      bankDetails,
      web3Wallet
    } = req.body;

    // Check if KYC already exists
    const existingKYC = await KYC.findOne({ user: req.user.id });
    if (existingKYC && existingKYC.status === 'approved') {
      return res.status(400).json({
        success: false,
        message: 'KYC already approved'
      });
    }

    // Create or update KYC
    const kycData = {
      user: req.user.id,
      fullName,
      dateOfBirth,
      gender,
      address,
      documentType,
      documentNumber,
      documentFrontImage,
      documentBackImage,
      selfieImage,
      bankDetails,
      web3Wallet,
      status: 'pending',
      submittedAt: new Date(),
      ipAddress: req.ip,
      deviceInfo: req.headers['user-agent']
    };

    let kyc;
    if (existingKYC) {
      kyc = await KYC.findByIdAndUpdate(existingKYC._id, kycData, { new: true });
    } else {
      kyc = await KYC.create(kycData);
    }

    // Update user KYC status
    await User.findByIdAndUpdate(req.user.id, { kycStatus: 'submitted' });

    res.status(201).json({
      success: true,
      message: 'KYC submitted successfully',
      data: kyc
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get user's KYC status
// @route   GET /api/kyc/status
// @access  Private
exports.getKYCStatus = async (req, res) => {
  try {
    const kyc = await KYC.findOne({ user: req.user.id });
    
    if (!kyc) {
      return res.status(404).json({
        success: false,
        message: 'No KYC application found'
      });
    }

    res.status(200).json({
      success: true,
      data: kyc
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get all KYC applications (Admin)
// @route   GET /api/admin/kyc
// @access  Private (Admin)
exports.getAllKYC = async (req, res) => {
  try {
    const { page = 1, limit = 20, status, search } = req.query;
    
    let query = {};
    
    if (status) {
      query.status = status;
    }
    
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { documentNumber: { $regex: search, $options: 'i' } }
      ];
    }

    const kycs = await KYC.find(query)
      .populate('user', 'username email displayName profilePicture')
      .populate('reviewedBy', 'username displayName')
      .sort({ submittedAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await KYC.countDocuments(query);

    // Get counts by status
    const statusCounts = await KYC.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } }
    ]);

    res.status(200).json({
      success: true,
      data: kycs,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      },
      statusCounts: statusCounts.reduce((acc, item) => {
        acc[item._id] = item.count;
        return acc;
      }, {})
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get single KYC application (Admin)
// @route   GET /api/admin/kyc/:id
// @access  Private (Admin)
exports.getKYCById = async (req, res) => {
  try {
    const kyc = await KYC.findById(req.params.id)
      .populate('user', 'username email displayName profilePicture coinBalance totalCoinsEarned')
      .populate('reviewedBy', 'username displayName');

    if (!kyc) {
      return res.status(404).json({
        success: false,
        message: 'KYC application not found'
      });
    }

    res.status(200).json({
      success: true,
      data: kyc
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Approve KYC application (Admin)
// @route   PUT /api/admin/kyc/:id/approve
// @access  Private (Admin)
exports.approveKYC = async (req, res) => {
  try {
    const { adminNotes } = req.body;

    const kyc = await KYC.findById(req.params.id);
    if (!kyc) {
      return res.status(404).json({
        success: false,
        message: 'KYC application not found'
      });
    }

    kyc.status = 'approved';
    kyc.reviewedBy = req.user.id;
    kyc.reviewedAt = new Date();
    kyc.adminNotes = adminNotes;
    kyc.isDocumentVerified = true;
    kyc.isSelfieVerified = true;
    kyc.isBankVerified = true;

    await kyc.save();

    // Update user status
    await User.findByIdAndUpdate(kyc.user, {
      kycStatus: 'verified',
      isVerified: true
    });

    res.status(200).json({
      success: true,
      message: 'KYC approved successfully',
      data: kyc
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Reject KYC application (Admin)
// @route   PUT /api/admin/kyc/:id/reject
// @access  Private (Admin)
exports.rejectKYC = async (req, res) => {
  try {
    const { rejectionReason, adminNotes } = req.body;

    if (!rejectionReason) {
      return res.status(400).json({
        success: false,
        message: 'Rejection reason is required'
      });
    }

    const kyc = await KYC.findById(req.params.id);
    if (!kyc) {
      return res.status(404).json({
        success: false,
        message: 'KYC application not found'
      });
    }

    kyc.status = 'rejected';
    kyc.reviewedBy = req.user.id;
    kyc.reviewedAt = new Date();
    kyc.rejectionReason = rejectionReason;
    kyc.adminNotes = adminNotes;

    await kyc.save();

    // Update user status
    await User.findByIdAndUpdate(kyc.user, {
      kycStatus: 'rejected'
    });

    res.status(200).json({
      success: true,
      message: 'KYC rejected',
      data: kyc
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Request resubmission (Admin)
// @route   PUT /api/admin/kyc/:id/resubmit
// @access  Private (Admin)
exports.requestResubmission = async (req, res) => {
  try {
    const { reason, adminNotes } = req.body;

    const kyc = await KYC.findById(req.params.id);
    if (!kyc) {
      return res.status(404).json({
        success: false,
        message: 'KYC application not found'
      });
    }

    kyc.status = 'resubmit_required';
    kyc.reviewedBy = req.user.id;
    kyc.reviewedAt = new Date();
    kyc.rejectionReason = reason;
    kyc.adminNotes = adminNotes;

    await kyc.save();

    // Update user status
    await User.findByIdAndUpdate(kyc.user, {
      kycStatus: 'resubmit_required'
    });

    res.status(200).json({
      success: true,
      message: 'Resubmission requested',
      data: kyc
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

module.exports = exports;
