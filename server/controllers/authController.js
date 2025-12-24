const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const { generateReferralCode, awardCoins } = require('../utils/coinSystem');
const phoneEmailService = require('../services/phoneEmailService');
const authKeyService = require('../services/authkeyService');
const resendService = require('../services/resendService');
const googleAuthService = require('../services/googleAuthService');

// In-memory OTP storage for tracking (in production, use Redis or database)
// Stores: { identifier: { logId, expiresAt, attempts, createdAt } }
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

    // Normalize phone number: remove any + or spaces, just keep digits
    const normalizedPhone = phone ? phone.replace(/\D/g, '') : null;
    const identifier = email || `${countryCode}${normalizedPhone}`;
    
    console.log('╔════════════════════════════════════════╗');
    console.log('║          🔐 SENDING OTP               ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Phone/Email: ${identifier.padEnd(23)} ║`);
    console.log('╚════════════════════════════════════════╝');

    let logId = null;
    let otpSent = false;

    try {
      if (email) {
        // Send email OTP via Resend
        console.log(`📧 Sending OTP to email: ${email}`);
        
        const result = await resendService.sendEmailOTP(email);
        
        if (result.success) {
          logId = result.messageId;
          otpSent = true;
          
          // Store OTP and messageId for verification
          otpStore.set(identifier, {
            otp: result.otp, // Store the OTP for verification
            logId: result.messageId,
            expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
            attempts: 0,
            createdAt: Date.now(),
          });
          
          console.log('✅ OTP sent via Resend Email');
          console.log(`║  OTP Code:    ${result.otp.padEnd(23)} ║`);
          console.log(`║  MessageID:   ${result.messageId.padEnd(23)} ║`);
        }
      } else {
        // Send phone OTP via AuthKey.io
        console.log(`📱 Sending OTP to phone: +${countryCode} ${phone}`);
        
        const result = await authKeyService.sendOTP(phone, countryCode);
        
        if (result.success) {
          logId = result.logId;
          otpSent = true;
          
          // Store OTP and logId for verification
          otpStore.set(identifier, {
            otp: result.otp, // Store the OTP for verification
            logId: result.logId,
            expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
            attempts: 0,
            createdAt: Date.now(),
          });
          
          console.log('✅ OTP sent via AuthKey.io SMS');
          console.log(`║  OTP Code:    ${result.otp.padEnd(23)} ║`);
          console.log(`║  LogID:       ${result.logId.padEnd(23)} ║`);
        }
      }
    } catch (otpError) {
      console.error('⚠️ SMS service error:', otpError.message);
      
      // Fallback: Generate OTP locally for development
      if (process.env.NODE_ENV === 'development') {
        const otp = generateOTP();
        otpStore.set(identifier, {
          otp,
          logId: null,
          expiresAt: Date.now() + 10 * 60 * 1000,
          attempts: 0,
          createdAt: Date.now(),
        });
        
        console.log('⚠️ Using fallback OTP (development only)');
        console.log(`║  OTP Code:    ${otp.padEnd(23)} ║`);
        otpSent = true;
      } else {
        throw otpError;
      }
    }

    console.log('╚════════════════════════════════════════╝');

    if (!otpSent) {
      return res.status(500).json({
        success: false,
        message: 'Failed to send OTP. Please try again.',
      });
    }

    res.status(200).json({
      success: true,
      message: 'OTP sent successfully',
      data: {
        identifier,
        expiresIn: 600, // 10 minutes in seconds
        ...(logId && { logId }), // Include logId if available
        // Include OTP in response for development (remove in production)
        ...(process.env.NODE_ENV === 'development' && otpStore.get(identifier).otp && { 
          otp: otpStore.get(identifier).otp 
        }),
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

    console.log('╔════════════════════════════════════════╗');
    console.log('║       🔍 VERIFYING OTP                ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Phone/Email: ${identifier.padEnd(23)} ║`);
    console.log(`║  Entered OTP: ${otp.padEnd(23)} ║`);
    console.log(`║  Attempts:    ${storedSession.attempts}/3${' '.repeat(18)} ║`);
    console.log('╚════════════════════════════════════════╝');

    let isValid = false;

    try {
      // Always verify locally first (OTP is generated locally)
      if (storedSession.otp) {
        console.log('🔍 Verifying OTP locally');
        console.log(`   Stored OTP: ${storedSession.otp}`);
        console.log(`   Entered OTP: ${otp}`);
        
        if (storedSession.otp === otp) {
          isValid = true;
          console.log('✅ OTP verified locally - MATCH!');
        } else {
          console.log('❌ Invalid OTP (local) - NO MATCH');
        }
      } else if (storedSession.logId) {
        // Fallback: Try to verify via AuthKey.io 2FA API if no local OTP
        console.log('🔍 Verifying OTP via AuthKey.io (fallback)');
        console.log(`   LogID: ${storedSession.logId}`);
        
        const result = await authKeyService.verifyOTP(storedSession.logId, otp, 'SMS');
        
        if (result.success) {
          isValid = true;
          console.log('✅ OTP verified via AuthKey.io');
        } else {
          console.log('❌ Invalid OTP (AuthKey.io)');
        }
      } else {
        throw new Error('No OTP verification method available');
      }
    } catch (verifyError) {
      console.error('⚠️ OTP verification error:', verifyError.message);
      
      // Fallback to local verification if available
      if (storedSession.otp && storedSession.otp === otp) {
        isValid = true;
        console.log('✅ OTP verified via fallback');
      }
    }

    if (!isValid) {
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
    const { email, phone, password, username, displayName, referralCode, termsAccepted } = req.body;

    // Check if user accepted terms and conditions
    if (!termsAccepted) {
      return res.status(400).json({
        success: false,
        message: 'You must accept the Terms & Conditions to create an account',
      });
    }

    // Normalize phone number if provided
    const normalizedPhone = phone ? phone.replace(/\D/g, '') : null;

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

    if (normalizedPhone) {
      const phoneExists = await User.findOne({ phone: normalizedPhone });
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
      phone: normalizedPhone,
      password,
      username: username.toLowerCase(),
      displayName,
      referralCode: generateReferralCode(username),
      termsAndConditionsAccepted: true,
      termsAndConditionsVersion: 1,
      termsAndConditionsAcceptedAt: new Date(),
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

// @desc    Check email availability
// @route   POST /api/auth/check-email
// @access  Public
exports.checkEmail = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Please provide an email',
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid email address',
      });
    }

    // Check if email exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });

    if (existingUser) {
      return res.status(200).json({
        success: false,
        available: false,
        message: 'Email already registered',
        exists: true,
      });
    }

    res.status(200).json({
      success: true,
      available: true,
      message: 'Email is available',
      exists: false,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Check phone availability
// @route   POST /api/auth/check-phone
// @access  Public
exports.checkPhone = async (req, res) => {
  try {
    const { phone, countryCode } = req.body;

    if (!phone || !countryCode) {
      return res.status(400).json({
        success: false,
        message: 'Please provide phone number and country code',
      });
    }

    // Normalize phone number: remove any + or spaces, just keep digits
    const normalizedPhone = phone.replace(/\D/g, '');

    // Validate phone format (basic validation)
    if (normalizedPhone.length < 7 || normalizedPhone.length > 15) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid phone number',
      });
    }

    // Check if phone exists
    const existingUser = await User.findOne({ phone: normalizedPhone });

    if (existingUser) {
      return res.status(200).json({
        success: false,
        available: false,
        message: 'Phone number already registered',
        exists: true,
      });
    }

    res.status(200).json({
      success: true,
      available: true,
      message: 'Phone number is available',
      exists: false,
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
        referralCode: generateReferralCode(username),
      });

      console.log('✅ New user created:', user.username);

      // Award welcome bonus
      await awardCoins(user._id, 50, 'welcome_bonus', 'Welcome Bonus');
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

// @desc    Verify Phone.email web button callback (Step 2 of integration)
// @route   POST /api/auth/phone-email-verify
// @access  Public
exports.phoneEmailVerify = async (req, res) => {
  console.log('╔════════════════════════════════════════╗');
  console.log('║  phoneEmailVerify function called!     ║');
  console.log('╚════════════════════════════════════════╝');
  console.log('Method:', req.method);
  console.log('Headers:', req.headers);
  console.log('Body:', req.body);
  
  try {
    const { user_json_url } = req.body;

    if (!user_json_url) {
      console.log('⚠️  Missing user_json_url in request body');
      return res.status(400).json({
        success: false,
        message: 'user_json_url is required',
      });
    }

    console.log('🔐 Phone.email verification callback received');
    console.log('📄 Fetching user data from:', user_json_url);

    // Fetch user data from Phone.email JSON URL
    const https = require('https');
    const userData = await new Promise((resolve, reject) => {
      https.get(user_json_url, (response) => {
        let data = '';
        
        response.on('data', (chunk) => {
          data += chunk;
        });
        
        response.on('end', () => {
          try {
            resolve(JSON.parse(data));
          } catch (error) {
            reject(new Error('Failed to parse user data'));
          }
        });
      }).on('error', (error) => {
        reject(error);
      });
    });

    console.log('✅ User data fetched:', userData);

    const { user_country_code, user_phone_number, user_first_name, user_last_name } = userData;

    if (!user_phone_number || !user_country_code) {
      return res.status(400).json({
        success: false,
        message: 'Invalid user data received from Phone.email',
      });
    }

    // Check if user exists with this phone number
    let user = await User.findOne({ phone: user_phone_number });

    if (!user) {
      // Create new user
      console.log('👤 Creating new user from Phone.email verification');
      
      const baseUsername = `user_${user_phone_number.slice(-6)}`;
      let username = baseUsername;
      let counter = 1;
      
      while (await User.findOne({ username: username.toLowerCase() })) {
        username = `${baseUsername}_${counter}`;
        counter++;
      }

      const displayName = user_first_name && user_last_name 
        ? `${user_first_name} ${user_last_name}`.trim()
        : user_first_name || `User ${user_phone_number.slice(-4)}`;

      user = await User.create({
        username: username.toLowerCase(),
        displayName: displayName,
        phone: user_phone_number,
        countryCode: user_country_code,
        isPhoneVerified: true,
        accountStatus: 'active',
        referralCode: generateReferralCode(username),
      });

      console.log('✅ New user created:', user.username);

      // Award welcome bonus
      await awardCoins(user._id, 50, 'welcome_bonus', 'Welcome Bonus');
    } else {
      console.log('✅ Existing user found:', user.username);
      
      if (!user.isPhoneVerified) {
        user.isPhoneVerified = true;
        await user.save();
      }
    }

    // Update last login
    user.lastLogin = Date.now();
    await user.save();

    // Generate JWT token
    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      message: 'Phone verified and user authenticated successfully',
      user: {
        userId: user._id,
        username: user.username,
        displayName: user.displayName,
        phoneNumber: user.phone,
        countryCode: user.countryCode,
        firstName: user_first_name,
        lastName: user_last_name,
        coinBalance: user.coinBalance,
        isPhoneVerified: user.isPhoneVerified,
      },
      token: token,
    });
  } catch (error) {
    console.error('❌ Phone.email verification error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to verify phone number',
    });
  }
};


// @desc    Sign in with Phone OTP (after OTP verification)
// @route   POST /api/auth/signin-phone-otp
// @access  Public
exports.signInPhoneOTP = async (req, res) => {
  try {
    const { phone, countryCode } = req.body;

    if (!phone || !countryCode) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and country code are required',
      });
    }

    // Normalize phone number: remove any + or spaces, just keep digits
    const normalizedPhone = phone.replace(/\D/g, '');

    console.log('📱 Phone OTP Sign-In Request:', { phone: normalizedPhone, countryCode });

    // Check if user exists with this phone number
    const user = await User.findOne({ phone: normalizedPhone });

    if (!user) {
      // User doesn't exist - ask them to sign up
      console.log('❌ User not found for phone:', phone);
      return res.status(404).json({
        success: false,
        message: 'Account not found. Please sign up first.',
        code: 'ACCOUNT_NOT_FOUND',
      });
    }

    console.log('✅ Existing user found:', user.username);
    
    // Update phone verification status if not already verified
    if (!user.isPhoneVerified) {
      user.isPhoneVerified = true;
      await user.save();
    }

    // Update last login
    user.lastLogin = Date.now();
    await user.save();

    // Generate JWT token
    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      message: 'Phone OTP sign-in successful',
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
    console.error('❌ Phone OTP sign-in error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Google OAuth - Sign in or Sign up with Google ID Token
// @route   POST /api/auth/google
// @access  Public
exports.googleAuth = async (req, res) => {
  try {
    const { idToken, accessToken } = req.body;

    if (!idToken && !accessToken) {
      return res.status(400).json({
        success: false,
        message: 'Please provide Google ID token or access token',
      });
    }

    console.log('🔐 Google OAuth Request');
    console.log('   Has ID Token:', !!idToken);
    console.log('   Has Access Token:', !!accessToken);

    let googleUser;

    try {
      if (idToken) {
        // Verify ID token
        console.log('🔍 Verifying Google ID token...');
        googleUser = await googleAuthService.verifyIdToken(idToken);
      } else if (accessToken) {
        // Get user info from access token
        console.log('🔍 Getting user info from access token...');
        googleUser = await googleAuthService.getUserInfo(accessToken);
      }

      console.log('✅ Google user verified:', googleUser.email);
    } catch (error) {
      console.error('❌ Google verification failed:', error.message);
      return res.status(401).json({
        success: false,
        message: 'Invalid Google credentials',
      });
    }

    // Check if user exists with this Google ID
    let user = await User.findOne({ googleId: googleUser.sub || googleUser.id });

    if (!user) {
      // Check if user exists with this email
      user = await User.findOne({ email: googleUser.email });

      if (user) {
        // Link Google account to existing user
        console.log('🔗 Linking Google account to existing user');
        user.googleId = googleUser.sub || googleUser.id;
        user.isEmailVerified = googleUser.emailVerified || googleUser.verifiedEmail;
        // Only set profile picture if user doesn't have one yet
        if (googleUser.picture && !user.profilePicture) {
          console.log('ℹ️  Setting initial profile picture from Google');
          user.profilePicture = googleUser.picture;
        } else {
          console.log('ℹ️  Keeping existing profile picture');
        }
        await user.save();
      } else {
        // Create new user
        console.log('👤 Creating new user from Google account');

        // Generate username from email
        const baseUsername = googleUser.email.split('@')[0].toLowerCase().replace(/[^a-z0-9_]/g, '');
        let username = baseUsername;
        let counter = 1;

        while (await User.findOne({ username: username.toLowerCase() })) {
          username = `${baseUsername}${counter}`;
          counter++;
        }

        // Create user
        user = await User.create({
          username: username.toLowerCase(),
          displayName: googleUser.name || googleUser.givenName || username,
          email: googleUser.email,
          googleId: googleUser.sub || googleUser.id,
          profilePicture: googleUser.picture,
          isEmailVerified: googleUser.emailVerified || googleUser.verifiedEmail || true,
          accountStatus: 'active',
          referralCode: generateReferralCode(username),
        });

        console.log('✅ New user created:', user.username);

        // Award welcome bonus
        await awardCoins(user._id, 50, 'welcome_bonus', 'Welcome Bonus');
      }
    } else {
      console.log('✅ Existing Google user found:', user.username);

      // Don't update profile picture for existing users
      // Users should manage their profile picture through profile settings
      console.log('ℹ️  Keeping existing profile picture');
    }

    // Update last login
    user.lastLogin = Date.now();
    await user.save();

    // Generate JWT token
    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      message: 'Google authentication successful',
      data: {
        user: {
          id: user._id,
          username: user.username,
          displayName: user.displayName,
          email: user.email,
          profilePicture: user.profilePicture,
          bio: user.bio,
          coinBalance: user.coinBalance,
          isVerified: user.isVerified,
          isEmailVerified: user.isEmailVerified,
          isProfileComplete: user.isProfileComplete,
          accountStatus: user.accountStatus,
        },
        token: token,
      },
    });
  } catch (error) {
    console.error('❌ Google auth error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Google authentication failed',
    });
  }
};

