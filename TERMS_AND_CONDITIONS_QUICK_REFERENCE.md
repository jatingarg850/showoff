# T&C Checkbox Integration - Quick Reference

## What Was Done
Added a compulsory Terms & Conditions checkbox to the password setup screen during signup. Users cannot create an account without accepting the T&C.

## Files Modified

| File | Changes |
|------|---------|
| `apps/lib/set_password_screen.dart` | Added T&C checkbox UI, state variable, and validation |
| `apps/lib/providers/auth_provider.dart` | Added `termsAccepted` parameter to register() |
| `apps/lib/services/api_service.dart` | Added `termsAccepted` to register API call |
| `server/controllers/authController.js` | Added T&C validation and database recording |

## How It Works

### Frontend Flow
1. User enters password on SetPasswordScreen
2. User MUST check "I agree to the Terms & Conditions" checkbox
3. Continue button is disabled until checkbox is checked
4. When clicked, register() is called with `termsAccepted: true`

### Backend Flow
1. Register endpoint receives `termsAccepted` flag
2. If false, returns 400 error: "You must accept the Terms & Conditions to create an account"
3. If true, creates user with T&C fields:
   - `termsAndConditionsAccepted: true`
   - `termsAndConditionsVersion: 1`
   - `termsAndConditionsAcceptedAt: new Date()`

## Key Code Snippets

### SetPasswordScreen - Checkbox UI
```dart
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
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    ),
  ],
)
```

### Backend Validation
```javascript
if (!termsAccepted) {
  return res.status(400).json({
    success: false,
    message: 'You must accept the Terms & Conditions to create an account',
  });
}
```

## Testing

### Manual Testing Steps
1. Start signup flow (phone or email)
2. Verify OTP
3. Go to password setup screen
4. Try clicking Continue without checking checkbox → Button should be disabled
5. Check the checkbox → Button should be enabled
6. Click Continue → Account should be created
7. Check database → User should have `termsAndConditionsAccepted: true`

### Error Testing
1. Manually send register request without `termsAccepted: true`
2. Should receive: "You must accept the Terms & Conditions to create an account"

## Signup Flow Integration

```
Phone/Email Input
    ↓
OTP Verification
    ↓
Set Password ← NEW: T&C Checkbox Here (COMPULSORY)
    ↓
Profile Picture Setup
    ↓
Account Created
```

## Database Schema

User model fields:
- `termsAndConditionsAccepted` (Boolean) - Default: false
- `termsAndConditionsVersion` (Number) - Default: 1
- `termsAndConditionsAcceptedAt` (Date) - Timestamp

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Continue button always disabled | Check `_termsAccepted` state is updating in setState |
| Registration fails with T&C error | Ensure `termsAccepted: true` is passed from frontend |
| Checkbox not visible | Check SetPasswordScreen layout - should be before Spacer |
| Database not recording T&C | Verify User model has T&C fields (already added) |

## Related Files

- T&C Content: `server/models/TermsAndConditions.js`
- T&C Admin Panel: `server/views/admin/terms-and-conditions.ejs`
- T&C Screen: `apps/lib/terms_and_conditions_screen.dart`
- T&C Routes: `server/routes/termsRoutes.js`

## Next Steps (Optional)

- [ ] Add "View T&C" link from checkbox screen
- [ ] Integrate T&C into Google OAuth signup
- [ ] Add T&C re-acceptance for version updates
- [ ] Create admin dashboard for T&C acceptance analytics
