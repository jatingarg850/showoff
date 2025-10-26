const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const { generateReferralCode, awardCoins } = require('../utils/coinSystem');

// In-memory OTP storage (in production, use Redis or database)
const otpStore = new Map();

// Generate 6-digit OTP
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// @desc    Send OTP for phone/email verification
// @route   POST /api/auth/send-otp
// @access  Public
exports.sendOTP = async (req, res) => {
  try {
    const { phone, email, countryCode } = req.body;
    
    if (!phone && !email) {
      return res.status(400).json({
        success: false,
        message: 'Please provide phone or email',
      });
    }

    // Check if user already exists
    if (email) {
      const emailExists = await User.findOne({ email });
      if (emailExists) {
        return res.status(400).json({
          success: false,
          message: 'Email already registered',
        });
      }
    }

    if (phone) {
      const phoneExists = await User.findOne({ phone });
      if (phoneExists) {
        return res.status(400).json({
          success: false,
          message: 'Phone number already registered',
        });
      }
    }

    // Generate OTP
    const otp = generateOTP();
    const identifier = email || `${countryCode}${phone}`;
    
    // Store OTP with 5 minute expiry
    otpStore.set(identifier, {
      otp,
      expiresAt: Date.now() + 5 * 60 * 1000, // 5 minutes
      attempts: 0,
    });

    // In production, send OTP via SMS/Email service
    // For development, log it
    console.log(`OTP for ${identifier}: ${otp}`);

    res.status(200).json({
      success: true,
      message: 'OTP sent successfully',
      // In development, return OTP (remove in production)
      ...(process.env.NODE_ENV === 'development' && { otp }),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Verify OTP
// @route   POST /api/auth/verify-otp
// @access  Public
exports.verifyOTP = async (req, res) => {
  try {
    const { phone, email, countryCode, otp } = req.body;
    
    if (!otp) {
      return res.status(400).json({
        success: false,
        message: 'Please provide OTP',
      });
    }

    const identifier = email || `${countryCode}${phone}`;
    const storedOTP = otpStore.get(identifier);

    if (!storedOTP) {
      return res.status(400).json({
        success: false,
        message: 'OTP expired or not found. Please request a new one.',
      });
    }

    // Check expiry
    if (Date.now() > storedOTP.expiresAt) {
      otpStore.delete(identifier);
      return res.status(400).json({
        success: false,
        message: 'OTP expired. Please request a new one.',
      });
    }

    // Check attempts
    if (storedOTP.attempts >= 3) {
      otpStore.delete(identifier);
      return res.status(400).json({
        success: false,
        message: 'Too many failed attempts. Please request a new OTP.',
      });
    }

    // Verify OTP
    if (storedOTP.otp !== otp) {
      storedOTP.attempts += 1;
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP',
      });
    }

    // OTP verified successfully
    otpStore.delete(identifier);

    res.status(200).json({
      success: true,
      message: 'OTP verified successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res) => {
  try {
    const { email, phone, password, username, displayName, referralCode } = req.body;

    // Check if user exists
    if (email) {
      const emailExists = await User.findOne({ email });
      if (emailExists) {
        return res.status(400).json({
          success: false,
          message: 'Email already registered',
        });
      }
    }

    if (phone) {
      const phoneExists = await User.findOne({ phone });
      if (phoneExists) {
        return res.status(400).json({
          success: false,
          message: 'Phone number already registered',
        });
      }
    }

    // Check username
    const usernameExists = await User.findOne({ username: username.toLowerCase() });
    if (usernameExists) {
      return res.status(400).json({
        success: false,
        message: 'Username already taken',
      });
    }

    // Create user
    const user = await User.create({
      email,
      phone,
      password,
      username: username.toLowerCase(),
      displayName,
      referralCode: generateReferralCode(username),
    });

    // Handle referral
    if (referralCode) {
      const referrer = await User.findOne({ referralCode });
      if (referrer) {
        user.referredBy = referrer._id;
        await user.save();

        // Award referral coins
        const referralCoins = referrer.referralCount < 100 
          ? parseInt(process.env.REFERRAL_COINS_FIRST_100)
          : parseInt(process.env.REFERRAL_COINS_AFTER);

        await awardCoins(
          referrer._id,
          referralCoins,
          'referral',
          `Referral bonus for inviting ${user.username}`,
          { relatedUser: user._id }
        );

        referrer.referralCount += 1;
        referrer.referralCoinsEarned += referralCoins;
        await referrer.save();
      }
    }

    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: user._id,
          username: user.username,
          displayName: user.displayName,
          email: user.email,
          phone: user.phone,
          profilePicture: user.profilePicture,
          coinBalance: user.coinBalance,
          referralCode: user.referralCode,
        },
        token,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res) => {
  try {
    const { emailOrPhone, password } = req.body;

    if (!emailOrPhone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email/phone and password',
      });
    }

    // Find user
    const user = await User.findOne({
      $or: [{ email: emailOrPhone }, { phone: emailOrPhone }],
    }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    // Update last login
    user.lastLogin = Date.now();
    await user.save();

    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: user._id,
          username: user.username,
          displayName: user.displayName,
          email: user.email,
          phone: user.phone,
          profilePicture: user.profilePicture,
          bio: user.bio,
          interests: user.interests,
          coinBalance: user.coinBalance,
          subscriptionTier: user.subscriptionTier,
          isProfileComplete: user.isProfileComplete,
          profileCompletionPercentage: user.profileCompletionPercentage,
        },
        token,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get current user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    console.log('getMe - User profile picture:', user.profilePicture);

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Check username availability
// @route   POST /api/auth/check-username
// @access  Public
exports.checkUsername = async (req, res) => {
  try {
    const { username } = req.body;

    if (!username) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a username',
      });
    }

    // Check if username exists
    const existingUser = await User.findOne({ 
      username: username.toLowerCase() 
    });

    if (existingUser) {
      // Generate suggestions
      const suggestions = [];
      const baseUsername = username.toLowerCase().replace(/[^a-z0-9_]/g, '');
      
      // Add numbers
      for (let i = 1; i <= 3; i++) {
        const suggestion = `${baseUsername}${Math.floor(Math.random() * 1000)}`;
        const exists = await User.findOne({ username: suggestion });
        if (!exists) {
          suggestions.push(suggestion);
        }
      }
      
      // Add underscores with numbers
      for (let i = 1; i <= 2; i++) {
        const suggestion = `${baseUsername}_${Math.floor(Math.random() * 100)}`;
        const exists = await User.findOne({ username: suggestion });
        if (!exists) {
          suggestions.push(suggestion);
        }
      }

      return res.status(200).json({
        success: false,
        available: false,
        message: 'Username already taken',
        suggestions: suggestions.slice(0, 5), // Return max 5 suggestions
      });
    }

    res.status(200).json({
      success: true,
      available: true,
      message: 'Username is available',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
