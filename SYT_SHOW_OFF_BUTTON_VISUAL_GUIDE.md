# SYT "Show off" Button - Visual & Flow Guide

## Button Location & Appearance

### Right-Side Action Buttons Stack (Top to Bottom)
```
┌─────────────────────────────────────┐
│  SYT Reel Screen                    │
│                                     │
│                          ┌────────┐ │
│                          │  ❤️    │ │  Like
│                          │  123   │ │
│                          └────────┘ │
│                                     │
│                          ┌────────┐ │
│                          │  🗳️    │ │  Vote
│                          │  45    │ │
│                          │ VOTE   │ │
│                          └────────┘ │
│                                     │
│                          ┌────────┐ │
│                          │  💬    │ │  Comment
│                          │  12    │ │
│                          └────────┘ │
│                                     │
│                          ┌────────┐ │
│                          │  🔖    │ │  Bookmark
│                          │  8     │ │
│                          └────────┘ │
│                                     │
│                          ┌────────┐ │
│                          │  📤    │ │  Share
│                          │  5     │ │
│                          └────────┘ │
│                                     │
│                          ┌────────┐ │
│                          │  🎁    │ │  Gift
│                          └────────┘ │
│                                     │
│                          ┌────────┐ │
│                          │  ⊕     │ │  Show off ← NEW!
│                          │ Show   │ │
│                          │  off   │ │
│                          └────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## User Interaction Flow

### Step 1: User Views SYT Reel
```
User scrolls through SYT competition entries
↓
Sees "Show off" button at bottom of action buttons
```

### Step 2: User Clicks "Show off" Button
```
Click "Show off" button
↓
Current video pauses
Current music stops
↓
Navigate to ContentCreationFlowScreen
```

### Step 3: Unified Content Creation Flow (6 Steps)
```
┌─────────────────────────────────────────────────┐
│ Step 1: Record                                  │
│ - Record video or take photo                    │
│ - Camera screen with recording controls         │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Step 2: Caption                                 │
│ - Add title/description                         │
│ - Add hashtags                                  │
│ - Category pre-selected from reel               │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Step 3: Music Selection                         │
│ - Choose background music (optional)            │
│ - Browse music library                          │
│ - Preview with music                            │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Step 4: Thumbnail (Videos Only)                 │
│ - Select frame from video                       │
│ - Auto-generate or manual selection             │
│ - Skip for photos                               │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Step 5: Preview                                 │
│ - Review complete content                       │
│ - Edit if needed (back button)                  │
│ - Confirm before upload                         │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Step 6: Upload                                  │
│ - Submit to SYT competition                     │
│ - Show upload progress                          │
│ - Success confirmation                          │
└─────────────────────────────────────────────────┘
```

### Step 4: Return to SYT Reel Screen
```
Upload completes
↓
Navigation pops back to SYT reel screen
↓
Video resumes playing
Music resumes playing
↓
User can continue viewing other entries
```

## Key Features

### 1. Pre-Selected Category
- Category from current reel is passed to flow
- User doesn't need to select category again
- Streamlines the submission process

### 2. Media Lifecycle Management
- Video pauses before navigation
- Music stops before navigation
- Both resume when user returns
- Prevents audio conflicts

### 3. Unified Flow Benefits
- Same 6-step flow as regular Reels
- Consistent user experience
- All features available (music, captions, hashtags)
- Professional submission process

### 4. Seamless Navigation
- Uses `.then()` callback to resume media
- Checks `mounted` before resuming
- Handles back button gracefully
- No memory leaks or orphaned resources

## Button Styling

### Visual Design
- **Icon**: `Icons.add_circle_outline` (plus sign in circle)
- **Background**: Purple with 30% opacity
- **Text**: "Show" on first line, "off" on second line
- **Colors**: White text on transparent background
- **Size**: Matches other action buttons (28px icon)

### Animations
- Fade-in animation on page load
- Scale animation on tap
- Smooth transitions between states

## Code Implementation

### Navigation Code
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ContentCreationFlowScreen(
      selectedPath: 'SYT',
      sytCategory: reel['category'],
    ),
  ),
).then((_) {
  if (mounted) {
    resumeVideo();
  }
});
```

### Key Parameters
- `selectedPath: 'SYT'` - Routes to SYT upload flow
- `sytCategory: reel['category']` - Pre-selects category
- `.then()` callback - Resumes media on return

## Testing Scenarios

### Scenario 1: Basic Flow
1. View SYT reel
2. Click "Show off"
3. Record video
4. Add caption
5. Select music
6. Choose thumbnail
7. Preview
8. Upload
9. Return to reel
10. Video resumes

### Scenario 2: Photo Upload
1. View SYT reel
2. Click "Show off"
3. Take photo
4. Add caption
5. Select music
6. Skip thumbnail (auto-skipped for photos)
7. Preview
8. Upload
9. Return to reel

### Scenario 3: Back Navigation
1. View SYT reel
2. Click "Show off"
3. Record video
4. Click back button
5. Return to reel
6. Video resumes

### Scenario 4: Multiple Submissions
1. View SYT reel
2. Click "Show off"
3. Submit entry
4. Return to reel
5. Click "Show off" again
6. Submit another entry
7. Both entries appear in feed

## Success Criteria
- ✅ Button appears in action buttons
- ✅ Button navigates to unified flow
- ✅ Category is pre-selected
- ✅ Video pauses before navigation
- ✅ Video resumes after return
- ✅ Music resumes after return
- ✅ Full upload flow works
- ✅ Submitted entries appear in feed
- ✅ No crashes or errors
- ✅ Smooth animations and transitions
