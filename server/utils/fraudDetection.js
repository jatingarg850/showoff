const FraudLog = require('../models/FraudLog');
const UserSession = require('../models/UserSession');
const User = require('../models/User');
const axios = require('axios');

// IP Intelligence Service (you can use ipapi.co, ipinfo.io, or similar)
const getIPInfo = async (ipAddress) => {
  try {
    const response = await axios.get(`https://ipapi.co/${ipAddress}/json/`);
    return {
      country: response.data.country_name,
      countryCode: response.data.country_code,
      region: response.data.region,
      city: response.data.city,
      timezone: response.data.timezone,
      isp: response.data.org,
      asn: response.data.asn,
      isVPN: response.data.threat?.is_proxy || false,
      isTor: response.data.threat?.is_tor || false,
      isDatacenter: response.data.threat?.is_datacenter || false,
      coordinates: {
        lat: response.data.latitude,
        lng: response.data.longitude
      }
    };
  } catch (error) {
    console.error('IP lookup error:', error.message);
    return null;
  }
};

// Detect VPN/Proxy/Tor
const detectSuspiciousIP = async (ipAddress) => {
  const ipInfo = await getIPInfo(ipAddress);
  if (!ipInfo) return { isSuspicious: false };
  
  const isSuspicious = ipInfo.isVPN || ipInfo.isTor || ipInfo.isDatacenter;
  const reasons = [];
  
  if (ipInfo.isVPN) reasons.push('VPN detected');
  if (ipInfo.isTor) reasons.push('Tor network detected');
  if (ipInfo.isDatacenter) reasons.push('Datacenter IP detected');
  
  return {
    isSuspicious,
    reasons,
    ipInfo,
    ipType: ipInfo.isVPN ? 'vpn' : ipInfo.isTor ? 'tor' : ipInfo.isDatacenter ? 'datacenter' : 'residential'
  };
};

// Detect multiple accounts from same IP/Device
const detectMultipleAccounts = async (userId, ipAddress, deviceId) => {
  const timeWindow = 24 * 60 * 60 * 1000; // 24 hours
  const recentTime = new Date(Date.now() - timeWindow);
  
  // Find other users with same IP or device
  const suspiciousSessions = await UserSession.find({
    user: { $ne: userId },
    $or: [
      { ipAddress: ipAddress },
      { deviceId: deviceId }
    ],
    lastActivity: { $gte: recentTime }
  }).populate('user', 'username email');
  
  if (suspiciousSessions.length > 0) {
    return {
      isSuspicious: true,
      count: suspiciousSessions.length,
      relatedUsers: suspiciousSessions.map(s => s.user._id),
      reason: `${suspiciousSessions.length} other account(s) detected from same IP/device`
    };
  }
  
  return { isSuspicious: false };
};

// Detect geo-hopping (location changes too fast)
const detectGeoHopping = async (userId, newLocation) => {
  const recentSession = await UserSession.findOne({
    user: userId,
    'location.coordinates.lat': { $exists: true }
  }).sort({ lastActivity: -1 });
  
  if (!recentSession || !recentSession.location.coordinates) {
    return { isSuspicious: false };
  }
  
  const timeDiff = Date.now() - recentSession.lastActivity.getTime();
  const hoursDiff = timeDiff / (1000 * 60 * 60);
  
  // Calculate distance between locations (simplified)
  const distance = calculateDistance(
    recentSession.location.coordinates,
    newLocation.coordinates
  );
  
  // If traveled more than 500km in less than 1 hour, suspicious
  const maxSpeed = 500; // km/h
  const expectedDistance = maxSpeed * hoursDiff;
  
  if (distance > expectedDistance && hoursDiff < 1) {
    return {
      isSuspicious: true,
      reason: `Traveled ${Math.round(distance)}km in ${Math.round(hoursDiff * 60)} minutes`,
      distance,
      timeDiff: hoursDiff
    };
  }
  
  return { isSuspicious: false };
};

