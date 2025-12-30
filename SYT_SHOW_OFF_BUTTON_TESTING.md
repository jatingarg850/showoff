# SYT "Show off" Button - Testing Guide

## Pre-Testing Setup

### 1. Build the App
```bash
cd apps
flutter clean
flutter pub get
flutter run
```

### 2. Navigate to SYT Reel Screen
- Open the app
- Navigate to the SYT (Show Your Talent) section
- View any SYT competition entry

## Test Cases

### Test 1: Button Visibility
**Objective**: Verify the "Show off" button appears in the correct location

**Steps**:
1. Open SYT reel screen
2. Look at the right-side action buttons
3. Scroll down the action buttons if needed

**Expected Result**:
- ✅ "Show off" button appears at the bottom of action buttons
- ✅ Button has purple background with add icon
- ✅ Button shows "Show" and "off" text labels
- ✅ Button is properly aligned with other buttons

**Failure Indicators**:
- ❌ Button not visible
- ❌ Button misaligned or overlapping
- ❌ Icon or text not displaying
- ❌ Wrong colors or styling

---

### Test 2: Navigation to Flow
**Objective**: Verify clicking the button navigates to ContentCreationFlowScreen

**Steps**:
1. Open SYT reel screen
2. Click the "Show off" button
3. Observe the navigation

**Expected Result**:
- ✅ Video pauses immediately
- ✅ Music stops immediately
- ✅ Screen transitions to ContentCreationFlowScreen
- ✅ "Step 1: Record" screen appears
- ✅ Camera/recording interface is ready

**Failure Indicators**:
- ❌ Navigation doesn't occur
- ❌ Video continues playing
- ❌ Music continues playing
- ❌ Wrong screen appears
- ❌ Crash or error

---

### Test 3: Category Pre-Selection
**Objective**: Verify the category from the reel is pre-selected in the flow

**Steps**:
1. Note the category of the current SYT reel (e.g., "Singing", "Dancing")
2. Click "Show off" button
3. Navigate through the flow to the caption/upload screen
4. Check if the category matches

**Expected Result**:
- ✅ Category from reel is pre-selected
- ✅ User doesn't need to select category again
- ✅ Category appears in submission metadata

**Failure Indicators**:
- ❌ Category not pre-selected
- ❌ Wrong category selected
- ❌ Category field is empty

---

### Test 4: Video Resume on Return
**Objective**: Verify video resumes when returning from the flow

**Steps**:
1. Open SYT reel screen
2. Wait for video to start playing
3. Click "Show off" button
4. On the recording screen, click back button
5. Return to SYT reel screen

**Expected Result**:
- ✅ Video was paused before navigation
- ✅ Video resumes playing after return
- ✅ Video continues from where it was paused
- ✅ No lag or stuttering

**Failure Indicators**:
- ❌ Video doesn't resume
- ❌ Video restarts from beginning
- ❌ Video is frozen
- ❌ Crash on return

---

### Test 5: Music Resume on Return
**Objective**: Verify background music resumes when returning from the flow

**Steps**:
1. Open SYT reel screen with background music
2. Listen to the background music
3. Click "Show off" button
4. On the recording screen, click back button
5. Return to SYT reel screen

**Expected Result**:
- ✅ Music was stopped before navigation
- ✅ Music resumes playing after return
- ✅ Music volume is appropriate
- ✅ No audio conflicts

**Failure Indicators**:
- ❌ Music doesn't resume
- ❌ Music is too loud or too quiet
- ❌ Audio conflicts or distortion
- ❌ Crash on return

---

### Test 6: Complete Upload Flow
**Objective**: Verify the complete 6-step flow works correctly

**Steps**:
1. Click "Show off" button
2. **Step 1 - Record**: Record a short video (5-10 seconds)
3. **Step 2 - Caption**: Add a title and hashtags
4. **Step 3 - Music**: Select background music (or skip)
5. **Step 4 - Thumbnail**: Choose a thumbnail frame
6. **Step 5 - Preview**: Review the content
7. **Step 6 - Upload**: Submit the entry

**Expected Result**:
- ✅ All 6 steps complete without errors
- ✅ Recording works properly
- ✅ Caption is saved
- ✅ Music is selected (or skipped)
- ✅ Thumbnail is chosen
- ✅ Preview shows all content
- ✅ Upload succeeds
- ✅ Success message appears
- ✅ Returns to SYT reel screen

**Failure Indicators**:
- ❌ Any step fails or crashes
- ❌ Data is lost between steps
- ❌ Upload fails
- ❌ Error messages appear
- ❌ Doesn't return to reel screen

---

### Test 7: Photo Upload Flow
**Objective**: Verify the flow works for photo uploads (skips thumbnail)

