# Phone Login Integration Guide

## Overview
This guide explains how to complete the Phone Email Authentication integration in your ShowOff.life Flutter app.

## What's Been Done

### 1. Package Installation
- Added `phone_email_auth: ^0.0.6` to `pubspec.yaml`
- Run `flutter pub get` to install the package (already done)

### 2. Files Created

#### `apps/lib/config/phone_email_config.dart`
Configuration file for storing your CLIENT_ID from phone.email admin dashboard.

#### `apps/lib/services/phone_auth_service.dart`
Service wrapper for Phone Email Authentication functionality.

#### Updated `apps/lib/auth/login_screen.dart`
Added Phone Login button to the login screen with proper integration.

## Setup Steps

### Step 1: Get Your CLIENT_ID

1. Visit https://admin.phone.email
2. Sign in to your account
3. Navigate to **Profile Details** section
4. Copy your **CLIENT_ID**

### Step 2: Update Configuration

Open `apps/lib/config/phone_email_config.dart` and replace `YOUR_CLIENT_ID` with your actual CLIENT_ID:

```dart
class PhoneEmailConfig {
  static const String clientId = 'your_actual_client_id_here';
}
```

### Step 3: Backend Integration (Required)

You need to implement phone-based authentication in your backend. Add a new endpoint to handle phone login:

#### Backend Endpoint Example (Node.js/Express)

```javascript
// In your server routes
router.post('/auth/phone-login', async (req, res) => {
  try {
    const { phoneNumber, countryCode, firstName, lastName, accessToken } = req.body;
    
    // Verify the access token with phone.email API if needed
    
    // Check if user exists with this phone number
    let user = await User.findOne({ phone: phoneNumber });
    
    if (!user) {
      // Create new user
      user = new User({
        phone: phoneNumber,
        countryCode: countryCode,
        displayName: `${firstName} ${lastName}`,
        username: `user_${phoneNumber}`, // Generate unique username
        // Set other required fields
      });
      await user.save();
    }
    
    // Generate JWT token for your app
    const token = generateToken(user._id);
    
    res.json({
      success: true,
      data: {
        user: user,
        token: token
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});
```

### Step 4: Update Flutter Login Flow

Once your backend endpoint is ready, update the phone login handler in `apps/lib/auth/login_screen.dart`:

Replace the TODO section with actual API call:

```dart
// Get user info from phone auth
final userData = await PhoneAuthService.getUserInfo(accessToken);

if (userData != null && mounted) {
  final phoneNumber = '${userData.countryCode}${userData.phoneNumber}';
  
  // Call your backend phone login endpoint
  final response = await ApiService.phoneLogin(
    phoneNumber: userData.phoneNumber ?? '',
    countryCode: userData.countryCode ?? '',
    firstName: userData.firstName ?? '',
    lastName: userData.lastName ?? '',
    accessToken: accessToken,
  );
  
  if (response['success']) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateUser(response['data']['user']);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }
}
```

### Step 5: Add Backend Method to ApiService

Add this method to `apps/lib/services/api_service.dart`:

```dart
static Future<Map<String, dynamic>> phoneLogin({
  required String phoneNumber,
  required String countryCode,
  required String firstName,
  required String lastName,
  required String accessToken,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/phone-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
        'firstName': firstName,
        'lastName': lastName,
        'accessToken': accessToken,
      }),
    );

    return jsonDecode(response.body);
  } catch (e) {
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}
```

## Optional: Email Alert Integration

To show email alerts for authenticated users, add this to any screen where you want to display the email alert button:

```dart
floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
floatingActionButton: _phoneJwtToken.isNotEmpty
    ? EmailAlertButton(
        jwtToken: _phoneJwtToken,
      )
    : const Offstage(),
```

## Testing

1. Run `flutter pub get` to install dependencies
2. Update the CLIENT_ID in configuration
3. Run your app: `flutter run`
4. Navigate to the login screen
5. Click "Login with Phone" button
6. Complete phone verification
7. Check that user data is received correctly

## Troubleshooting

### Issue: "CLIENT_ID not configured"
- Make sure you've replaced `YOUR_CLIENT_ID` in `phone_email_config.dart`

### Issue: "Phone login button not showing"
- Ensure `phone_email_auth` package is installed: `flutter pub get`
- Check that imports are correct in `login_screen.dart`

### Issue: "Backend authentication fails"
- Verify your backend endpoint is implemented
- Check that the phone number format matches your database schema
- Ensure JWT token generation is working

## Security Notes

1. Never commit your CLIENT_ID to public repositories
2. Consider using environment variables for sensitive configuration
3. Validate phone numbers on the backend
4. Implement rate limiting for phone authentication attempts
5. Store phone numbers securely in your database

## Next Steps

1. ✅ Install package
2. ✅ Add configuration file
3. ✅ Create phone auth service
4. ✅ Update login screen UI
5. ⏳ Get CLIENT_ID from admin.phone.email
6. ⏳ Implement backend phone authentication endpoint
7. ⏳ Update ApiService with phoneLogin method
8. ⏳ Test the complete flow

## Support

If you encounter issues during integration:
- Check the official documentation: https://phone.email/docs
- Contact phone.email support
- Review the example code in this guide
