# Terms & Conditions - Quick Start Guide

## What Was Created

✅ **Complete T&C System** with:
- Admin panel to manage T&C content
- Flutter screen with checkbox for signup
- Database tracking of user acceptance
- Version control system
- API endpoints for all operations

## Files Created

### Backend (Server)
- `server/models/TermsAndConditions.js` - Database model
- `server/controllers/termsController.js` - API logic
- `server/routes/termsRoutes.js` - API routes
- `server/views/admin/terms-and-conditions.ejs` - Admin UI

### Frontend (App)
- `apps/lib/terms_and_conditions_screen.dart` - T&C screen
- Updated `apps/lib/services/api_service.dart` - API methods

### Database
- Updated `server/models/User.js` - Added T&C fields

### Routes
- Updated `server/server.js` - Added terms routes
- Updated `server/routes/adminWebRoutes.js` - Added admin route
- Updated `server/views/admin/partials/admin-sidebar.ejs` - Added sidebar link

## Quick Setup

### 1. Seed Default T&C
```javascript
// Run in Node console or create seed script
const TermsAndConditions = require('./models/TermsAndConditions');

await TermsAndConditions.create({
  version: 1,
  title: 'SHOWOFF.LIFE – TERMS & CONDITIONS',
  content: 'SHOWOFF.LIFE – TERMS & CONDITIONS\nLast Updated: 23 December 2025\n\n[Full content provided]',
  isActive: true
});
```

### 2. Access Admin Panel
- URL: `http://localhost:3000/admin/terms-and-conditions`
- Login with admin credentials
- Edit and save T&C content

### 3. Add to Signup Flow
In your signup screen, after user details:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TermsAndConditionsScreen(
      isSignupFlow: true,
      onAccepted: () => _completeSignup(),
    ),
  ),
);
```

## Key Features

### Admin Panel
- **Editor Tab**: Create/edit T&C content
- **Versions Tab**: View all versions, delete old ones
- **Auto-versioning**: Each save creates new version
- **Active Status**: Only one version active at a time

### Flutter Screen
- Display T&C content
- Checkbox to accept
- Accept button (disabled until checked)
- Can be used standalone or in signup flow

### Database Tracking
- Records when user accepted T&C
- Tracks which version they accepted
- Timestamp of acceptance

## API Endpoints

### Public
- `GET /api/terms/current` - Get active T&C
- `GET /api/terms/:version` - Get specific version

### Private
- `POST /api/terms/accept` - Accept T&C (requires auth)

### Admin
- `POST /api/admin/terms` - Create new version
- `GET /api/admin/terms` - List all versions
- `PUT /api/admin/terms/:id` - Update version
- `DELETE /api/admin/terms/:id` - Delete version

## Testing

### Test Admin Panel
1. Go to `http://localhost:3000/admin/terms-and-conditions`
2. Edit content in Editor tab
3. Click "Save New Version"
4. Check Versions tab to see history

### Test Signup Flow
1. Start signup
2. Fill user details
3. T&C screen appears
4. Try to proceed without checkbox (fails)
5. Check box and accept
6. User created with T&C recorded

### Test API
```bash
# Get current T&C
curl http://localhost:3000/api/terms/current

# Accept T&C
curl -X POST http://localhost:3000/api/terms/accept \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"termsVersion": 1}'
```

## Content Included

The system includes the complete T&C content covering:
- Definitions
- Eligibility & Age Policy
- Child Content Upload & Guardian Responsibility
- User Content Ownership & Liability
- Copyright & IP Policy
- Prohibited Content
- Upload Disclaimer
- Content Moderation
- KYC/AML Verification
- Withdrawal Eligibility
- Payment Modes (SOFFT Token)
- International Users
- Limitation of Liability
- Indemnity
- Termination
- Governing Law & Jurisdiction
- Contact Details
- Change of Terms

## Admin Credentials
- Email: `admin@showofflife.com`
- Password: `admin123`

## Next Steps

1. ✅ Seed default T&C in database
2. ✅ Test admin panel
3. ✅ Integrate T&C screen into signup flow
4. ✅ Test signup with T&C acceptance
5. ✅ Verify user records show T&C acceptance

## Support

For issues:
- Check server logs
- Verify database connection
- Ensure all files are created
- Check API endpoints are accessible

## Documentation

Full documentation available in: `TERMS_AND_CONDITIONS_IMPLEMENTATION.md`
