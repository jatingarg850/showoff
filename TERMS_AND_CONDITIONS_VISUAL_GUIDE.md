# T&C Checkbox Integration - Visual Guide

## User Interface Flow

### Before Implementation
```
┌─────────────────────────────────────┐
│         Set Password Screen         │
├─────────────────────────────────────┤
│                                     │
│  Password                           │
│  ┌─────────────────────────────┐   │
│  │ Enter your password      👁 │   │
│  └─────────────────────────────┘   │
│  ✓ At least 8 characters            │
│                                     │
│  Confirm Password                   │
│  ┌─────────────────────────────┐   │
│  │ Confirm your password    👁 │   │
│  └─────────────────────────────┘   │
│  ✓ Passwords match                  │
│                                     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      Continue (Enabled)     │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### After Implementation
```
┌─────────────────────────────────────┐
│         Set Password Screen         │
├─────────────────────────────────────┤
│                                     │
│  Password                           │
│  ┌─────────────────────────────┐   │
│  │ Enter your password      👁 │   │
│  └─────────────────────────────┘   │
│  ✓ At least 8 characters            │
│                                     │
│  Confirm Password                   │
│  ┌─────────────────────────────┐   │
│  │ Confirm your password    👁 │   │
│  └─────────────────────────────┘   │
│  ✓ Passwords match                  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☐ I agree to the Terms &   │   │ ← NEW
│  │   Conditions               │   │ ← NEW
│  └─────────────────────────────┘   │ ← NEW
│                                     │
│  ┌─────────────────────────────┐   │
│  │    Continue (Disabled)      │   │ ← Disabled until checked
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### After Checkbox Checked
```
┌─────────────────────────────────────┐
│         Set Password Screen         │
├─────────────────────────────────────┤
│                                     │
│  Password                           │
│  ┌─────────────────────────────┐   │
│  │ Enter your password      👁 │   │
│  └─────────────────────────────┘   │
│  ✓ At least 8 characters            │
│                                     │
│  Confirm Password                   │
│  ┌─────────────────────────────┐   │
│  │ Confirm your password    👁 │   │
│  └─────────────────────────────┘   │
│  ✓ Passwords match                  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ I agree to the Terms &   │   │ ← CHECKED
│  │   Conditions               │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      Continue (Enabled)     │   │ ← Now enabled!
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

## Complete Signup Flow

```
START
  │
  ├─→ Phone/Email Input Screen
  │   ├─ User enters phone or email
  │   └─ Clicks "Continue"
  │
  ├─→ OTP Verification Screen
  │   ├─ User receives OTP
  │   ├─ Enters 6-digit code
  │   └─ OTP verified
  │
  ├─→ Set Password Screen ⭐ NEW T&C CHECKBOX HERE
  │   ├─ User enters password (min 8 chars)
  │   ├─ User confirms password
  │   ├─ User MUST check T&C checkbox ⭐
  │   ├─ Continue button enabled only if:
  │   │  ✓ Password valid (8+ chars)
  │   │  ✓ Passwords match
  │   │  ✓ T&C checkbox checked ⭐
  │   └─ Clicks "Continue"
  │
  ├─→ Backend Validation
  │   ├─ Checks termsAccepted = true ⭐
  │   ├─ If false → 400 error
  │   ├─ If true → Create user
  │   └─ Records T&C acceptance ⭐
  │
  ├─→ Profile Picture Setup Screen
  │   ├─ User uploads profile picture
  │   └─ Clicks "Continue"
  │
  ├─→ Account Created ✓
  │   ├─ User logged in
  │   ├─ T&C acceptance recorded in DB
  │   └─ Ready to use app
  │
END
```

## State Management Flow

```
SetPasswordScreen
│
├─ _termsAccepted: false (initial)
│
├─ User taps checkbox
│  └─ setState(() { _termsAccepted = true })
│
├─ _canProceed getter evaluates:
│  ├─ _isPasswordValid? ✓
│  ├─ _doPasswordsMatch? ✓
│  ├─ _confirmPasswordController.text.isNotEmpty? ✓
│  └─ _termsAccepted? ✓ ← NEW
│
├─ All conditions true → Continue button ENABLED
│
└─ User clicks Continue
   └─ authProvider.register(termsAccepted: true)
      └─ ApiService.register(termsAccepted: true)
         └─ POST /api/auth/register { termsAccepted: true }
            └─ Backend validates and creates user
```

## Data Flow

```
Frontend (Flutter)
│
├─ SetPasswordScreen
│  └─ _termsAccepted = true/false
│
├─ AuthProvider.register()
│  └─ termsAccepted parameter
│
├─ ApiService.register()
│  └─ HTTP POST body: { termsAccepted: true }
│
└─ Network Request
   │
   ↓
