# Content Creation Flow Restructure

## Overview
The content creation flow has been restructured to follow a sequential, step-by-step process:

**Record → Caption → Music → Thumbnail → Preview → Upload**

This provides a better user experience with clear progression and the ability to go back to previous steps.

## New Architecture

### 1. ContentCreationFlow Model
**File**: `apps/lib/models/content_creation_flow.dart`

Manages the state of the entire content creation process:
- Tracks all data through each step
- Validates progression between steps
- Provides step information (current step, step names)

```dart
ContentCreationFlow(
  selectedPath: 'reels', // or 'SYT'
  sytCategory: null,
)
```

### 2. ContentCreationFlowScreen
**File**: `apps/lib/content_creation_flow_screen.dart`

Main orchestrator screen that manages the flow:
- Uses PageView for step navigation
- Handles callbacks from each step
- Manages data passing between steps
- Provides back/next navigation

**Flow Steps**:
1. **Recording** - CameraScreen
2. **Caption** - UploadContentScreen
3. **Music Selection** - MusicSelectionScreen
4. **Thumbnail Selection** - ThumbnailSelectorScreen (videos only)
5. **Preview** - PreviewScreen
6. **Upload** - Handled in PreviewScreen

### 3. Updated Screens with Callback Support

#### CameraScreen
**New Parameters**:
- `onRecordingComplete(String mediaPath, bool isVideo)` - Called when recording/photo is done
- `onSkip()` - Called to skip to next step

**Behavior**:
- If callbacks provided → uses new flow
- If callbacks null → uses old navigation (backward compatible)

#### UploadContentScreen
**New Parameters**:
- `onCaptionComplete(String caption, List<String> hashtags)` - Called when caption is entered
- `onBack()` - Called to go back

**Features**:
- Automatically extracts hashtags from caption
- Validates caption before proceeding
- Supports both new and old flows

#### MusicSelectionScreen
**New Parameters**:
- `onMusicSelected(String? musicId, Map<String, dynamic>? music)` - Called when music is selected
- `onSkip()` - Called to skip music selection
- `onBack()` - Called to go back

**Features**:
- Can skip music selection
- Returns both music ID and full music data
- Supports both new and old flows

#### ThumbnailSelectorScreen
**New Parameters**:
- `onThumbnailSelected(String thumbnailPath)` - Called when thumbnail is selected
- `onBack()` - Called to go back

**Features**:
- Auto-generates 4 thumbnails at different timestamps
- Can upload custom thumbnail
- Supports both new and old flows

#### PreviewScreen
**New Parameters**:
- `onUploadComplete()` - Called when upload is complete
- `onBack()` - Called to go back

**Features**:
- Shows all content details before upload
- Handles upload orchestration
- Supports both new and old flows

### 4. PathSelectionScreen Updates
**Changes**:
- Now routes to `ContentCreationFlowScreen` for Show and SYT
- Daily Selfie still uses old flow (DailySelfieScreen)
- Maintains backward compatibility

## Data Flow

```
PathSelectionScreen
    ↓ (selectedPath: 'reels' or 'SYT')
ContentCreationFlowScreen
    ├─ Step 1: CameraScreen
    │   └─ onRecordingComplete(mediaPath, isVideo)
    ├─ Step 2: UploadContentScreen
    │   └─ onCaptionComplete(caption, hashtags)
    ├─ Step 3: MusicSelectionScreen
    │   └─ onMusicSelected(musicId, music)
    ├─ Step 4: ThumbnailSelectorScreen (videos only)
    │   └─ onThumbnailSelected(thumbnailPath)
    ├─ Step 5: PreviewScreen
    │   └─ onUploadComplete()
    └─ Upload & Navigation
```

## Key Features

### 1. Sequential Flow
- Users progress through steps in order
- Can go back to previous steps
- Clear indication of current step

### 2. Data Persistence
- All data stored in ContentCreationFlow model
- Data survives navigation between steps
- No data loss when going back

### 3. Backward Compatibility
- Old navigation still works if callbacks are null
- Existing code continues to function
- Gradual migration possible

### 4. Flexible Music Selection
- Music selection is optional
- Can skip and proceed without music
- Music can be selected or changed

### 5. Auto Thumbnail Generation
- Generates 4 thumbnails automatically
- User can select auto-generated or upload custom
- Skipped for photo uploads

## Usage Example

### New Flow (Recommended)
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ContentCreationFlowScreen(
      selectedPath: 'reels',
      sytCategory: null,
    ),
  ),
);
```

### Old Flow (Still Supported)
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MusicSelectionScreen(
      selectedPath: 'reels',
    ),
  ),
);
```

## Step Details

### Step 1: Recording
- Record video or take photo
- Select from gallery
- Toggle camera, flash
- Proceed to caption

### Step 2: Caption
- Enter caption/description
- Hashtags auto-extracted
- Validation required
- Proceed to music selection

### Step 3: Music Selection
- Browse approved music
- Filter by genre/mood
- Select or skip
- Proceed to thumbnail (videos) or preview (photos)

### Step 4: Thumbnail Selection (Videos Only)
- Auto-generated thumbnails shown
- Select auto-generated or upload custom
- Proceed to preview

### Step 5: Preview
- Review all content
- Show caption, music, category
- Confirm and upload
- Return to home on completion

## Files Modified

1. **New Files**:
   - `apps/lib/models/content_creation_flow.dart`
   - `apps/lib/content_creation_flow_screen.dart`

2. **Updated Files**:
   - `apps/lib/camera_screen.dart` - Added callbacks
   - `apps/lib/upload_content_screen.dart` - Added callbacks
   - `apps/lib/music_selection_screen.dart` - Added callbacks
   - `apps/lib/thumbnail_selector_screen.dart` - Added callbacks
   - `apps/lib/preview_screen.dart` - Added callbacks
   - `apps/lib/path_selection_screen.dart` - Routes to new flow

## Testing Checklist

- [ ] Record video → Caption → Music → Thumbnail → Preview → Upload
- [ ] Record photo → Caption → Music → Preview → Upload
- [ ] Skip music selection
- [ ] Go back from each step
- [ ] Upload completes successfully
- [ ] Old flow still works (backward compatibility)
- [ ] Hashtags extracted correctly
- [ ] Thumbnails generated correctly
- [ ] Music plays in preview
- [ ] SYT submission works
- [ ] Show/Reels upload works

## Future Enhancements

1. **Editing Between Steps**:
   - Allow editing caption after music selection
   - Allow changing music after thumbnail selection

2. **Draft Saving**:
   - Save draft at each step
   - Resume from draft later

3. **Step Indicators**:
   - Visual progress bar
   - Step completion indicators

4. **Validation**:
   - Real-time caption validation
   - File size warnings
   - Duration warnings for videos

5. **Analytics**:
   - Track which steps users complete
   - Identify drop-off points
   - Optimize flow based on data
