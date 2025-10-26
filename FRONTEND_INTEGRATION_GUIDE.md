# Frontend Integration Guide - Connect UI to Backend

This guide shows exactly what to add to each screen to connect to the backend API while keeping the UI exactly the same.

## Step 1: Update pubspec.yaml (ALREADY DONE ✓)

The dependencies have been added:
- `http: ^1.1.0`
- `shared_preferences: ^2.2.2`
- `provider: ^6.1.1`

Run: `flutter pub get`

## Step 2: Configure API Endpoint

File: `apps/lib/config/api_config.dart` (ALREADY CREATED ✓)

Update the `baseUrl` based on your setup:
- Android Emulator: `http://10.0.2.2:3000/api`
- iOS Simulator: `http://localhost:3000/api`
- Real Device: `http://YOUR_IP:3000/api`

## Step 3: Services Layer (ALREADY CREATED ✓)

- `apps/lib/services/api_service.dart` - Complete API integration
- `apps/lib/services/storage_service.dart` - Local storage

## Step 4: Providers (ALREADY CREATED ✓)

- `apps/lib/providers/auth_provider.dart` - Authentication state
- `apps/lib/providers/profile_provider.dart` - Profile state

## Step 5: Update main.dart (ALREADY DONE ✓)

Wrapped app with providers.

## Step 6: Update Splash Screen (ALREADY DONE ✓)

Now checks authentication status and navigates accordingly.

## Step 7: Update Login Screens (ALREADY DONE ✓)

- `apps/lib/auth/login_screen.dart` - Connected to API
- `apps/lib/auth/signin_email_screen.dart` - Connected to API

## Step 8: Update Remaining Screens

### A. Authentication & Registration Screens

#### 1. `apps/lib/email_signup_screen.dart`
**What to add:**
```dart
// At top, add imports:
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

// In the Continue button onPressed, replace with:
onPressed: () async {
  if (_emailController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your email address'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Store email temporarily and navigate to set password
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SetPasswordScreen(
        email: _emailController.text.trim(),
      ),
    ),
  );
},
```

#### 2. `apps/lib/phone_signup_screen.dart`
**What to add:**
```dart
// In Continue button onPressed:
onPressed: () {
  if (_phoneController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your phone number'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Navigate to set password with phone
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SetPasswordScreen(
        phone: _phoneController.text.trim(),
        countryCode: _selectedCountryCode,
      ),
    ),
  );
},
```

#### 3. `apps/lib/set_password_screen.dart`
**Update class to accept email/phone:**
```dart
class SetPasswordScreen extends StatefulWidget {
  final String? email;
  final String? phone;
  final String? countryCode;

  const SetPasswordScreen({
    super.key,
    this.email,
    this.phone,
    this.countryCode,
  });
  
  // ... rest of code
}

// In Continue button onPressed, replace with:
onPressed: _canProceed ? () async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
  
  // Register user
  final success = await authProvider.register(
    username: 'user${DateTime.now().millisecondsSinceEpoch}', // Temporary
    displayName: 'User', // Temporary
    password: _passwordController.text,
    email: widget.email,
    phone: widget.phone != null ? '${widget.countryCode}${widget.phone}' : null,
  );
  
  if (!mounted) return;
  Navigator.pop(context); // Close loading
  
  if (success) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePictureScreen(),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authProvider.error ?? 'Registration failed'),
        backgroundColor: Colors.red,
      ),
    );
  }
} : null,
```

### B. Profile Setup Screens

#### 4. `apps/lib/account_setup/profile_picture_screen.dart`
**What to add:**
```dart
// At top:
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

// In Continue button onPressed, add upload logic:
onPressed: () async {
  if (_selectedImage != null) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    final success = await profileProvider.uploadProfilePicture(_selectedImage!);
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.error ?? 'Upload failed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DisplayNameScreen(),
    ),
  );
},
```

#### 5. `apps/lib/account_setup/display_name_screen.dart`
**What to add:**
```dart
// Store username temporarily in state management or pass to next screen
// No API call needed here, just validation and navigation
```

#### 6. `apps/lib/account_setup/interests_screen.dart`
**What to add:**
```dart
// Store interests temporarily, will be sent in bio screen
```

