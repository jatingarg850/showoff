# Critical Issues - Implementation Plan

## Priority Order & Status

### 🔴 CRITICAL (Fix First)
1. **Video Upload Errors & Performance** - Blocking users from uploading
2. **Video Deletion Feature** - Basic functionality missing
3. **Admin Panel Sync** - Coin values not updating
4. **Rewarded Ads Management** - Monetization blocker

### 🟠 HIGH (Fix Second)
5. **Detailed User Earnings** - Admin visibility
6. **Music Feature** - New feature with UI changes
7. **Selfie Feature Error** - User-facing bug

---

## Issue 1: Video Upload Errors & Performance Issues (CRITICAL)

### Problems:
- Errors during video uploads
- Camera running in background (battery drain)
- Wi-Fi upload failures

### Root Causes to Investigate:
- Video compression issues
- Network timeout on Wi-Fi
- Camera not being properly disposed
- File size too large

### Files to Check:
- `apps/lib/upload_content_screen.dart`
- `apps/lib/camera_screen.dart`
- `apps/lib/services/api_service.dart` (upload method)

### Implementation:
1. Add proper camera lifecycle management
2. Implement video compression before upload
3. Add retry logic for failed uploads
4. Add timeout handling for Wi-Fi

---

## Issue 2: User Profile – Video Deletion

### Requirements:
- Users can delete their own videos
- Confirmation dialog before deletion
- Update profile after deletion
- Remove from database and storage

### Files to Create/Modify:
- `apps/lib/profile_screen.dart` - Add delete button
- `server/controllers/postController.js` - Add delete endpoint
- `server/routes/postRoutes.js` - Add delete route

### Implementation:
1. Add delete button to video cards in profile
2. Create backend DELETE endpoint
3. Add confirmation dialog
4. Refresh profile after deletion

---

## Issue 3: Admin Panel Sync - Coin Values

### Problem:
- Admin changes coin values for rewarded ads
- App doesn't reflect changes

### Solution:
1. Add cache invalidation when admin updates values
2. Add real-time sync via WebSocket
3. Add refresh endpoint for app to call
4. Store coin values in database (not hardcoded)

### Files to Modify:
- `server/controllers/adminController.js` - Add coin update endpoint
- `apps/lib/services/api_service.dart` - Add fetch coin values
- `apps/lib/providers/app_provider.dart` - Cache coin values

---

## Issue 4: Rewarded Ads Management (VERY IMPORTANT)

### Requirements:
- Admin panel section for ads management
- Update links for Ads 1-5
- Rotate ads among users
- Serve from multiple companies

### Backend Implementation:
1. Create Ads model in database
2. Create admin endpoints for CRUD
3. Create user endpoint to get assigned ad
4. Implement ad rotation logic

### Frontend Implementation:
1. Create admin ads management screen
2. Add form to update ad links
3. Display ads in app based on assignment

---

## Issue 5: Music Feature

### Admin Panel:
- Music management section
- Upload/delete music
- View all uploaded music

### User App:
- Music selection in Reels
- Rename "Reels" → "Show"
- Rename "SYT" → "Show Your Talent (SYT)"

### Files to Create:
- `server/models/Music.js`
- `server/controllers/musicController.js`
- `apps/lib/music_management_screen.dart`
- `apps/lib/music_selection_screen.dart`

---

## Issue 6: Selfie Feature Error

### Problem:
- Selfie feature showing errors
- Missing demo section

### Solution:
1. Debug selfie feature
2. Add demo/tutorial section
3. Fix error handling

### Files to Check:
- `apps/lib/daily_selfie_screen.dart`
- `apps/lib/selfie_calendar_screen.dart`

---

## Implementation Timeline

| Issue | Priority | Estimated Time | Status |
|-------|----------|-----------------|--------|
| Video Upload Fix | CRITICAL | 4 hours | ⏳ TODO |
| Video Deletion | CRITICAL | 2 hours | ⏳ TODO |
| Admin Sync | CRITICAL | 3 hours | ⏳ TODO |
| Rewarded Ads | CRITICAL | 6 hours | ⏳ TODO |
| User Earnings | HIGH | 3 hours | ⏳ TODO |
| Music Feature | HIGH | 5 hours | ⏳ TODO |
| Selfie Feature | HIGH | 2 hours | ⏳ TODO |
| **TOTAL** | | **25 hours** | |

---

## Next Steps

1. Start with Issue 1 (Video Upload) - blocking users
2. Then Issue 2 (Video Deletion) - basic feature
3. Then Issue 3 (Admin Sync) - affects monetization
4. Then Issue 4 (Rewarded Ads) - critical for revenue
5. Then remaining issues

**Ready to start implementation?**
