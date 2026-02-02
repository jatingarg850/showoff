# Withdrawal Request Admin Flow - Complete Guide

## Problem
User submitted a withdrawal request but cannot find it in the admin panel. The withdrawal request was successfully created (201 status) but doesn't appear in the KYC Management screen.

## Root Cause
**Withdrawal requests and KYC applications are TWO SEPARATE SYSTEMS:**
- **KYC Management** (`/admin/kyc`) - For user identity verification (passport, driving license, national ID, etc.)
- **Withdrawals** (`/admin/withdrawals`) - For money withdrawal requests from users

The user was looking in the wrong section. Withdrawal requests appear in the **Withdrawals** section, NOT in KYC Management.

## Complete Withdrawal Request Flow

### Step 1: User Submits Withdrawal Request (Mobile App)
**Screen**: Withdrawal Screen
**Action**: User enters:
- Withdrawal amount (in coins)
- Withdrawal method (UPI, Bank Transfer, Sofft Address, PayPal)
- Method-specific details (UPI ID, Bank Account, etc.)
- ID documents (uploaded as images)

**Backend**: `POST /api/withdrawal/request`
- Validates minimum withdrawal amount (default 1000 coins)
- Checks user coin balance
- Calculates amounts:
  - INR Amount = Coins / 1 (1 coin = 1 INR)
  - USD Amount = INR / 83 (1 USD ≈ 83 INR)
  - Local Amount = INR (for INR users)
- Uploads ID documents to Wasabi S3
- Creates Withdrawal record in database with status="pending"
- Deducts coins from user balance immediately
- Creates Transaction record with type="withdrawal"

**Response**: 201 Created
```json
{
  "success": true,
  "message": "Withdrawal request submitted successfully. Your money will be processed within 24 hours.",
  "data": {
    "_id": "withdrawal_id",
    "user": "user_id",
    "coinAmount": 1006,
    "localAmount": 1006,
    "usdAmount": 12.12,
    "method": "upi",
    "upiId": "jatingarg850@ybl",
    "idDocuments": [...],
    "status": "pending"
  }
}
```

### Step 2: Admin Reviews Withdrawal Request (Web Admin Panel)

#### Navigate to Withdrawals Section
1. Go to Admin Panel: `http://localhost:3000/admin`
2. Click **"Withdrawals"** in the left sidebar (NOT KYC Management)
3. You should see the withdrawal request in the list

#### Withdrawal Management Page Features
- **Status Filter**: Pending, Processing, Completed, Rejected, All
- **Stats Cards**: Shows count of withdrawals by status
- **Withdrawal Table**: Lists all withdrawals with:
  - User info (username, profile picture)
  - Amount (coins + INR)
  - Withdrawal method
  - Request date
  - Current status
  - Action buttons

#### View Withdrawal Details
1. Click on a withdrawal row to open details modal
2. Modal shows:
   - User information
   - Withdrawal amount and method
   - Method-specific details (UPI ID, Bank Account, etc.)
   - ID documents (uploaded images)
   - Current status
   - Admin notes (if any)

### Step 3: Admin Approves or Rejects

#### Approve Withdrawal
1. Click "Approve" button on withdrawal row
2. Modal opens with:
   - Current requested amount
   - Input field to adjust approved amount (optional)
   - Admin notes field
   - Transaction ID field
3. Admin can:
   - Approve full amount (leave as-is)
   - Approve partial amount (edit amount field)
   - Add notes about the approval
4. Click "Confirm Approve"
5. Backend updates:
   - Withdrawal status → "completed"
   - Stores approvedAmount (may differ from requested)
   - Stores admin notes
   - Stores processedBy (admin user ID)
   - Stores processedAt (timestamp)
   - Updates Transaction status → "completed"

#### Reject Withdrawal
1. Click "Reject" button on withdrawal row
2. Modal opens with:
   - Rejection reason field
   - Admin notes field
3. Admin enters rejection reason
4. Click "Confirm Reject"
5. Backend updates:
   - Withdrawal status → "rejected"
   - Stores rejection reason
   - **Refunds coins to user** (adds back to coinBalance)
   - Creates refund Transaction record
   - Updates original Transaction status → "failed"

### Step 4: User Receives Notification
- User receives notification about withdrawal approval/rejection
- If approved: Money will be transferred within 24 hours
- If rejected: Coins are refunded to wallet

## Admin Panel Navigation

### Correct Path to Withdrawals
```
Admin Dashboard
  ↓
Left Sidebar Menu
  ↓
"Withdrawals" (with money-bill-wave icon)
  ↓
Withdrawal Management Page
```

### DO NOT Look Here
❌ KYC Management - This is for user identity verification, NOT withdrawals
❌ Financial - This is for analytics, NOT withdrawal requests

## Database Models

