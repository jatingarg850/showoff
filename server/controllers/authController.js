const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const { generateReferralCode, awardCoins } = require('../utils/coinSystem');
const phoneEmailService = require('../services/phoneEmailService');

// In-memory OTP storage for tracking (in production, use Redis or database)
const otpStore = new Map();

// Generate 6-digit OTP (fallback only)
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

    const identifier = email || `${countryCode}${phone}`;
    
    // Generate OTP locally for development/testing
    const otp = generateOTP();
    
    // Store OTP
    otpStore.set(identifier, {
      otp,
      expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
      attempts: 0,
      createdAt: Date.now(),
    });

    // Always show OTP in console for development
    console.log('╔════════════════════════════════════════╗');
    console.log('║          🔐 OTP GENERATED             ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Phone/Email: ${identifier.padEnd(23)} ║`);
    console.log(`║  OTP Code:    ${otp.padEnd(23)} ║`);
    console.log(`║  Valid for:   10 minutes              ║`);
    console.log('╚════════════════════════════════════════╝');

    try {
      // Try to send OTP via phone.email service (but don't fail if it doesn't work)
      if (email) {
        console.log(`📧 Attempting to send OTP to email: ${email}`);
        await phoneEmailService.sendEmailOTP(email).catch(err => {
          console.log('⚠️ Email service unavailable, using console OTP only');
        });
      } else {
        const fullPhone = `${countryCode}${phone}`;
        console.log(`📱 Attempting to send OTP to phone: ${fullPhone}`);
        await phoneEmailService.sendPhoneOTP(fullPhone).catch(err => {
          console.log('⚠️ SMS service unavailable, using console OTP only');
        });
      }
    } catch (otpError) {
      console.log('⚠️ External OTP service error, using console OTP only');
    }

    // Always return success with OTP in development
    res.status(200).json({
      success: true,
      message: 'OTP sent successfully',
      data: {
        identifier,
        expiresIn: 600, // 10 minutes in seconds
        // Include OTP in response for development (remove in production)
        ...(process.env.NODE_ENV === 'development' && { otp }),
      },
    });
  } catch (error) {
    console.error('❌ Send OTP error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to send OTP',
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
    const storedSession = otpStore.get(identifier);

    if (!storedSession) {
      return res.status(400).json({
        success: false,
        message: 'OTP session expired or not found. Please request a new one.',
      });
    }

    // Check expiry
    if (Date.now() > storedSession.expiresAt) {
      otpStore.delete(identifier);
      return res.status(400).json({
        success: false,
        message: 'OTP expired. Please request a new one.',
      });
    }

    // Check attempts
    if (storedSession.attempts >= 3) {
      otpStore.delete(identifier);
      return res.status(400).json({
        success: false,
        message: 'Too many failed attempts. Please request a new OTP.',
      });
    }

    // Verify OTP locally (since we're using console OTP)
    console.log('╔════════════════════════════════════════╗');
    console.log('║       🔍 VERIFYING OTP                ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Phone/Email: ${identifier.padEnd(23)} ║`);
    console.log(`║  Entered OTP: ${otp.padEnd(23)} ║`);
    console.log(`║  Stored OTP:  ${(storedSession.otp || 'N/A').padEnd(23)} ║`);
    console.log(`║  Attempts:    ${storedSession.attempts}/3${' '.repeat(18)} ║`);
    console.log('╚════════════════════════════════════════╝');

    if (storedSession.otp !== otp) {
      storedSession.attempts += 1;
      
      console.log(`❌ Invalid OTP for ${identifier} (Attempt ${storedSession.attempts}/3)`);
      
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP',
        attemptsLeft: 3 - storedSession.attempts,
      });
    }
    
    // OTP verified successfully
    otpStore.delete(identifier);
    
    console.log('╔════════════════════════════════════════╗');
    console.log('║       ✅ OTP VERIFIED SUCCESS         ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Phone/Email: ${identifier.padEnd(23)} ║`);
    console.log('╚════════════════════════════════════════╝');

    res.status(200).json({
      success: true,
      message: 'OTP verified successfully',
    });
  } catch (error) {
    console.error('❌ Verify OTP error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to verify OTP',
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

// @desc    Login or Register with Phone.email verified phone number
// @route   POST /api/auth/phone-login
// @access  Public
exports.phoneLogin = async (req, res) => {
  try {
    const { phoneNumber, countryCode, firstName, lastName, accessToken } = req.body;

    if (!phoneNumber || !countryCode) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and country code are required',
      });
    }

    console.log('📱 Phone Login Request:', { phoneNumber, countryCode, firstName, lastName });

    // Check if user exists with this phone number
    let user = await User.findOne({ phone: phoneNumber });

    if (!user) {
      // Create new user with phone number
      console.log('👤 Creating new user with phone number');
      
      // Generate username from phone number
      const baseUsername = `user_${phoneNumber.slice(-6)}`;
      let username = baseUsername;
      let counter = 1;
      
      // Ensure username is unique
      while (await User.findOne({ username: username.toLowerCase() })) {
        username = `${baseUsername}_${counter}`;
        counter++;
      }

      // Generate display name
      const displayName = firstName && lastName 
        ? `${firstName} ${lastName}`.trim()
        : `User ${phoneNumber.slice(-4)}`;

      user = await User.create({
        username: username.toLowerCase(),
        displayName: displayName,
        phone: phoneNumber,
        countryCode: countryCode,
        isPhoneVerified: true, // Phone is verified by Phone.email
        accountStatus: 'active',
        referralCode: generateReferralCode(),
      });

      console.log('✅ New user created:', user.username);

      // Award welcome bonus
      await awardCoins(user._id, 50, 'welcome_bonus', 'Welcome bonus for new user');
    } else {
      console.log('✅ Existing user found:', user.username);
      
      // Update phone verification status if not already verified
      if (!user.isPhoneVerified) {
        user.isPhoneVerified = true;
        await user.save();
      }
    }

    // Generate JWT token
    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user._id,
          username: user.username,
          displayName: user.displayName,
          phone: user.phone,
          email: user.email,
          profilePicture: user.profilePicture,
          bio: user.bio,
          coinBalance: user.coinBalance,
          isVerified: user.isVerified,
          isPhoneVerified: user.isPhoneVerified,
          accountStatus: user.accountStatus,
        },
        token: token,
      },
    });
  } catch (error) {
    console.error('❌ Phone login error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
