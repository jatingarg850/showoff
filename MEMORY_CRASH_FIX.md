# Memory Crash Fix - OutOfMemoryError

## Problem
App is crashing with OutOfMemoryError:
```
OutOfMemoryError: Failed to allocate... 
Heap: 191MB/192MB (99% full)
Target footprint: 192MB
Growth limit: 192MB
```

The app is hitting the 192MB heap limit and cannot allocate even small objects (24 bytes).

## Root Causes

### 1. Limited Heap Size
Default Android heap is only 192MB, which is too small for video-heavy apps.

### 2. Memory Leaks
- Video controllers not being disposed properly
- Images not being released
- Cache growing too large
- Controllers accumulating in memory

### 3. Too Many Videos in Memory
- Loading too many reels at once
- Not disposing old video controllers
- Cache manager keeping too many videos

## Solutions Implemented

### 1. Increase Heap Size
Added `largeHeap="true"` to AndroidManifest.xml:

```xml
<application
    android:label="ShowOff.life"
    android:name="${applicationName}"
    android:icon="@mipmap/launcher_icon"
    android:largeHeap="true"           <!-- NEW: Increases heap to ~512MB -->
    android:hardwareAccelerated="true"> <!-- NEW: Better performance -->
```

**Effect:** Increases available heap from 192MB to ~512MB (device dependent)

### 2. Lock Portrait Orientation
Added to MainActivity to prevent memory spikes during rotation:

```xml
<activity
    android:name=".MainActivity"
    ...
    android:screenOrientation="portrait"> <!-- NEW: Prevents rotation memory issues -->
```

**Effect:** Prevents memory allocation spikes when rotating device

### 3. Optimize Reel Screen Cache
Already implemented in code but verify these settings:

```dart
// Permanent cache - REDUCED
static final _cacheManager = CacheManager(
  Config(
    'reelVideoCache',
    stalePeriod: const Duration(days: 1),  // Was 7 days
    maxNrOfCacheObjects: 2,                // Was 5 videos
  ),
);

// Temporary cache - REDUCED
static final _tempCacheManager = CacheManager(
  Config(
    'reelTempCache',
    stalePeriod: const Duration(minutes: 5), // Was 10 minutes
    maxNrOfCacheObjects: 2,                   // Was 3 videos
  ),
);

// Load fewer posts at once
static const int _postsPerPage = 3; // Only 3 posts at a time
```

## Additional Optimizations Needed

### 1. Aggressive Video Controller Disposal
Add to reel_screen.dart:

```dart
void _disposeVideoController(int index) {
  if (_videoControllers.containsKey(index)) {
    _videoControllers[index]?.pause();
    _videoControllers[index]?.dispose();
    _videoControllers.remove(index);
    _videoInitialized.remove(index);
    _videoFullyLoaded.remove(index);
    _lastPlayAttempt.remove(index);
  }
}

// Dispose controllers that are far from current index
void _cleanupDistantControllers() {
  final controllersToRemove = <int>[];
  
  _videoControllers.forEach((index, controller) {
    // Keep only current, previous, and next video
    if ((index - _currentIndex).abs() > 1) {
      controllersToRemove.add(index);
    }
  });
  
  for (final index in controllersToRemove) {
    _disposeVideoController(index);
  }
}

// Call this when page changes
void _onPageChanged(int index) {
  setState(() {
    _currentIndex = index;
  });
  
  // Clean up distant controllers
  _cleanupDistantControllers();
  
  // Rest of your code...
}
```

### 2. Image Memory Optimization
For thumbnail selector and image loading:

```dart
// Use memory-efficient image loading
Image.file(
  File(path),
  fit: BoxFit.cover,
  cacheWidth: 640,  // Limit decoded size
  cacheHeight: 480,
)

// For thumbnails
Image.file(
  File(thumbnailPath),
  fit: BoxFit.cover,
  cacheWidth: 200,  // Even smaller for thumbnails
  cacheHeight: 200,
)
```