// @desc    Google OAuth Web Flow - Redirect to Google
// @route   GET /api/auth/google/redirect
// @access  Public
exports.googleRedirect = (req, res) => {
  try {
    const state = Math.random().toString(36).substring(7);
    const authUrl = googleAuthService.getAuthUrl(state);

    console.log('🔗 Redirecting to Google OAuth');
    console.log('   Auth URL:', authUrl);

    res.redirect(authUrl);
  } catch (error) {
    console.error('❌ Google redirect error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to initiate Google authentication',
    });
  }
};

// @desc    Google OAuth Web Flow - Callback
// @route   GET /api/auth/google/callback
// @access  Public
exports.googleCallback = async (req, res) => {
  try {
    const { code, error } = req.query;

    if (error) {
      console.error('❌ Google OAuth error:', error);
      return res.redirect('/login?error=google_auth_failed');
    }

    if (!code) {
      return res.status(400).json({
        success: false,
        message: 'Authorization code not provided',
      });
    }

    console.log('🔐 Google OAuth callback received');
    console.log('   Code:', code.substring(0, 20) + '...');

    // Exchange code for tokens
    const tokens = await googleAuthService.exchangeCodeForTokens(code);
    console.log('✅ Tokens received from Google');

    // Get user info
    const googleUser = await googleAuthService.getUserInfo(tokens.accessToken);
    console.log('✅ User info received:', googleUser.email);

    // Find or create user (same logic as googleAuth)
    let user = await User.findOne({ googleId: googleUser.id });

    if (!user) {
      user = await User.findOne({ email: googleUser.email });

      if (user) {
        user.googleId = googleUser.id;
        user.isEmailVerified = googleUser.verifiedEmail;
        if (googleUser.picture && !user.profilePicture) {
          user.profilePicture = googleUser.picture;
        }
        await user.save();
      } else {
        const baseUsername = googleUser.email.split('@')[0].toLowerCase().replace(/[^a-z0-9_]/g, '');
        let username = baseUsername;
        let counter = 1;

        while (await User.findOne({ username: username.toLowerCase() })) {
          username = `${baseUsername}${counter}`;
          counter++;
        }

        user = await User.create({
          username: username.toLowerCase(),
          displayName: googleUser.name || googleUser.givenName || username,
          email: googleUser.email,
          googleId: googleUser.id,
          profilePicture: googleUser.picture,
          isEmailVerified: googleUser.verifiedEmail || true,
          accountStatus: 'active',
          referralCode: generateReferralCode(username),
        });

        await awardCoins(user._id, 50, 'welcome_bonus', 'Welcome Bonus');
      }
    }

    user.lastLogin = Date.now();
    await user.save();

    const token = generateToken(user._id);

    // Redirect to frontend with token
    res.redirect(`/auth-success?token=${token}`);
  } catch (error) {
    console.error('❌ Google callback error:', error);
    res.redirect('/login?error=google_auth_failed');
  }
};
