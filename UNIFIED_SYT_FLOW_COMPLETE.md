# Unified SYT Content Creation Flow - Complete Implementation

## Overview
The entire SYT (Show Your Talent) submission flow has been unified across the app. Users now experience the same 6-step flow regardless of where they start the submission process.

## Entry Points to SYT Flow

### 1. Path Selection Screen
**File**: `apps/lib/path_selection_screen.dart`
**Button**: "Continue" after selecting SYT
**Flow**: ContentCreationFlowScreen(selectedPath: 'SYT', sytCategory: null)

```
Path Selection Screen
    ↓
Select "SYT" option
    ↓
Click "Continue"
    ↓
ContentCreationFlowScreen
```

### 2. Talent Screen - Message Box
**File**: `apps/lib/talent_screen.dart`
**Button**: "Show off" in message box (for users who haven't submitted)
**Flow**: ContentCreationFlowScreen(selectedPath: 'SYT', sytCategory: null)

```
Talent Screen
    ↓
See message: "You have not shared your talent to the world"
    ↓
Click "Show off" button
    ↓
ContentCreationFlowScreen
```

### 3. Talent Screen - Floating Button
**File**: `apps/lib/talent_screen.dart`
**Button**: "Show Your Talent : SYT" floating button
**Flow**: ContentCreationFlowScreen(selectedPath: 'SYT', sytCategory: null)
**Status**: Disabled if user already submitted this week

```
Talent Screen
    ↓
See floating button at bottom
    ↓
Click "Show Your Talent : SYT"
    ↓
ContentCreationFlowScreen
```

### 4. SYT Reel Screen - Show off Button
**File**: `apps/lib/syt_reel_screen.dart`
**Button**: "Show off" in right-side action buttons
**Flow**: ContentCreationFlowScreen(selectedPath: 'SYT', sytCategory: reel['category'])
**Special**: Pre-selects the category from current reel

```
SYT Reel Screen
    ↓
View competition entry
    ↓
Click "Show off" button (right side)
    ↓
Video pauses, music stops
    ↓
ContentCreationFlowScreen (with category pre-selected)
    ↓
After upload, video/music resume
```

## The 6-Step Unified Flow

### Step 1: Record
**Screen**: `CameraScreen`
**Actions**:
- Record video (5 seconds to 5 minutes)
- Or take photo
- Preview recording
- Re-record if needed

**Output**: mediaPath, isVideo flag

### Step 2: Caption
**Screen**: `UploadContentScreen`
**Actions**:
- Add title/description
- Add hashtags
- Select category (if not pre-selected)
- Preview with caption

**Output**: caption, hashtags

### Step 3: Music Selection
**Screen**: `MusicSelectionScreen`
**Actions**:
- Browse music library
- Search for music
- Preview with music
- Skip if desired

**Output**: backgroundMusicId, selectedMusic

### Step 4: Thumbnail Selection
**Screen**: `ThumbnailSelectorScreen`
**Actions**:
- Select frame from video
- Auto-generate thumbnail
- Manual selection
- Skip for photos (auto-skipped)

**Output**: thumbnailPath

### Step 5: Preview
**Screen**: `PreviewScreen`
**Actions**:
- Review complete content
- See video with music
- See caption and hashtags
- Edit if needed (back button)
- Confirm before upload

**Output**: Validation of all data

### Step 6: Upload
**Screen**: `PreviewScreen` (upload section)
**Actions**:
- Submit to SYT competition
- Show upload progress
- Display success/error
- Return to previous screen

**Output**: Submission confirmation

## Data Flow Through Steps

```
Step 1: Record
├── mediaPath: "/path/to/video.mp4"
├── isVideo: true
└── duration: "00:45"

Step 2: Caption
├── caption: "My amazing dance performance"
├── hashtags: ["dance", "showoff", "talent"]
└── category: "Dance"

Step 3: Music
├── backgroundMusicId: "507f1f77bcf86cd799439012"
├── selectedMusic: {name, artist, duration}
└── audioUrl: "https://..."

Step 4: Thumbnail
├── thumbnailPath: "/path/to/thumbnail.jpg"
└── timestamp: 15000 (ms)

Step 5: Preview
├── All above data combined
├── Validation passed
└── Ready for upload

Step 6: Upload
├── POST /api/syt/entries
├── FormData with all fields
├── Upload progress: 0-100%
└── Success response
```

## Navigation & Back Button

### Forward Navigation
```
Step 1 → Step 2 → Step 3 → Step 4 → Step 5 → Upload → Return
```

### Back Navigation (at any step)
```
Step 2 ← Step 1 (back button)
Step 3 ← Step 2 (back button)
Step 4 ← Step 3 (back button)
Step 5 ← Step 4 (back button)
Step 1 ← Exit (back button at step 1)
```

### Data Preservation
- All data is preserved when going back
- Users can edit previous steps
- No data loss on back navigation

## Special Cases

### Photo Upload
```
Step 1: Take photo
Step 2: Add caption
Step 3: Select music
Step 4: SKIPPED (no thumbnail for photos)
Step 5: Preview
Step 6: Upload
```

### No Music Selected
```
Step 1: Record video
Step 2: Add caption
Step 3: Skip music
Step 4: Select thumbnail
Step 5: Preview (without music)
Step 6: Upload
```

### Category Pre-Selection (SYT Reel Screen)
```
User viewing "Dance" category reel
    ↓
Clicks "Show off"
    ↓
ContentCreationFlowScreen receives sytCategory: "Dance"
    ↓
Step 2 shows "Dance" pre-selected
    ↓
User can change if desired
```

## State Management

### ContentCreationFlow Model
```dart
class ContentCreationFlow {
  // Step 1
  String? mediaPath;
  bool isVideo = false;
  
  // Step 2
  String caption = '';
  List<String> hashtags = [];
  
  // Step 3
  String? backgroundMusicId;
  Map<String, dynamic>? selectedMusic;
  
  // Step 4
  String? thumbnailPath;
  
  // Metadata
  String selectedPath = 'SYT';
  String? sytCategory;
}
```

### State Persistence
- Data persists across step navigation
- Data is cleared on upload success
- Data is cleared on exit
- No data loss on back navigation

## Error Handling

### Validation Errors
```
Step 1: Recording failed
  → Show error message
  → Allow retry

Step 2: Caption empty
  → Show validation error
  → Prevent next step

Step 3: Music load failed
  → Show error
  → Allow skip

Step 4: Thumbnail generation failed
  → Show error
  → Allow retry

Step 5: Preview validation failed
  → Show error
  → Allow back to edit

Step 6: Upload failed
  → Show error message
  → Allow retry
```

### Network Errors
- Graceful error handling
- Retry mechanism
- User-friendly messages
- No data loss

## Performance Optimizations

### Caching
- Video cache manager for thumbnails
- Music preview caching
- Image caching for thumbnails

### Memory Management
- Dispose controllers properly
- Clean up resources on exit
- Prevent memory leaks

### Loading States
- Show progress indicators
- Disable buttons during upload
- Show upload progress

## Accessibility

### Navigation
- Clear step indicators
- Back button always available
- Progress tracking

### User Feedback
- Success messages
- Error messages
- Loading indicators
- Progress bars

## Testing Scenarios

### Scenario 1: Complete Flow
1. Record video
2. Add caption
3. Select music
4. Choose thumbnail
5. Preview
6. Upload
✅ Entry appears in feed

### Scenario 2: Photo Upload
1. Take photo
2. Add caption
3. Select music
4. Skip thumbnail
5. Preview
6. Upload
✅ Entry appears in feed

### Scenario 3: Back Navigation
1. Record video
2. Add caption
3. Go back to step 1
4. Re-record
5. Continue through flow
✅ New recording used

### Scenario 4: Category Pre-Selection
1. View "Dance" reel
2. Click "Show off"
3. Category is "Dance"
4. Continue through flow
✅ Entry submitted in Dance category

### Scenario 5: Skip Music
1. Record video
2. Add caption
3. Skip music
4. Choose thumbnail
5. Preview (no music)
6. Upload
✅ Entry without music

## Files Involved

### Core Flow
- `apps/lib/content_creation_flow_screen.dart` - Main flow controller
- `apps/lib/models/content_creation_flow.dart` - Data model

### Step Screens
- `apps/lib/camera_screen.dart` - Step 1: Recording
- `apps/lib/upload_content_screen.dart` - Step 2: Caption
- `apps/lib/music_selection_screen.dart` - Step 3: Music
- `apps/lib/thumbnail_selector_screen.dart` - Step 4: Thumbnail
- `apps/lib/preview_screen.dart` - Step 5 & 6: Preview & Upload

### Entry Points
- `apps/lib/path_selection_screen.dart` - Path selection
- `apps/lib/talent_screen.dart` - Talent screen
- `apps/lib/syt_reel_screen.dart` - SYT reel screen

## API Endpoints Used

### Upload Entry
```
POST /api/syt/entries
Content-Type: multipart/form-data

Fields:
- video/photo file
- caption
- hashtags
- category
- backgroundMusicId (optional)
- thumbnailFile (optional)
```

### Get Music
```
GET /api/music/:id
Response: {audioUrl, name, artist, duration}
```

### Check Submission Status
```
GET /api/syt/check-weekly-submission
Response: {hasSubmitted: boolean}
```

## Summary

The unified SYT flow provides:
- ✅ Consistent user experience
- ✅ Complete submission process
- ✅ Professional quality control
- ✅ Flexible entry points
- ✅ Robust error handling
- ✅ Smooth navigation
- ✅ Data preservation
- ✅ Category pre-selection
- ✅ Music integration
- ✅ Thumbnail management

All entry points now lead to the same professional 6-step flow, ensuring users have a complete and consistent experience regardless of where they start their SYT submission.
