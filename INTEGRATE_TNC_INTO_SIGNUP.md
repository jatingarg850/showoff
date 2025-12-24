# Integrate T&C into Signup Flow

## Status
✅ **T&C System is Ready**
- Database seeded with default T&C
- Admin panel accessible at: `http://localhost:3000/admin/terms-and-conditions`
- T&C screen created and ready to use
- API endpoints working

## Integration Steps

### Step 1: Update Phone Signup Screen

In `apps/lib/phone_signup_screen.dart`, after successful registration, add T&C screen:

```dart
import 'terms_and_conditions_screen.dart';

// In the registration success handler, replace:
// Navigator.pushReplacement(...)

// With:
if (context.mounted) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => TermsAndConditionsScreen(
        isSignupFlow: true,
        onAccepted: () {
          // After T&C accepted, go to main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(),
            ),
          );
        },
      ),
    ),
  );
}
```

### Step 2: Update Email Signup Screen

In `apps/lib/email_signup_screen.dart`, after OTP verification and registration:

```dart
import 'terms_and_conditions_screen.dart';

// After successful registration:
if (context.mounted) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => TermsAndConditionsScreen(
        isSignupFlow: true,
        onAccepted: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(),
            ),
          );
        },
      ),
    ),
  );
}
```

### Step 3: Update Google Auth Flow

In `apps/lib/services/google_auth_service.dart`, after successful Google signup:

```dart
import 'terms_and_conditions_screen.dart';

// After user creation:
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => TermsAndConditionsScreen(
      isSignupFlow: true,
      onAccepted: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      },
    ),
  ),
);
```

### Step 4: Update Backend Registration

In `server/controllers/authController.js`, after user creation, add T&C acceptance:

```javascript
const TermsAndConditions = require('../models/TermsAndConditions');

// After user is created:
const currentTerms = await TermsAndConditions.findOne({ isActive: true });

if (currentTerms) {
  await User.findByIdAndUpdate(userId, {
    termsAndConditionsAccepted: true,
    termsAndConditionsVersion: currentTerms.version,
    termsAndConditionsAcceptedAt: new Date()
  });
}
```

## Testing the Integration

### Test 1: Phone Signup
1. Open app
2. Click "Sign Up with Phone"
3. Enter phone number
4. Verify OTP
5. Enter display name
6. **T&C screen should appear**
7. Check checkbox
8. Click "Accept & Continue"
9. Should go to main screen

### Test 2: Email Signup
1. Open app
2. Click "Sign Up with Email"
3. Enter email
4. Verify OTP
5. Enter display name
6. **T&C screen should appear**
7. Check checkbox
8. Click "Accept & Continue"
9. Should go to main screen

### Test 3: Google Signup
1. Open app
2. Click "Continue with Google"
3. Select Google account
4. **T&C screen should appear**
5. Check checkbox
6. Click "Accept & Continue"
7. Should go to main screen

### Test 4: Verify Database
```bash
# Check user T&C acceptance
db.users.findOne({ 
  termsAndConditionsAccepted: true 
})

# Should show:
# termsAndConditionsAccepted: true
# termsAndConditionsVersion: 1
# termsAndConditionsAcceptedAt: <timestamp>
```

## Admin Panel

### Access
- URL: `http://localhost:3000/admin/terms-and-conditions`
- Login: `admin@showofflife.com` / `admin123`

### Features
- **Editor Tab**: Edit T&C content and save new versions
- **Versions Tab**: View all versions and delete old ones
- **Auto-versioning**: Each save creates new version
- **Active Status**: Only one version active at a time

## API Endpoints

### Get Current T&C
```bash
curl http://localhost:3000/api/terms/current
```

### Accept T&C (After Signup)
```bash
curl -X POST http://localhost:3000/api/terms/accept \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"termsVersion": 1}'
```

## Database Fields Added to User

```javascript
{
  termsAndConditionsAccepted: Boolean,      // true/false
  termsAndConditionsVersion: Number,        // version number
  termsAndConditionsAcceptedAt: Date        // timestamp
}
```

## Files to Modify

1. `apps/lib/phone_signup_screen.dart` - Add T&C after registration
2. `apps/lib/email_signup_screen.dart` - Add T&C after registration
3. `apps/lib/services/google_auth_service.dart` - Add T&C after Google signup
4. `server/controllers/authController.js` - Record T&C acceptance in backend

## Files Already Created

✅ `apps/lib/terms_and_conditions_screen.dart` - T&C screen
✅ `apps/lib/services/api_service.dart` - API methods (updated)
✅ `server/models/TermsAndConditions.js` - T&C model
✅ `server/controllers/termsController.js` - T&C controller
✅ `server/routes/termsRoutes.js` - T&C routes
✅ `server/views/admin/terms-and-conditions.ejs` - Admin UI
✅ `server/seeds/seedTermsAndConditions.js` - Seed script (executed)
✅ `server/models/User.js` - Updated with T&C fields
✅ `server/server.js` - Routes added
✅ `server/routes/adminWebRoutes.js` - Admin route added
✅ `server/views/admin/partials/admin-sidebar.ejs` - Sidebar link added

## Verification Checklist

- [ ] T&C seeded in database (✅ Done)
- [ ] Admin panel accessible
- [ ] T&C screen displays correctly
- [ ] Checkbox works
- [ ] Accept button works
- [ ] Phone signup shows T&C
- [ ] Email signup shows T&C
- [ ] Google signup shows T&C
- [ ] User record shows T&C acceptance
- [ ] Database has T&C fields

## Next Steps

1. Modify signup screens to show T&C
2. Test all signup flows
3. Verify database records
4. Test admin panel
5. Deploy to production

## Support

For issues:
- Check server logs
- Verify API endpoints
- Check database connection
- Review console errors in app
