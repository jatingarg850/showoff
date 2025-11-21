# Withdrawal System Implementation

## Overview
Implemented a complete withdrawal flow with admin panel integration for ShowOff Life app.

## Features Implemented

### 1. User Withdrawal Flow (Flutter App)

**File:** `apps/lib/withdrawal_screen.dart`

- **Withdrawal Balance Display**: Shows user's available coin balance in a gradient card
- **Amount Input**: User enters withdrawal amount with validation
- **Minimum Withdrawal**: Admin-configurable minimum amount (default: 100 coins)
- **Two Withdrawal Methods**:
  - **Sofft Address**: For crypto/wallet withdrawals
  - **UPI**: For Indian UPI payments
- **ID Document Upload**: Users must upload ID documents (stored on Wasabi)
- **Success Confirmation**: Bottom sheet showing "Your money will be withdrawn within 24 hours"

**Flow:**
1. User enters withdrawal amount
2. Clicks "Continue"
3. Bottom sheet appears with two options: Sofft Address or UPI
4. User selects method
5. Another bottom sheet for entering payment details and uploading ID documents
6. User submits
7. Success bottom sheet confirms 24-hour processing time

### 2. Backend API Updates

**Files Modified:**
- `server/models/Withdrawal.js`
- `server/controllers/withdrawalController.js`
- `server/routes/withdrawalRoutes.js`

**New Fields Added:**
- `sofftAddress`: For Sofft wallet withdrawals
- `upiId`: For UPI payments
- `idDocuments`: Array of uploaded ID documents with URLs and types
- `method`: Updated enum to include 'sofft_address' and 'upi'

**New Endpoints:**
- `GET /api/withdrawal/settings` - Get minimum withdrawal amount and settings
- `POST /api/withdrawal/request` - Submit withdrawal with ID documents (multipart)

**Features:**
- Validates minimum withdrawal amount (set by admin)
- Uploads ID documents to Wasabi
- Deducts coins from user balance immediately
- Creates pending transaction
- Returns success message with 24-hour processing time

### 3. Admin Panel Integration

**Files Modified:**
- `server/views/admin/withdrawals.ejs`
- `server/controllers/adminController.js`
- `server/routes/adminRoutes.js`

**Admin Features:**
- View all withdrawal requests with filters (pending, processing, completed, rejected)
- See withdrawal statistics dashboard
- View user details, amount, method, and payment details
- **View ID Documents**: Admin can see all uploaded ID documents in a grid
- **Approve Withdrawals**: Mark as completed with optional transaction ID
- **Reject Withdrawals**: Automatically refunds coins to user with reason
- Real-time status updates

**New Admin API Endpoints:**
- `GET /api/admin/withdrawals` - List all withdrawals with pagination
- `GET /api/admin/withdrawals/:id` - Get withdrawal details
- `PUT /api/admin/withdrawals/:id/approve` - Approve withdrawal
- `PUT /api/admin/withdrawals/:id/reject` - Reject and refund

**Admin View Features:**
- Shows ID document count in table
- Modal popup with full withdrawal details
- Image gallery for ID documents (click to open full size)
- Displays Sofft Address or UPI ID based on method
- Transaction history tracking

### 4. Environment Configuration

**File:** `server/.env`

Added:
```
MIN_WITHDRAWAL_AMOUNT=100
```

This can be changed by admin to set minimum withdrawal threshold.

### 5. API Service Updates

**File:** `apps/lib/services/api_service.dart`

**New Methods:**
- `requestWithdrawal()` - Multipart request supporting ID document uploads
- `getWithdrawalSettings()` - Fetch minimum withdrawal amount

## Technical Details

### Withdrawal Process Flow

1. **User Side:**
   - User initiates withdrawal
   - Selects payment method (Sofft/UPI)
   - Uploads ID documents
   - Submits request
   - Coins deducted immediately
   - Receives confirmation

2. **Admin Side:**
   - Sees pending request in admin panel
   - Views user details and ID documents
   - Verifies information
   - Approves or rejects
   - If rejected, coins automatically refunded

3. **Database:**
   - Withdrawal record created with status 'pending'
   - Transaction record created
   - ID documents stored with Wasabi URLs
   - Status updated by admin actions

### Security Features

- KYC verification required before withdrawal
- ID document verification
- Admin approval required
- Automatic refund on rejection
- Transaction audit trail
- Minimum withdrawal limits

### Payment Methods Supported

1. **Sofft Address** - Crypto wallet address
2. **UPI** - Indian UPI ID (e.g., name@upi)

## Testing

To test the withdrawal flow:

1. **User App:**
   - Navigate to withdrawal screen
   - Enter amount >= 100 coins
   - Select payment method
   - Upload ID documents
   - Submit request

2. **Admin Panel:**
   - Login to admin panel at `/admin/login`
   - Navigate to "Withdrawals" section
   - View pending requests
   - Click "View" to see details and ID documents
   - Approve or reject

## Notes

- Processing time: 24 hours (displayed to users)
- ID documents stored on Wasabi S3
- Coins deducted immediately on request
- Refunded automatically if rejected
- Admin can add transaction ID when approving
- All actions logged with timestamps

## Future Enhancements

- Email notifications on status changes
- Automatic KYC verification
- Multiple currency support
- Batch approval for admins
- Withdrawal history for users
- Analytics dashboard for withdrawals