Backend (Node.js)
│
├─ AuthController.register()
│  ├─ Extract termsAccepted from req.body
│  ├─ Validate: if (!termsAccepted) → 400 error
│  └─ Create user with T&C fields
│
├─ User.create()
│  ├─ termsAndConditionsAccepted: true
│  ├─ termsAndConditionsVersion: 1
│  └─ termsAndConditionsAcceptedAt: new Date()
│
└─ Database (MongoDB)
   │
   └─ User document saved with T&C fields
```

## Error Scenarios

### Scenario 1: User Tries to Skip T&C
```
User Action: Click Continue without checking checkbox
│
Frontend Response:
├─ Continue button is DISABLED
└─ User cannot proceed

Result: ✓ Prevented at frontend level
```

### Scenario 2: Frontend Bypassed (Manual API Call)
```
User Action: Send POST /api/auth/register without termsAccepted
│
Backend Response:
├─ Status: 400 Bad Request
├─ Message: "You must accept the Terms & Conditions to create an account"
└─ User not created

Result: ✓ Prevented at backend level
```

### Scenario 3: Valid Registration
```
User Action: Check checkbox and click Continue
│
Frontend:
├─ Validates all conditions
├─ Sends termsAccepted: true
└─ Shows loading dialog

Backend:
├─ Validates termsAccepted = true
├─ Creates user with T&C fields
└─ Returns 201 success

Database:
├─ User document created
├─ termsAndConditionsAccepted: true
├─ termsAndConditionsVersion: 1
└─ termsAndConditionsAcceptedAt: 2025-12-24T...

Result: ✓ Account created successfully
```

## UI Component Breakdown

### Checkbox Component
```
┌─────────────────────────────────────┐
│ Row(                                │
│   children: [                       │
│     Checkbox(                       │
│       value: _termsAccepted,        │
│       activeColor: 0xFF701CF5,      │ ← Purple
│       onChanged: (value) { ... }    │
│     ),                              │
│     Expanded(                       │
│       child: GestureDetector(       │
│         onTap: () { ... },          │ ← Tap to toggle
│         child: Text(                │
│           'I agree to the Terms &   │
│           Conditions'               │
│         ),                          │
│       ),                            │
│     ),                              │
│   ],                                │
│ )                                   │
└─────────────────────────────────────┘
```

### Continue Button States

**Disabled State (Checkbox Unchecked)**
```
┌─────────────────────────────────────┐
│         Continue (Disabled)         │
│         Background: Grey            │
│         Text: Grey                  │
│         Opacity: 0.5                │
│         onPressed: null             │
└─────────────────────────────────────┘
```

**Enabled State (Checkbox Checked)**
```
┌─────────────────────────────────────┐
│         Continue (Enabled)          │
│         Background: Purple Gradient │
│         Text: White                 │
│         Opacity: 1.0                │
│         onPressed: () { ... }       │
└─────────────────────────────────────┘
```

## Database Schema Visualization

```
User Collection
│
├─ _id: ObjectId
├─ username: "user1234567890"
├─ email: "user@example.com"
├─ phone: "1234567890"
├─ password: "hashed_password"
├─ displayName: "User"
│
├─ ⭐ NEW T&C FIELDS:
│  ├─ termsAndConditionsAccepted: true
│  ├─ termsAndConditionsVersion: 1
│  └─ termsAndConditionsAcceptedAt: ISODate("2025-12-24T10:30:00Z")
│
├─ coinBalance: 0
├─ referralCode: "abc123xyz"
├─ createdAt: ISODate("2025-12-24T10:30:00Z")
└─ updatedAt: ISODate("2025-12-24T10:30:00Z")
```

## Timeline

```
User Journey Timeline
│
├─ T+0s   → User enters phone/email
├─ T+5s   → OTP sent and verified
├─ T+10s  → User on password setup screen
├─ T+15s  → User enters password
├─ T+20s  → User checks T&C checkbox ⭐
├─ T+21s  → Continue button becomes enabled ⭐
├─ T+22s  → User clicks Continue
├─ T+23s  → Frontend sends registration request
├─ T+24s  → Backend validates T&C ⭐
├─ T+25s  → User created in database ⭐
├─ T+26s  → T&C acceptance recorded ⭐
├─ T+27s  → Profile picture setup screen shown
└─ T+30s  → Account fully created ✓
```

## Summary

The T&C checkbox integration adds a critical step to the signup flow:

1. **Frontend**: Checkbox prevents account creation without acceptance
2. **Backend**: Validates T&C acceptance before creating user
3. **Database**: Records acceptance with timestamp and version
4. **User Experience**: Clear, simple, and compulsory

This ensures legal compliance and tracks user consent for Terms & Conditions.
