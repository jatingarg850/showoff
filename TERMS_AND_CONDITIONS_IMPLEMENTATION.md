# Terms & Conditions Implementation Guide

## Overview
Complete Terms & Conditions system with:
- Admin panel to create and manage T&C versions
- Flutter screen with checkbox for signup flow
- API endpoints for fetching and accepting T&C
- Database tracking of user acceptance

## Files Created

### Backend

1. **Model** - `server/models/TermsAndConditions.js`
   - Stores T&C versions with content
   - Tracks active version
   - Records last updated date

2. **Controller** - `server/controllers/termsController.js`
   - Public endpoints: Get current T&C, get by version
   - Private endpoints: Accept T&C
   - Admin endpoints: Create, update, delete, list versions

3. **Routes** - `server/routes/termsRoutes.js`
   - `/api/terms/current` - Get active T&C (public)
   - `/api/terms/:version` - Get specific version (public)
   - `/api/terms/accept` - Accept T&C (private)
   - `/api/admin/terms` - Manage T&C (admin)

4. **Admin View** - `server/views/admin/terms-and-conditions.ejs`
   - Editor tab: Create/edit T&C content
   - Versions tab: View version history
   - Delete old versions
   - Load current T&C

### Frontend

1. **Screen** - `apps/lib/terms_and_conditions_screen.dart`
   - Display T&C content
   - Checkbox to accept
   - Accept button
   - Can be used standalone or in signup flow

2. **API Methods** - `apps/lib/services/api_service.dart`
   - `getTermsAndConditions()` - Fetch current T&C
   - `acceptTermsAndConditions(version)` - Accept T&C
   - `getTermsByVersion(version)` - Fetch specific version

### Database

1. **User Model Update** - `server/models/User.js`
   - `termsAndConditionsAccepted` - Boolean flag
   - `termsAndConditionsVersion` - Version number accepted
   - `termsAndConditionsAcceptedAt` - Timestamp of acceptance

## Setup Instructions

### 1. Initialize Default T&C

Run this in your Node.js console or create a seed script:

```javascript
const TermsAndConditions = require('./models/TermsAndConditions');

const defaultContent = `SHOWOFF.LIFE – TERMS & CONDITIONS
Last Updated: 23 December 2025

[Full T&C content here...]`;

await TermsAndConditions.create({
  version: 1,
  title: 'SHOWOFF.LIFE – TERMS & CONDITIONS',
  content: defaultContent,
  isActive: true,
  lastUpdated: new Date()
});
```

### 2. Add to Signup Flow

In `signup_screen.dart` or email/phone signup screens:

```dart
// After user enters details, show T&C screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TermsAndConditionsScreen(
      isSignupFlow: true,
      onAccepted: () {
        // Continue with signup
        _completeSignup();
      },
    ),
  ),
);
```

### 3. Update Registration Endpoint

In `server/controllers/authController.js`, after user creation:

```javascript
// Get current T&C version
const currentTerms = await TermsAndConditions.findOne({ isActive: true });

// Update user
await User.findByIdAndUpdate(userId, {
  termsAndConditionsAccepted: true,
  termsAndConditionsVersion: currentTerms.version,
  termsAndConditionsAcceptedAt: new Date()
});
```

## Admin Panel Usage

### Access
- Navigate to: `http://localhost:3000/admin/terms-and-conditions`
- Login with admin credentials

### Editor Tab
1. Modify the T&C content
2. Click "Save New Version"
3. Previous version automatically deactivated
4. New version becomes active

### Versions Tab
1. View all T&C versions
2. See which version is active
3. View version details
4. Delete old versions

## API Endpoints

### Public Endpoints

**Get Current T&C**
```
GET /api/terms/current
Response: { success: true, data: { version, title, content, lastUpdated } }
```

**Get T&C by Version**
```
GET /api/terms/:version
Response: { success: true, data: { version, title, content } }
```

### Private Endpoints

**Accept T&C**
```
POST /api/terms/accept
Headers: Authorization: Bearer {token}
Body: { termsVersion: 1 }
Response: { success: true, data: { user } }
```

### Admin Endpoints

**Create New Version**
```
POST /api/admin/terms
Headers: Authorization: Bearer {adminToken}
Body: { title: "...", content: "..." }
Response: { success: true, data: { version, title, content } }
```

**Get All Versions**
```
GET /api/admin/terms
Headers: Authorization: Bearer {adminToken}
Response: { success: true, data: [{ version, title, isActive, ... }] }
```

**Update Version**
```
PUT /api/admin/terms/:id
Headers: Authorization: Bearer {adminToken}
Body: { title: "...", content: "..." }
Response: { success: true, data: { version, title, content } }
```

**Delete Version**
```
DELETE /api/admin/terms/:id
Headers: Authorization: Bearer {adminToken}
Response: { success: true, message: "..." }
```

## Features

### Version Management
- Automatic version numbering
- Only one active version at a time
- Previous versions preserved for audit trail
- Can view any historical version

### User Tracking
- Records when user accepted T&C
- Tracks which version they accepted
- Can identify users who haven't accepted latest version

### Admin Control
- Full CRUD operations
- Edit existing content
- Create new versions
- Delete old versions
- View version history

### Signup Integration
- Checkbox requirement
- Can't proceed without acceptance
- Automatic acceptance recording
- Version tracking

## Default T&C Content

The system comes with the provided T&C content covering:
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
- Payment Modes
- SOFFT Token Details
- International Users
- Limitation of Liability
- Indemnity
- Termination
- Governing Law
- Contact Details
- Change of Terms

## Testing

### Test Signup Flow
1. Start signup process
2. Fill in user details
3. T&C screen appears
4. Try to proceed without checking box (should fail)
5. Check box and click Accept
6. User created with T&C acceptance recorded

### Test Admin Panel
1. Login to admin panel
2. Go to Terms & Conditions
3. Edit content
4. Save new version
5. Check versions tab
6. Verify version history

### Test API
```bash
# Get current T&C
curl http://localhost:3000/api/terms/current

# Accept T&C (requires auth)
curl -X POST http://localhost:3000/api/terms/accept \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"termsVersion": 1}'
```

## Security Considerations

1. **Admin Access**: Only admins can create/edit T&C
2. **User Acceptance**: Tracked and timestamped
3. **Version Control**: Prevents accidental overwrites
4. **Audit Trail**: All versions preserved
5. **Compliance**: Records user acceptance for legal compliance

## Future Enhancements

1. **Multi-language Support**: T&C in different languages
2. **Acceptance Analytics**: Dashboard showing acceptance rates
3. **Forced Re-acceptance**: Require users to re-accept new versions
4. **Email Notifications**: Notify users of T&C changes
5. **PDF Export**: Generate PDF of T&C for download
6. **Comparison View**: Compare different versions side-by-side

## Troubleshooting

### T&C Not Loading
- Check if version exists in database
- Verify API endpoint is accessible
- Check network tab in browser console

### Acceptance Not Recording
- Verify user is authenticated
- Check if termsVersion is correct
- Check database for user record

### Admin Panel Not Showing
- Verify admin session is active
- Check if route is added to adminWebRoutes.js
- Verify sidebar link is present

## Support

For issues or questions:
- Email: support@showoff.life
- Check server logs for errors
- Verify database connection