#### 7. `apps/lib/account_setup/bio_screen.dart`
**What to add:**
```dart
// At top:
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';

// In Continue button onPressed, replace with:
onPressed: () async {
  if (_bioController.text.trim().isEmpty) return;
  
  final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  
  // Update profile with all collected data
  final success = await profileProvider.updateProfile(
    displayName: 'Display Name', // Get from previous screen
    bio: _bioController.text.trim(),
    interests: [], // Get from interests screen
  );
  
  if (!mounted) return;
  Navigator.pop(context); // Close loading
  
  if (success) {
    // Refresh user data
    await authProvider.refreshUser();
    _showCongratulationsPopup();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(profileProvider.error ?? 'Update failed'),
        backgroundColor: Colors.red,
      ),
    );
  }
},
```

### C. Main App Screens

#### 8. `apps/lib/reel_screen.dart`
**What to add:**
```dart
// At top:
import 'services/api_service.dart';

// In initState, load feed:
@override
void initState() {
  super.initState();
  _loadFeed();
}

Future<void> _loadFeed() async {
  try {
    final response = await ApiService.getFeed(page: 1, limit: 20);
    if (response['success']) {
      setState(() {
        // Update posts list with response['data']
      });
    }
  } catch (e) {
    print('Error loading feed: $e');
  }
}

// For like button:
Future<void> _toggleLike(String postId) async {
  try {
    final response = await ApiService.toggleLike(postId);
    if (response['success']) {
      // Update UI
    }
  } catch (e) {
    print('Error toggling like: $e');
  }
}

// For view tracking:
Future<void> _trackView(String postId) async {
  try {
    await ApiService.incrementView(postId);
  } catch (e) {
    print('Error tracking view: $e');
  }
}
```

#### 9. `apps/lib/upload_content_screen.dart`
**What to add:**
```dart
// At top:
import 'services/api_service.dart';

// In upload function:
Future<void> _uploadPost() async {
  if (_selectedFile == null) return;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  
  try {
    final response = await ApiService.createPost(
      mediaFile: _selectedFile!,
      caption: _captionController.text,
      hashtags: _extractHashtags(_captionController.text),
      type: _isVideo ? 'video' : 'image',
    );
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading
    
    if (response['success']) {
      // Show reward if any
      if (response['reward'] != null && response['reward']['awarded']) {
        _showRewardDialog(response['reward']['coins']);
      }
      
      Navigator.pop(context); // Go back to feed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

#### 10. `apps/lib/wallet_screen.dart`
**What to add:**
```dart
// At top:
import 'services/api_service.dart';

// Load balance:
@override
void initState() {
  super.initState();
  _loadBalance();
}

Future<void> _loadBalance() async {
  try {
    final response = await ApiService.getCoinBalance();
    if (response['success']) {
      setState(() {
        _coinBalance = response['data']['coinBalance'];
        _withdrawableBalance = response['data']['withdrawableBalance'];
      });
    }
  } catch (e) {
    print('Error loading balance: $e');
  }
}