// Calculate distance between two coordinates (Haversine formula)
const calculateDistance = (coord1, coord2) => {
  const R = 6371; // Earth's radius in km
  const dLat = toRad(coord2.lat - coord1.lat);
  const dLon = toRad(coord2.lng - coord1.lng);
  
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(coord1.lat)) * Math.cos(toRad(coord2.lat)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

const toRad = (degrees) => degrees * (Math.PI / 180);

// Detect suspicious activity patterns
const detectSuspiciousActivity = async (userId, activityType, count, timeWindow = 3600000) => {
  // Define thresholds for different activities
  const thresholds = {
    vote: 100,        // 100 votes per hour
    view: 500,        // 500 views per hour
    upload: 20,       // 20 uploads per hour
    ad_watch: 50,     // 50 ads per hour
    referral: 10,     // 10 referrals per hour
    like: 200,        // 200 likes per hour
    comment: 50       // 50 comments per hour
  };
  
  const threshold = thresholds[activityType] || 100;
  
  if (count > threshold) {
    return {
      isSuspicious: true,
      reason: `Abnormal ${activityType} activity: ${count} in ${timeWindow / 60000} minutes (threshold: ${threshold})`,
      count,
      threshold
    };
  }
  
  return { isSuspicious: false };
};

// Detect self-referrals
const detectSelfReferral = async (referrerId, newUserId, ipAddress, deviceId) => {
  // Check if referrer and new user share IP or device
  const referrerSessions = await UserSession.find({
    user: referrerId,
    $or: [
      { ipAddress: ipAddress },
      { deviceId: deviceId }
    ]
  }).limit(1);
  
  if (referrerSessions.length > 0) {
    return {
      isSuspicious: true,
      reason: 'Referrer and new user share same IP/device (possible self-referral)'
    };
  }
  
  return { isSuspicious: false };
};

// Calculate user risk score
const calculateRiskScore = async (userId) => {
  let riskScore = 0;
  
  // Get recent fraud logs
  const recentFrauds = await FraudLog.find({
    user: userId,
    createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } // Last 30 days
  });
  
  // Weight by severity
  recentFrauds.forEach(fraud => {
    switch (fraud.severity) {
      case 'low': riskScore += 5; break;
      case 'medium': riskScore += 15; break;
      case 'high': riskScore += 30; break;
      case 'critical': riskScore += 50; break;
    }
  });
  
  // Check for VPN usage
  const vpnSessions = await UserSession.countDocuments({
    user: userId,
    ipType: { $in: ['vpn', 'proxy', 'tor'] }
  });
  riskScore += vpnSessions * 5;
  
  // Check for multiple devices
  const uniqueDevices = await UserSession.distinct('deviceId', { user: userId });
  if (uniqueDevices.length > 5) {
    riskScore += (uniqueDevices.length - 5) * 3;
  }
  
  // Cap at 100
  return Math.min(riskScore, 100);
};

// Log fraud incident
const logFraudIncident = async (userId, fraudType, details) => {
  const fraudLog = await FraudLog.create({
    user: userId,
    fraudType,
    severity: details.severity || 'medium',
    description: details.description || details.reason,
    evidence: details.evidence || {},
    ipAddress: details.ipAddress,
    deviceId: details.deviceId,
    userAgent: details.userAgent,
    location: details.location,
    actionTaken: details.actionTaken || 'none',
    actionDetails: details.actionDetails,
    riskScore: details.riskScore || 0,
    detectionMethod: details.detectionMethod || 'automatic'
  });
  
  // Update user risk score
  const newRiskScore = await calculateRiskScore(userId);
  await User.findByIdAndUpdate(userId, { riskScore: newRiskScore });
  
  return fraudLog;
};

// Take automated action based on fraud severity
const takeAutomatedAction = async (userId, fraudType, severity) => {
  const user = await User.findById(userId);
  if (!user) return;
  
  let action = 'none';
  let actionDetails = '';
  
  switch (severity) {
    case 'low':
      // Just log, no action
      action = 'warning';
      actionDetails = 'User flagged for monitoring';
      break;
      
    case 'medium':
      // Rate limit
      action = 'rate_limit';
      actionDetails = 'User rate limited for 24 hours';
      // Implement rate limiting logic
      break;
      
    case 'high':
      // Freeze coins
      action = 'freeze_coins';
      actionDetails = 'User coins frozen pending review';
      await User.findByIdAndUpdate(userId, { 
        coinsFrozen: true,
        freezeReason: `Fraud detected: ${fraudType}`
      });
      break;
      
    case 'critical':
      // Suspend account
      action = 'suspend';
      actionDetails = 'Account suspended for fraud';
      await User.findByIdAndUpdate(userId, { 
        accountStatus: 'suspended',
        isBanned: true,
        banReason: `Critical fraud detected: ${fraudType}`
      });
      break;
  }
  
  return { action, actionDetails };
};

module.exports = {
  getIPInfo,
  detectSuspiciousIP,
  detectMultipleAccounts,
  detectGeoHopping,
  detectSuspiciousActivity,
  detectSelfReferral,
  calculateRiskScore,
  logFraudIncident,
  takeAutomatedAction
};
