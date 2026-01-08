#!/usr/bin/env node

/**
 * Razorpay Setup Verification Script
 * Checks if Razorpay is properly configured
 */

const fs = require('fs');
const path = require('path');

console.log('🔍 Razorpay Setup Verification\n');

// Check 1: Environment variables
console.log('1️⃣  Checking environment variables...');
require('dotenv').config({ path: path.join(__dirname, 'server/.env') });

const razorpayKeyId = process.env.RAZORPAY_KEY_ID;
const razorpayKeySecret = process.env.RAZORPAY_KEY_SECRET;

if (!razorpayKeyId) {
  console.log('❌ RAZORPAY_KEY_ID not found in server/.env');
} else {
  console.log(`✅ RAZORPAY_KEY_ID: ${razorpayKeyId.substring(0, 15)}...`);
}

if (!razorpayKeySecret) {
  console.log('❌ RAZORPAY_KEY_SECRET not found in server/.env');
} else {
  console.log(`✅ RAZORPAY_KEY_SECRET: ${razorpayKeySecret.substring(0, 15)}...`);
}

// Check 2: Flutter app key
console.log('\n2️⃣  Checking Flutter app Razorpay key...');
const razorpayServicePath = path.join(__dirname, 'apps/lib/services/razorpay_service.dart');

try {
  const content = fs.readFileSync(razorpayServicePath, 'utf8');
  const keyMatch = content.match(/'key':\s*'(rzp_[^']+)'/);
  
  if (keyMatch) {
    const flutterKey = keyMatch[1];
    console.log(`✅ Flutter app key: ${flutterKey}`);
    
    if (razorpayKeyId && flutterKey !== razorpayKeyId) {
      console.log(`⚠️  WARNING: Flutter key doesn't match backend key!`);
      console.log(`   Backend: ${razorpayKeyId}`);
      console.log(`   Flutter: ${flutterKey}`);
      console.log(`   ➜ Update Flutter key to match backend`);
    } else if (razorpayKeyId && flutterKey === razorpayKeyId) {
      console.log(`✅ Keys match!`);
    }
  } else {
    console.log('❌ Could not find Razorpay key in Flutter app');
  }
} catch (error) {
  console.log(`❌ Error reading Flutter service: ${error.message}`);
}

// Check 3: Razorpay package in pubspec.yaml
console.log('\n3️⃣  Checking Flutter dependencies...');
const pubspecPath = path.join(__dirname, 'apps/pubspec.yaml');

try {
  const content = fs.readFileSync(pubspecPath, 'utf8');
  
  if (content.includes('razorpay_flutter')) {
    console.log('✅ razorpay_flutter package found in pubspec.yaml');
  } else {
    console.log('❌ razorpay_flutter package NOT found in pubspec.yaml');
    console.log('   Add it with: flutter pub add razorpay_flutter');
  }
} catch (error) {
  console.log(`❌ Error reading pubspec.yaml: ${error.message}`);
}

// Check 4: Razorpay npm package in backend
console.log('\n4️⃣  Checking backend dependencies...');
const packageJsonPath = path.join(__dirname, 'server/package.json');

try {
  const content = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  
  if (content.dependencies && content.dependencies.razorpay) {
    console.log(`✅ razorpay package found (v${content.dependencies.razorpay})`);
  } else {
    console.log('❌ razorpay package NOT found in package.json');
    console.log('   Install with: npm install razorpay');
  }
} catch (error) {
  console.log(`❌ Error reading package.json: ${error.message}`);
}

// Summary
console.log('\n📋 Summary:');
console.log('─'.repeat(50));

const issues = [];

if (!razorpayKeyId) issues.push('Missing RAZORPAY_KEY_ID in server/.env');
if (!razorpayKeySecret) issues.push('Missing RAZORPAY_KEY_SECRET in server/.env');

if (issues.length === 0) {
  console.log('✅ All checks passed! Razorpay should be working.');
} else {
  console.log('❌ Issues found:');
  issues.forEach((issue, i) => {
    console.log(`   ${i + 1}. ${issue}`);
  });
  console.log('\n🔧 Fix these issues and restart the server.');
}

console.log('\n📚 For more help, see RAZORPAY_ERROR_FIX.md');