// For spin wheel:
Future<void> _spinWheel() async {
  try {
    final response = await ApiService.spinWheel();
    if (response['success']) {
      _showWinDialog(response['coinsWon']);
      _loadBalance(); // Refresh balance
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// For watch ad:
Future<void> _watchAd() async {
  try {
    final response = await ApiService.watchAd();
    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Earned ${response['coinsEarned']} coins!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadBalance();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    print('Error watching ad: $e');
  }
}
```

#### 11. `apps/lib/talent_screen.dart` (SYT)
**What to add:**
```dart
// At top:
import 'services/api_service.dart';

// Load entries:
@override
void initState() {
  super.initState();
  _loadEntries();
}

Future<void> _loadEntries() async {
  try {
    final response = await ApiService.getSYTEntries(
      filter: _selectedFilter, // 'weekly', 'monthly', 'all', 'winners'
    );
    if (response['success']) {
      setState(() {
        _entries = response['data'];
      });
    }
  } catch (e) {
    print('Error loading entries: $e');
  }
}

// For voting:
Future<void> _voteEntry(String entryId) async {
  try {
    final response = await ApiService.voteSYTEntry(entryId);
    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vote recorded!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadEntries(); // Refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    print('Error voting: $e');
  }
}

// For submitting entry:
Future<void> _submitEntry() async {
  if (_selectedVideo == null) return;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  
  try {
    final response = await ApiService.submitSYTEntry(
      videoFile: _selectedVideo!,
      title: _titleController.text,
      category: _selectedCategory,
      competitionType: _competitionType, // 'weekly', 'monthly', 'quarterly'
      description: _descriptionController.text,
    );
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading
    
    if (response['success']) {
      Navigator.pop(context); // Close submit screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadEntries();
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Submission failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

#### 12. `apps/lib/profile_screen.dart`
**What to add:**
```dart
// At top:
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'services/api_service.dart';

// Load user data:
@override
void initState() {
  super.initState();
  _loadUserData();
}

Future<void> _loadUserData() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
  
  await authProvider.refreshUser();
  await profileProvider.getStats();
  
  // Load user posts
  if (authProvider.user != null) {
    final response = await ApiService.getUserPosts(authProvider.user!['id']);
    if (response['success']) {
      setState(() {
        _posts = response['data'];
      });
    }
  }
}

// Display user data from provider:
Consumer<AuthProvider>(
  builder: (context, auth, _) {
    if (auth.user == null) return CircularProgressIndicator();
    
    return Column(
      children: [
        // Profile picture
        CircleAvatar(
          backgroundImage: auth.user!['profilePicture'] != null
              ? NetworkImage(auth.user!['profilePicture'])
              : null,
        ),
        // Display name
        Text(auth.user!['displayName'] ?? 'User'),
        // Bio
        Text(auth.user!['bio'] ?? ''),
        // Stats
        Consumer<ProfileProvider>(
          builder: (context, profile, _) {
            if (profile.stats == null) return SizedBox();
            return Row(
              children: [
                _buildStatColumn(
                  profile.stats!['postsCount'].toString(),
                  'Posts',
                ),
                _buildStatColumn(
                  profile.stats!['followersCount'].toString(),
                  'Followers',
                ),
                _buildStatColumn(
                  profile.stats!['followingCount'].toString(),
                  'Following',
                ),
              ],
            );
          },
        ),
      ],
    );
  },
),
```

#### 13. `apps/lib/user_profile_screen.dart`
**What to add:**
```dart
// At top:
import 'services/api_service.dart';

// Load user profile:
@override
void initState() {
  super.initState();
  _loadUserProfile();
}

Future<void> _loadUserProfile() async {
  try {
    final response = await ApiService.getUserProfile(widget.username);
    if (response['success']) {
      setState(() {
        _userData = response['data'];
      });
    }
    
    // Load user posts
    final postsResponse = await ApiService.getUserPosts(_userData['id']);
    if (postsResponse['success']) {
      setState(() {
        _posts = postsResponse['data'];
      });
    }
    
    // Check if following
    final followResponse = await ApiService.checkFollowing(_userData['id']);
    if (followResponse['success']) {
      setState(() {
        _isFollowing = followResponse['isFollowing'];
      });
    }
  } catch (e) {
    print('Error loading profile: $e');
  }
}

// For follow/unfollow:
Future<void> _toggleFollow() async {
  try {
    final response = _isFollowing
        ? await ApiService.unfollowUser(_userData['id'])
        : await ApiService.followUser(_userData['id']);
    
    if (response['success']) {
      setState(() {
        _isFollowing = !_isFollowing;
        if (_isFollowing) {
          _userData['followersCount']++;
        } else {
          _userData['followersCount']--;
        }
      });
    }
  } catch (e) {
    print('Error toggling follow: $e');
  }
}
```

#### 14. `apps/lib/withdrawal_screen.dart`
**What to add:**
```dart
// At top:
import 'services/api_service.dart';

// For withdrawal request:
Future<void> _requestWithdrawal() async {
  if (_coinAmount <= 0) return;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  
  try {
    final response = await ApiService.requestWithdrawal(
      coinAmount: _coinAmount,
      method: _selectedMethod, // 'bank_transfer', 'sofft_pay'
      bankDetails: _selectedMethod == 'bank_transfer' ? {
        'accountName': _accountNameController.text,
        'accountNumber': _accountNumberController.text,
        'bankName': _bankNameController.text,
        'ifscCode': _ifscController.text,
      } : null,
      walletAddress: _selectedMethod == 'sofft_pay' ? _walletController.text : null,
    );
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading
    
    if (response['success']) {
      Navigator.pop(context); // Close withdrawal screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal request submitted!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Load withdrawal history:
Future<void> _loadHistory() async {
  try {
    final response = await ApiService.getWithdrawalHistory();
    if (response['success']) {
      setState(() {
        _withdrawals = response['data'];
      });
    }
  } catch (e) {
    print('Error loading history: $e');
  }
}
```

#### 15. `apps/lib/transaction_history_screen.dart`
**What to add:**
```dart
// At top:
import 'services/api_service.dart';

// Load transactions:
@override
void initState() {
  super.initState();
  _loadTransactions();
}

Future<void> _loadTransactions() async {
  try {
    final response = await ApiService.getTransactions(page: _currentPage, limit: 20);
    if (response['success']) {
      setState(() {
        _transactions = response['data'];
        _totalPages = response['pagination']['pages'];
      });
    }
  } catch (e) {
    print('Error loading transactions: $e');
  }
}
```

#### 16. `apps/lib/gift_screen.dart`
**What to add:**
```dart
// At top:
import 'services/api_service.dart';

// Send gift:
Future<void> _sendGift() async {
  if (_amount <= 0 || _recipientId == null) return;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  
  try {
    final response = await ApiService.sendGift(
      recipientId: _recipientId!,
      amount: _amount,
      message: _messageController.text,
    );
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading
    
    if (response['success']) {
      Navigator.pop(context); // Close gift screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gift sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

#### 17. `apps/lib/referrals_screen.dart`
**What to add:**
```dart
// Display referral code from user data:
Consumer<AuthProvider>(
  builder: (context, auth, _) {
    if (auth.user == null) return CircularProgressIndicator();
    
    return Column(
      children: [
        Text('Your Referral Code:'),
        Text(
          auth.user!['referralCode'] ?? '',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        // Share button
        ElevatedButton(
          onPressed: () {
            // Share referral code
            Share.share('Join ShowOff.life with my code: ${auth.user!['referralCode']}');
          },
          child: Text('Share Code'),
        ),
      ],
    );
  },
),
```

## Step 9: Testing Checklist

After implementing all changes, test:

1. ✅ User Registration (Email/Phone)
2. ✅ User Login
3. ✅ Profile Setup Flow
4. ✅ Profile Picture Upload
5. ✅ Post Upload (Image/Video)
6. ✅ Feed Loading
7. ✅ Like/Comment
8. ✅ Follow/Unfollow
9. ✅ SYT Entry Submission
10. ✅ Voting
11. ✅ Spin Wheel
12. ✅ Watch Ads
13. ✅ Coin Balance
14. ✅ Transaction History
15. ✅ Withdrawal Request
16. ✅ Gift Sending

## Step 10: Error Handling

Add this helper function to all screens:

```dart
void _showError(String message) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

void _showSuccess(String message) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
}
```

## Step 11: Loading States

Add loading indicators:

```dart
bool _isLoading = false;

// Show loading
setState(() => _isLoading = true);

// Hide loading
setState(() => _isLoading = false);

// In UI:
if (_isLoading)
  const Center(child: CircularProgressIndicator())
else
  // Your content
```

## Important Notes

1. **Keep UI Exactly Same** - Only add backend logic, don't change any UI elements
2. **Error Handling** - Always wrap API calls in try-catch
3. **Loading States** - Show loading indicators during API calls
4. **Null Safety** - Check for null values before using data
5. **Navigation** - Use proper navigation after successful operations
6. **Refresh Data** - Reload data after create/update/delete operations

## Quick Start

1. Start backend server: `cd server && npm run dev`
2. Update API config with your server URL
3. Run Flutter app: `cd apps && flutter run`
4. Test registration and login first
5. Then test other features one by one

---

This guide maintains the exact UI while connecting everything to the backend!
