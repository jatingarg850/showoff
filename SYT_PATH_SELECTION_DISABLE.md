# SYT Button Disabled After Submission - Implementation

## Feature
The SYT button in the path selection screen is now automatically disabled if the user has already submitted an entry for the current running competition.

## What Was Changed

### File: `apps/lib/path_selection_screen.dart`

#### 1. Added State Variables
```dart
bool _hasSubmittedSYT = false;
bool _isLoadingSYTStatus = true;
```

#### 2. Added Submission Check on Init
```dart
@override
void initState() {
  super.initState();
  _checkSYTSubmissionStatus();
}

Future<void> _checkSYTSubmissionStatus() async {
  try {
    final response = await ApiService.checkUserWeeklySubmission();
    if (response['success']) {
      setState(() {
        _hasSubmittedSYT = response['data']['hasSubmitted'] ?? false;
        _isLoadingSYTStatus = false;
      });
    }
  } catch (e) {
    print('Error checking SYT submission: $e');
    setState(() {
      _hasSubmittedSYT = false;
      _isLoadingSYTStatus = false;
    });
  }
}
```

#### 3. Updated SYT Button UI

**Visual Changes:**
- **Opacity:** Reduced to 50% when disabled
- **Background:** Changes to grey when disabled
- **Border:** Changes to grey when disabled
- **Icon:** Changes to grey when disabled
- **Text:** Changes from "Compete to win prizes" to "Already submitted"
- **Badge:** Shows orange "Submitted" badge in top-right corner

**Interaction:**
- **onTap:** Set to `null` when disabled (prevents selection)
- **Selection:** Cannot be selected if already submitted

## User Experience

### Before Submission
```
┌─────────────────┐
│  [SYT Icon]     │
│      SYT        │
│ Compete to win  │
│    prizes       │
└─────────────────┘
✅ Clickable
✅ Can be selected
✅ Full color
```

### After Submission
```
┌─────────────────┐
│ [Submitted] 🟧  │
│  [SYT Icon]     │  (greyed out)
│      SYT        │  (greyed out)
│   Already       │  (greyed out)
│   submitted     │
└─────────────────┘
❌ Not clickable
❌ Cannot be selected
❌ 50% opacity
❌ Grey colors
```

## How It Works

### Flow Diagram
```
User opens Path Selection Screen
           ↓
    initState() called
           ↓
_checkSYTSubmissionStatus()
           ↓
API call: /api/syt/check-submission?type=weekly
           ↓
    ┌─────────────┐
    │  Response   │
    └─────────────┘
           ↓
    ┌──────────────────────┐
    │ hasSubmitted: true?  │
    └──────────────────────┘
         ↓           ↓
       YES          NO
         ↓           ↓
   Disable SYT   Enable SYT
   Show badge    Normal state
   Grey colors   Full colors
```

### API Integration
Uses existing endpoint:
```
GET /api/syt/check-submission?type=weekly
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "hasCompetition": true,
    "hasSubmitted": true,  // ← This determines button state
    "competition": { ... },
    "submission": { ... }
  }
}
```

## Testing

### Test Case 1: User Has Not Submitted
1. Open app
2. Tap the + button (center of bottom nav)
3. Path selection screen opens
4. SYT button should be:
   - ✅ Full color
   - ✅ Clickable
   - ✅ Shows "Compete to win prizes"
   - ✅ No "Submitted" badge

### Test Case 2: User Has Already Submitted
1. Upload an SYT reel
2. Go back to home
3. Tap the + button again
4. Path selection screen opens
5. SYT button should be:
   - ✅ Greyed out (50% opacity)
   - ✅ Not clickable
   - ✅ Shows "Already submitted"
   - ✅ Orange "Submitted" badge visible
   - ✅ Cannot be selected

### Test Case 3: New Competition Starts
1. Admin creates new competition
2. User opens path selection screen
3. SYT button should be:
   - ✅ Enabled again (user hasn't submitted to new competition)
   - ✅ Full color
   - ✅ Clickable

## Edge Cases Handled

### 1. API Error
If the API call fails:
- Button defaults to enabled state
- User can attempt to submit
- Backend will validate and reject if already submitted

### 2. No Active Competition
If no competition is running:
- Button remains enabled
- Backend will reject submission with appropriate message

### 3. Network Timeout
If network is slow:
- `_isLoadingSYTStatus` can be used to show loading indicator
- Currently defaults to enabled state

## Future Enhancements

### Optional: Add Loading State
```dart
if (_isLoadingSYTStatus)
  Positioned.fill(
    child: Container(
      color: Colors.white.withOpacity(0.7),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  ),
```

### Optional: Add Refresh Button
Allow user to manually refresh submission status:
```dart
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: _checkSYTSubmissionStatus,
)
```

### Optional: Show Submission Details
When disabled, show info about the submitted entry:
```dart
Text(
  'Submitted: ${submission.title}',
  style: TextStyle(fontSize: 10),
)
```

## Related Files
- `apps/lib/path_selection_screen.dart` - Main implementation
- `apps/lib/services/api_service.dart` - API call method
- `server/controllers/sytController.js` - Backend validation
- `apps/lib/talent_screen.dart` - Also checks submission status

## Summary

✅ SYT button automatically disabled after submission
✅ Visual feedback with grey colors and badge
✅ Prevents accidental multiple submissions
✅ Checks status on every screen open
✅ Consistent with talent screen behavior
✅ User-friendly error prevention

The path selection screen now provides clear visual feedback about SYT submission status, preventing users from attempting to submit multiple entries for the same competition!
