# Auto Thumbnail Selector - Quick Reference

## What's New
The thumbnail selector screen now displays 4 auto-generated thumbnail options from your video (at 0ms, 1s, 2s, 3s) in a visual grid. Users can select one or choose a custom photo.

## User Flow
```
Video Selected
    ↓
ThumbnailSelectorScreen (auto-generates 4 thumbnails)
    ↓
User selects thumbnail (auto or custom)
    ↓
PreviewScreen (with selected thumbnail)
    ↓
Upload
```

## Screen Layout

### Auto Thumbnails Section
- 2x2 grid of thumbnail previews
- Each shows timestamp label (0ms, 1s, 2s, 3s)
- Tap to select, checkmark appears on selected
- Purple border on selected thumbnail

### Action Buttons
- **Use Selected Thumbnail** - Proceed with selected auto thumbnail
- **Or Choose Custom Photo** - Open gallery for custom selection

### Custom Photo Option
- Full-size preview if custom photo selected
- **Continue** button to proceed

## Key Features

✅ **Auto Generation** - 4 frames generated automatically at 0ms, 1s, 2s, 3s
✅ **Visual Selection** - See actual video frames before choosing
✅ **Custom Fallback** - Can still select custom photo from gallery
✅ **Cleanup** - Temporary files deleted after upload
✅ **Responsive** - Works on all screen sizes (scrollable)
✅ **Error Handling** - Graceful fallback if generation fails

## Files

| File | Purpose |
|------|---------|
| `apps/lib/thumbnail_selector_screen.dart` | Main UI with grid display |
| `apps/lib/services/thumbnail_service.dart` | Thumbnail generation logic |
| `apps/lib/preview_screen.dart` | Uses selected thumbnail for upload |

## Methods

### ThumbnailService
```dart
// Generate 4 thumbnails at different timestamps
generateMultipleThumbnails({
  required String videoPath,
  List<int> timeMs = const [0, 1000, 2000, 3000],
  int maxWidth = 320,
  int maxHeight = 240,
  int quality = 70,
})

// Clean up temporary files
cleanupThumbnails(List<String> thumbnailPaths)
```

## Testing

1. **Upload a video** → Should see 4 thumbnail options
2. **Select a thumbnail** → Checkmark appears
3. **Click "Use Selected Thumbnail"** → Goes to preview
4. **Or click "Choose Custom Photo"** → Opens gallery
5. **Upload** → Uses selected thumbnail

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No thumbnails showing | Check video file is valid, try again |
| Thumbnails look wrong | Video may be corrupted, try different video |
| Custom photo not working | Check gallery permissions |
| Slow generation | Normal for large videos, wait for completion |

## Integration

Already integrated into:
- ✅ Regular reel upload flow
- ✅ SYT entry upload flow
- ✅ Selfie challenge upload flow

## Performance

- Thumbnails: 320x240px, 70% quality
- Generation: ~1-2 seconds for typical video
- Storage: Temporary files cleaned up automatically
- Memory: Efficient grid rendering with lazy loading