**Steps**:
1. Click "Show off" button
2. **Step 1 - Record**: Take a photo instead of recording
3. **Step 2 - Caption**: Add a title and hashtags
4. **Step 3 - Music**: Select background music (or skip)
5. **Step 4 - Thumbnail**: Should be skipped automatically
6. **Step 5 - Preview**: Review the content
7. **Step 6 - Upload**: Submit the entry

**Expected Result**:
- ✅ Photo is captured
- ✅ Caption is added
- ✅ Music is selected (or skipped)
- ✅ Thumbnail step is skipped (not shown)
- ✅ Preview shows photo with music
- ✅ Upload succeeds
- ✅ Returns to reel screen

**Failure Indicators**:
- ❌ Thumbnail step appears for photos
- ❌ Photo upload fails
- ❌ Music doesn't play with photo
- ❌ Crash or error

---

### Test 8: Back Button Navigation
**Objective**: Verify back button works at each step

**Steps**:
1. Click "Show off" button
2. At each step (1-5), click the back button
3. Verify you return to the previous step

**Expected Result**:
- ✅ Back button appears at steps 2-5
- ✅ Back button returns to previous step
- ✅ Data is preserved when going back
- ✅ Can edit previous steps

**Failure Indicators**:
- ❌ Back button doesn't work
- ❌ Returns to wrong screen
- ❌ Data is lost
- ❌ Crash on back

---

### Test 9: Multiple Submissions
**Objective**: Verify user can submit multiple entries

**Steps**:
1. Click "Show off" button
2. Complete and upload first entry
3. Return to reel screen
4. Click "Show off" button again
5. Complete and upload second entry
6. Return to reel screen

**Expected Result**:
- ✅ First entry uploads successfully
- ✅ Returns to reel screen
- ✅ Can submit another entry
- ✅ Second entry uploads successfully
- ✅ Both entries appear in feed

**Failure Indicators**:
- ❌ Can't submit second entry
- ❌ First entry doesn't appear
- ❌ Duplicate entries
- ❌ Crash on second submission

---

### Test 10: Edge Cases

#### 10a: No Background Music
**Steps**:
1. View a reel with no background music
2. Click "Show off" button
3. Complete the flow

**Expected Result**:
- ✅ Flow works without music
- ✅ Music step can be skipped
- ✅ Upload succeeds

#### 10b: Network Interruption
**Steps**:
1. Click "Show off" button
2. During upload, disconnect network
3. Observe behavior

**Expected Result**:
- ✅ Error message appears
- ✅ Can retry upload
- ✅ No crash

#### 10c: Rapid Button Clicks
**Steps**:
1. Click "Show off" button multiple times rapidly
2. Observe behavior

**Expected Result**:
- ✅ Only one navigation occurs
- ✅ No duplicate screens
- ✅ No crash

#### 10d: Screen Rotation
**Steps**:
1. Click "Show off" button
2. Rotate device during flow
3. Complete submission

**Expected Result**:
- ✅ Flow handles rotation
- ✅ Data is preserved
- ✅ UI adjusts properly

---

## Performance Testing

### Test 11: Memory Usage
**Objective**: Verify no memory leaks

**Steps**:
1. Open SYT reel screen
2. Click "Show off" button 5 times
3. Return to reel screen each time
4. Monitor memory usage

**Expected Result**:
- ✅ Memory usage is stable
- ✅ No memory leaks
- ✅ App doesn't slow down

---

### Test 12: Load Time
**Objective**: Verify navigation is fast

**Steps**:
1. Click "Show off" button
2. Measure time to reach recording screen

**Expected Result**:
- ✅ Navigation completes in < 500ms
- ✅ No lag or stuttering
- ✅ Smooth transitions

---

## Regression Testing

### Test 13: Other Action Buttons Still Work
**Objective**: Verify other buttons aren't affected

**Steps**:
1. Test like button
2. Test vote button
3. Test comment button
4. Test bookmark button
5. Test share button
6. Test gift button

**Expected Result**:
- ✅ All buttons work as before
- ✅ No changes to functionality
- ✅ No crashes

---

## Bug Report Template

If you find an issue, please report it with:

```
**Test Case**: [Test number and name]
**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**:
[What should happen]

**Actual Result**:
[What actually happened]

**Device**: [Device model and OS version]
**App Version**: [Version number]
**Logs**: [Any error messages or logs]
```

---

## Sign-Off Checklist

- [ ] All 13 test cases passed
- [ ] No crashes or errors
- [ ] Video resumes correctly
- [ ] Music resumes correctly
- [ ] Upload flow works end-to-end
- [ ] Category pre-selection works
- [ ] Back button navigation works
- [ ] Multiple submissions work
- [ ] Other buttons still work
- [ ] Performance is acceptable
- [ ] No memory leaks
- [ ] Ready for production

---

## Notes

- Test on both Android and iOS if possible
- Test on different device sizes (phone, tablet)
- Test with different network speeds
- Test with different SYT categories
- Test with and without background music
- Test with both video and photo uploads
