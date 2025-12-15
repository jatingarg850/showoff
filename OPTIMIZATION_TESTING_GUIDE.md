# App Reload Optimization - Testing Guide

## Quick Test Steps

### 1. Start the Server
```bash
cd server
npm start
```

### 2. Run the App
```bash
cd apps
flutter run
```

### 3. Test ProfileScreen Likes Tab
1. Navigate to Profile screen
2. Click on "Likes" tab
3. **Expected**: Instant load (should see liked posts immediately)
4. **Check**: Open browser DevTools → Network tab
   - Should see only 1 `getFeed` API call
   - Should NOT see 100+ `getPostStats` calls

### 4. Test ReelScreen
1. Navigate to Reel screen
2. Scroll through reels
3. **Expected**: Smooth playback with stats visible
4. **Check**: Open browser DevTools → Network tab
   - Should see `getFeed` calls with stats included
   - Should see minimal `getPostStats` calls (only for posts without stats)

### 5. Monitor Performance
**Before Optimization:**
- App reload: 3-5 seconds
- API calls: 50+
- Network requests: ~2-3 MB

**After Optimization:**
- App reload: 0.5-1 second
- API calls: ~10
- Network requests: ~200-300 KB

## Server Logs to Check

When you start the server, you should see:
```
✅ Loaded 20 posts (lazy loading)
✅ Using cached feed data (20 posts)
```

NOT:
```
Get stats: {postId: ..., userId: ...}  (repeated 100 times)
```

## API Calls Comparison

### Before (105 calls for Likes tab):
```
GET /api/posts/feed?page=1&limit=20
GET /api/posts/feed?page=2&limit=20
GET /api/posts/feed?page=3&limit=20
GET /api/posts/feed?page=4&limit=20
GET /api/posts/feed?page=5&limit=20
GET /api/posts/{id1}/stats
GET /api/posts/{id2}/stats
... (100 more stats calls)
```

### After (1 call for Likes tab):
```
GET /api/posts/feed?page=1&limit=20
(Response includes isLiked, isBookmarked, stats for all 20 posts)
```

## Troubleshooting

### Issue: Stats not showing in ReelScreen
**Solution**: Make sure the backend changes are deployed. Stats should be in the feed response.

### Issue: Liked posts not filtering correctly
**Solution**: Check that `isLiked` field is present in feed response. Log the response to verify.

### Issue: Still seeing slow load times
**Solution**: 
1. Clear app cache: `flutter clean`
2. Rebuild: `flutter pub get && flutter run`
3. Check network tab for any remaining unnecessary API calls

## Performance Metrics

Use Chrome DevTools to measure:

1. **Network Tab**:
   - Filter by XHR/Fetch
   - Count total API calls
   - Check response sizes
   - Measure request times

2. **Performance Tab**:
   - Record app navigation
   - Check for long tasks
   - Measure frame rate

3. **Console**:
   - Look for optimization logs:
     - "✅ Loaded X posts (lazy loading)"
     - "✅ Using cached feed data"
     - "✅ All posts already have stats"

## Expected Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| API Calls (Likes Tab) | 105 | 1 | 99% ↓ |
| API Calls (App Reload) | 50+ | ~10 | 80% ↓ |
| Load Time | 3-5s | 0.5-1s | 80% ↓ |
| Network Bandwidth | ~2-3 MB | ~200-300 KB | 90% ↓ |
| Memory Usage | High | Low | 50% ↓ |

## Next Steps

After testing:
1. Deploy to production
2. Monitor server logs for any issues
3. Collect user feedback on performance
4. Consider additional optimizations (caching, pagination)
