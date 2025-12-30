const jwt = require('jsonwebtoken');

const generateToken = (id) => {
  // Validate environment variables
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables');
  }
  
  const jwtExpire = process.env.JWT_EXPIRE || '30d';

  try {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
      expiresIn: jwtExpire,
    });
  } catch (error) {
    console.error('❌ Error generating JWT token:', error.message);
    console.error('   JWT_SECRET:', process.env.JWT_SECRET ? 'defined' : 'undefined');
    console.error('   JWT_EXPIRE:', process.env.JWT_EXPIRE ? 'defined' : 'undefined');
    throw error;
  }
};

module.exports = generateToken;