### Withdrawal Model
```javascript
{
  _id: ObjectId,
  user: ObjectId (ref: User),
  coinAmount: Number,
  inrAmount: Number,
  usdAmount: Number,
  localAmount: Number,
  currency: String,
  method: String (bank_transfer, sofft_address, upi, paypal),
  
  // Method-specific details
  bankDetails: {
    accountName: String,
    accountNumber: String,
    bankName: String,
    ifscCode: String
  },
  sofftAddress: String,
  upiId: String,
  
  // ID Documents
  idDocuments: [{
    url: String (S3 URL),
    type: String,
    uploadedAt: Date
  }],
  
  // Status
  status: String (pending, processing, completed, rejected),
  adminNotes: String,
  approvedAmount: Number,
  processedBy: ObjectId (ref: User),
  processedAt: Date,
  
  createdAt: Date,
  updatedAt: Date
}
```

### KYC Model (Different System)
```javascript
{
  _id: ObjectId,
  user: ObjectId (ref: User, unique),
  fullName: String,
  dateOfBirth: Date,
  gender: String,
  address: Object,
  documentType: String (passport, driving_license, national_id, aadhaar),
  documentNumber: String,
  documentFrontImage: String (S3 URL),
  documentBackImage: String (S3 URL),
  selfieImage: String (S3 URL),
  bankDetails: Object,
  status: String (pending, under_review, approved, rejected, resubmit_required),
  reviewedBy: ObjectId (ref: User),
  createdAt: Date,
  updatedAt: Date
}
```

## API Endpoints

### Withdrawal Endpoints (Admin)
- `GET /api/admin/withdrawals` - Get all withdrawals with pagination
- `GET /api/admin/withdrawals/:id` - Get withdrawal details
- `PUT /api/admin/withdrawals/:id/approve` - Approve withdrawal
- `PUT /api/admin/withdrawals/:id/reject` - Reject withdrawal

### Web Routes (Admin Panel)
- `GET /admin/withdrawals` - Withdrawals management page
- `POST /admin/withdrawals/:id/approve` - Approve (AJAX)
- `POST /admin/withdrawals/:id/reject` - Reject (AJAX)

### KYC Endpoints (Admin)
- `GET /api/kyc/admin/all` - Get all KYC applications
- `GET /api/kyc/admin/:id` - Get KYC details
- `PUT /api/kyc/admin/:id/approve` - Approve KYC
- `PUT /api/kyc/admin/:id/reject` - Reject KYC

## Troubleshooting

### Withdrawal Request Not Appearing
1. **Check Status Filter**: Make sure filter is set to "Pending" or "All"
2. **Check Database**: Verify withdrawal record exists
   ```
   db.withdrawals.find({status: "pending"})
   ```
3. **Check User Reference**: Verify user still exists
   ```
   db.withdrawals.findOne({_id: ObjectId("...")}).user
   ```
4. **Check Server Logs**: Look for errors in `/admin/withdrawals` route
5. **Refresh Page**: Clear browser cache and refresh

### Withdrawal Shows But Can't Approve
1. **Check Admin Session**: Verify admin is properly authenticated
2. **Check Permissions**: Verify admin has withdrawal approval permissions
3. **Check Browser Console**: Look for JavaScript errors
4. **Check Server Logs**: Look for backend errors

### Coins Not Refunded After Rejection
1. **Check Transaction**: Verify refund transaction was created
   ```
   db.transactions.find({type: "withdrawal_refund"})
   ```
2. **Check User Balance**: Verify coins were added back
   ```
   db.users.findOne({_id: ObjectId("...")}).coinBalance
   ```
3. **Check Server Logs**: Look for errors in rejection handler

## Key Differences: KYC vs Withdrawals

| Feature | KYC Management | Withdrawals |
|---------|---|---|
| **Purpose** | User identity verification | Money withdrawal requests |
| **Data** | Personal info, ID documents, selfie | Withdrawal amount, method, ID docs |
| **Status** | pending, under_review, approved, rejected, resubmit_required | pending, processing, completed, rejected |
| **Admin Action** | Approve/Reject identity | Approve/Reject payment |
| **User Impact** | Enables withdrawal capability | Transfers money to user |
| **Menu Location** | KYC Management | Withdrawals |
| **URL** | /admin/kyc | /admin/withdrawals |

## Summary

✅ **Withdrawal requests appear in**: `/admin/withdrawals` section
❌ **NOT in**: KYC Management section

**To find withdrawal requests**:
1. Go to Admin Panel
2. Click "Withdrawals" in left sidebar
3. Filter by "Pending" status
4. Click on withdrawal to view details
5. Click "Approve" or "Reject" to process

The system is working correctly - the withdrawal request was successfully created and is waiting in the Withdrawals section for admin review.