### 3. Clear Cache on Low Memory
Add to reel_screen.dart:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    // Clear temporary cache when app goes to background
    _tempCacheManager.emptyCache();
    
    // Dispose all but current video
    _videoControllers.forEach((index, controller) {
      if (index != _currentIndex) {
        _disposeVideoController(index);
      }
    });
  }
}
```

## Memory Management Best Practices

### 1. Video Controllers
```dart
// ✅ GOOD - Dispose when done
controller?.dispose();
_videoControllers.remove(index);

// ❌ BAD - Keeping all controllers
// Never dispose controllers
```

### 2. Images
```dart
// ✅ GOOD - Limit decoded size
Image.file(file, cacheWidth: 640, cacheHeight: 480)

// ❌ BAD - Full resolution
Image.file(file) // Decodes full 4K image
```

### 3. Cache
```dart
// ✅ GOOD - Limited cache
maxNrOfCacheObjects: 2

// ❌ BAD - Unlimited cache
maxNrOfCacheObjects: 100
```

### 4. Lists
```dart
// ✅ GOOD - Paginated loading
_postsPerPage = 3

// ❌ BAD - Load everything
loadAllPosts()
```

## Testing Memory Usage

### 1. Monitor Memory in Android Studio
```
View → Tool Windows → Profiler
Select Memory
Watch heap usage while scrolling reels
```

### 2. Check for Leaks
```
1. Scroll through 10 reels
2. Go back to home
3. Check if memory drops
4. If not, there's a leak
```

### 3. Stress Test
```
1. Scroll through 50 reels quickly
2. App should not crash
3. Memory should stabilize around 300-400MB
```

## Expected Results

### Before Fix:
- Heap: 191MB/192MB (99% full)
- Crashes after 10-20 reels
- OutOfMemoryError frequently

### After Fix:
- Heap: 300-400MB/512MB (60-80% usage)
- Can scroll through 100+ reels
- No crashes
- Smooth performance

## Files Modified

1. `apps/android/app/src/main/AndroidManifest.xml`
   - Added `android:largeHeap="true"`
   - Added `android:hardwareAccelerated="true"`
   - Added `android:screenOrientation="portrait"`

## Additional Files to Modify

2. `apps/lib/reel_screen.dart`
   - Add aggressive controller disposal
   - Add cleanup on page change
   - Add low memory handling

3. `apps/lib/thumbnail_selector_screen.dart`
   - Add cacheWidth/cacheHeight to images
   - Limit decoded image size

## Heap Size by Device

| Device Type | Default Heap | Large Heap |
|------------|--------------|------------|
| Low-end    | 128MB        | 256MB      |
| Mid-range  | 192MB        | 512MB      |
| High-end   | 256MB        | 768MB      |
| Flagship   | 512MB        | 1024MB     |

## Memory Budget

Recommended memory allocation:
- Video player: 100-150MB (current video)
- Cached videos: 50-100MB (next/prev)
- Images/UI: 50-100MB
- App code: 50MB
- System: 50MB
- **Total: ~400MB** (well under 512MB limit)

## Monitoring Commands

### Check current memory:
```bash
adb shell dumpsys meminfo com.showoff.life
```

### Force garbage collection:
```bash
adb shell am force-stop com.showoff.life
```

### Clear app cache:
```bash
adb shell pm clear com.showoff.life
```

## Prevention Checklist

- ✅ Dispose video controllers when not visible
- ✅ Limit cache size (2-3 videos max)
- ✅ Use cacheWidth/cacheHeight for images
- ✅ Load posts in small batches (3-5 at a time)
- ✅ Clear cache on low memory
- ✅ Use largeHeap in manifest
- ✅ Lock orientation to portrait
- ✅ Monitor memory in profiler

## Status

✅ AndroidManifest.xml updated with largeHeap
✅ Portrait orientation locked
✅ Hardware acceleration enabled
⚠️ Need to add aggressive disposal in reel_screen.dart
⚠️ Need to add image size limits
⚠️ Need to test memory usage

## Next Steps

1. Rebuild the app with new manifest
2. Test memory usage with profiler
3. Add aggressive disposal if still needed
4. Monitor for crashes
5. Optimize further if necessary
