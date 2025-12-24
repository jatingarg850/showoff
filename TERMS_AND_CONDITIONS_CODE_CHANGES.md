# T&C Checkbox Integration - Code Changes Reference

## 1. SetPasswordScreen - State Variable Addition

**File:** `apps/lib/set_password_screen.dart`

**Location:** In `_SetPasswordScreenState` class, after other boolean variables

```dart
// ADDED:
bool _termsAccepted = false;
```

## 2. SetPasswordScreen - _canProceed Getter Update

**File:** `apps/lib/set_password_screen.dart`

**Before:**
```dart
bool get _canProceed =>
    _isPasswordValid &&
    _doPasswordsMatch &&
    _confirmPasswordController.text.isNotEmpty;
```

**After:**
```dart
bool get _canProceed =>
    _isPasswordValid &&
    _doPasswordsMatch &&
    _confirmPasswordController.text.isNotEmpty &&
    _termsAccepted;
```

## 3. SetPasswordScreen - T&C Checkbox UI

**File:** `apps/lib/set_password_screen.dart`

**Location:** Before `const Spacer()` widget

```dart
// ADDED:
const SizedBox(height: 24),

// Terms & Conditions Checkbox
Row(
  children: [
    Checkbox(
      value: _termsAccepted,
      onChanged: (value) {
        setState(() {
          _termsAccepted = value ?? false;
        });
      },
      activeColor: const Color(0xFF701CF5),
    ),
    Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _termsAccepted = !_termsAccepted;
          });
        },
        child: const Text(
          'I agree to the Terms & Conditions',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    ),
  ],
),
```

## 4. SetPasswordScreen - Register Call Update

**File:** `apps/lib/set_password_screen.dart`

**Location:** In the onPressed callback of Continue button

**Before:**
```dart
final success = await authProvider.register(
  username: tempUsername,
  displayName: 'User',
  password: _passwordController.text,
  email: widget.email,
  phone: widget.phone != null
      ? '${widget.countryCode}${widget.phone}'
      : null,
);
```

**After:**
```dart
final success = await authProvider.register(
  username: tempUsername,
  displayName: 'User',
  password: _passwordController.text,
  email: widget.email,
  phone: widget.phone != null
      ? '${widget.countryCode}${widget.phone}'
      : null,
  termsAccepted: _termsAccepted,
);
```

## 5. AuthProvider - register() Method Update

**File:** `apps/lib/providers/auth_provider.dart`

**Before:**
```dart
Future<bool> register({
  required String username,
  required String displayName,
  required String password,
  String? email,
  String? phone,
  String? referralCode,
}) async {
  // ...
  final response = await ApiService.register(
    username: username,
    displayName: displayName,
    password: password,
    email: email,
    phone: phone,
    referralCode: referralCode,
  );
```

**After:**
```dart
Future<bool> register({
  required String username,
  required String displayName,
  required String password,
  String? email,
  String? phone,
  String? referralCode,
  bool termsAccepted = false,
}) async {
  // ...
  final response = await ApiService.register(
    username: username,
    displayName: displayName,
    password: password,
    email: email,
    phone: phone,
    referralCode: referralCode,
    termsAccepted: termsAccepted,
  );
```

## 6. ApiService - register() Method Update

**File:** `apps/lib/services/api_service.dart`

**Before:**
```dart
static Future<Map<String, dynamic>> register({
  required String username,
  required String displayName,
  required String password,
  String? email,
  String? phone,
  String? referralCode,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: await _getHeaders(),
    body: jsonEncode({
      'username': username,
      'displayName': displayName,
      'password': password,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (referralCode != null) 'referralCode': referralCode,
    }),
  );
```

**After:**
```dart
static Future<Map<String, dynamic>> register({
  required String username,
  required String displayName,
  required String password,
  String? email,
  String? phone,
  String? referralCode,
  bool termsAccepted = false,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: await _getHeaders(),
    body: jsonEncode({
      'username': username,
      'displayName': displayName,
      'password': password,
      'termsAccepted': termsAccepted,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (referralCode != null) 'referralCode': referralCode,
    }),
  );
```

## 7. AuthController - register() Endpoint Update

**File:** `server/controllers/authController.js`

**Location:** At the beginning of the register function

**Before:**
```javascript
exports.register = async (req, res) => {
  try {
    const { email, phone, password, username, displayName, referralCode } = req.body;

    // Normalize phone number if provided
    const normalizedPhone = phone ? phone.replace(/\D/g, '') : null;
```

**After:**
```javascript
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
```

## 8. AuthController - User Creation Update

**File:** `server/controllers/authController.js`

**Location:** In the User.create() call

**Before:**
```javascript
const user = await User.create({
  email,
  phone: normalizedPhone,
  password,
  username: username.toLowerCase(),
  displayName,
  referralCode: generateReferralCode(username),
});
```

**After:**
```javascript
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
```

## Summary of Changes

| Component | Change Type | Details |
|-----------|------------|---------|
| SetPasswordScreen | State | Added `_termsAccepted` boolean |
| SetPasswordScreen | Getter | Updated `_canProceed` to require T&C |
| SetPasswordScreen | UI | Added checkbox with label |
| SetPasswordScreen | Logic | Pass `termsAccepted` to register |
| AuthProvider | Method | Added `termsAccepted` parameter |
| ApiService | Method | Added `termsAccepted` to request |
| AuthController | Validation | Check T&C acceptance |
| AuthController | Database | Record T&C acceptance |

## Testing the Changes

### Frontend Test
```dart
// In SetPasswordScreen
// 1. Verify _termsAccepted starts as false
// 2. Verify Continue button is disabled
// 3. Tap checkbox - button should enable
// 4. Tap text label - checkbox should toggle
// 5. Uncheck - button should disable again
```

### Backend Test
```javascript
// Test 1: Without termsAccepted
POST /api/auth/register
{
  "username": "testuser",
  "displayName": "Test User",
  "password": "password123",
  "email": "test@example.com"
}
// Expected: 400 error "You must accept the Terms & Conditions..."

// Test 2: With termsAccepted: false
POST /api/auth/register
{
  "username": "testuser",
  "displayName": "Test User",
  "password": "password123",
  "email": "test@example.com",
  "termsAccepted": false
}
// Expected: 400 error

// Test 3: With termsAccepted: true
POST /api/auth/register
{
  "username": "testuser",
  "displayName": "Test User",
  "password": "password123",
  "email": "test@example.com",
  "termsAccepted": true
}
// Expected: 201 success, user created with T&C fields
```

## Database Verification

After successful registration with T&C:
```javascript
db.users.findOne({ username: "testuser" })
// Should show:
// {
//   ...
//   termsAndConditionsAccepted: true,
//   termsAndConditionsVersion: 1,
//   termsAndConditionsAcceptedAt: ISODate("2025-12-24T..."),
//   ...
// }
```
