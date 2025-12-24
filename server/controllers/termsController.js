const TermsAndConditions = require('../models/TermsAndConditions');
const User = require('../models/User');

// @desc    Get current active T&C
// @route   GET /api/terms/current
// @access  Public
exports.getCurrentTerms = async (req, res) => {
  try {
    const terms = await TermsAndConditions.findOne({ isActive: true })
      .sort({ version: -1 });

    if (!terms) {
      return res.status(404).json({
        success: false,
        message: 'Terms and conditions not found',
      });
    }

    res.status(200).json({
      success: true,
      data: terms,
    });
  } catch (error) {
    console.error('Error fetching terms:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Accept T&C during signup
// @route   POST /api/terms/accept
// @access  Private
exports.acceptTerms = async (req, res) => {
  try {
    const { termsVersion } = req.body;

    if (!termsVersion) {
      return res.status(400).json({
        success: false,
        message: 'Terms version is required',
      });
    }

    // Update user to mark T&C as accepted
    const user = await User.findByIdAndUpdate(
      req.user.id,
      {
        termsAndConditionsAccepted: true,
        termsAndConditionsVersion: termsVersion,
        termsAndConditionsAcceptedAt: new Date(),
      },
      { new: true }
    );

    res.status(200).json({
      success: true,
      message: 'Terms and conditions accepted',
      data: user,
    });
  } catch (error) {
    console.error('Error accepting terms:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get T&C by version
// @route   GET /api/terms/:version
// @access  Public
exports.getTermsByVersion = async (req, res) => {
  try {
    const { version } = req.params;

    const terms = await TermsAndConditions.findOne({ version: parseInt(version) });

    if (!terms) {
      return res.status(404).json({
        success: false,
        message: 'Terms and conditions version not found',
      });
    }

    res.status(200).json({
      success: true,
      data: terms,
    });
  } catch (error) {
    console.error('Error fetching terms:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ADMIN ENDPOINTS

// @desc    Create new T&C version
// @route   POST /api/admin/terms
// @access  Private (Admin only)
exports.createTerms = async (req, res) => {
  try {
    const { title, content } = req.body;

    if (!content) {
      return res.status(400).json({
        success: false,
        message: 'Content is required',
      });
    }

    // Deactivate previous versions
    await TermsAndConditions.updateMany({}, { isActive: false });

    // Get next version number
    const lastVersion = await TermsAndConditions.findOne()
      .sort({ version: -1 });
    const nextVersion = (lastVersion?.version || 0) + 1;

    const terms = await TermsAndConditions.create({
      version: nextVersion,
      title: title || 'SHOWOFF.LIFE – TERMS & CONDITIONS',
      content,
      isActive: true,
      lastUpdated: new Date(),
    });

    res.status(201).json({
      success: true,
      message: 'Terms and conditions created',
      data: terms,
    });
  } catch (error) {
    console.error('Error creating terms:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Update T&C
// @route   PUT /api/admin/terms/:id
// @access  Private (Admin only)
exports.updateTerms = async (req, res) => {
  try {
    const { title, content } = req.body;

    const terms = await TermsAndConditions.findByIdAndUpdate(
      req.params.id,
      {
        title: title || 'SHOWOFF.LIFE – TERMS & CONDITIONS',
        content,
        lastUpdated: new Date(),
      },
      { new: true }
    );

    if (!terms) {
      return res.status(404).json({
        success: false,
        message: 'Terms and conditions not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Terms and conditions updated',
      data: terms,
    });
  } catch (error) {
    console.error('Error updating terms:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get all T&C versions
// @route   GET /api/admin/terms
// @access  Private (Admin only)
exports.getAllTerms = async (req, res) => {
  try {
    const terms = await TermsAndConditions.find()
      .sort({ version: -1 });

    res.status(200).json({
      success: true,
      data: terms,
    });
  } catch (error) {
    console.error('Error fetching terms:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Delete T&C version
// @route   DELETE /api/admin/terms/:id
// @access  Private (Admin only)
exports.deleteTerms = async (req, res) => {
  try {
    const terms = await TermsAndConditions.findByIdAndDelete(req.params.id);

    if (!terms) {
      return res.status(404).json({
        success: false,
        message: 'Terms and conditions not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Terms and conditions deleted',
    });
  } catch (error) {
    console.error('Error deleting terms:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
