# Google OAuth Profile Picture Fix

## Problem
When existing users logged in with Google OAuth, their profile picture was being overwritten with their Gmail profile photo, even if they had already set a custom profile picture.

## Root Cause
The `googleAuth` function had logic that updated the profile picture every time a user logged in with Google:

```javascript
// OLD CODE - WRONG
if (googleUser.picture && googleUser.picture !== user.profilePicture) {
  user.profilePicture = googleUser.picture;  // ❌ Overwrites existing photo
  await user.save();
}
```

This meant:
- User sets custom profile picture ✅
- User logs in with Google 🔐
- Profile picture gets replaced with Gmail photo ❌

## Solution

### 1. Removed Auto-Update for Existing Users
```javascript
// NEW CODE - CORRECT
} else {
  console.log('✅ Existing Google user found:', user.username);
  
  // Don't update profile picture for existing users
  // Users should manage their profile picture through profile settings
  console.log('ℹ️  Keeping existing profile picture');
}
```

### 2. Only Set Picture on First Link
When linking a Google account to an existing email account, only set the picture if the user doesn't have one:

```javascript
if (user) {
  // Link Google account to existing user
  user.googleId = googleUser.sub || googleUser.id;
  user.isEmailVerified = googleUser.emailVerified || googleUser.verifiedEmail;
  
  // Only set profile picture if user doesn't have one yet
  if (googleUser.picture && !user.profilePicture) {
    console.log('ℹ️  Setting initial profile picture from Google');
    user.profilePicture = googleUser.picture;
  } else {
    console.log('ℹ️  Keeping existing profile picture');
  }
  await user.save();
}
```

## Behavior After Fix

### Scenario 1: New User Signs Up with Google
```
1. User signs up with Google
2. Profile picture set from Gmail ✅
3. User can change it later in settings
```

### Scenario 2: Existing User Links Google Account
```
1. User has email account with custom photo
2. User links Google account
3. If no photo: Set Gmail photo ✅
4. If has photo: Keep existing photo ✅
```

### Scenario 3: Existing Google User Logs In
```
1. User already has Google account linked
2. User logs in with Google
3. Profile picture stays the same ✅
4. No overwriting happens ✅
```

### Scenario 4: User Changes Profile Picture
```
1. User sets custom profile picture
2. User logs in with Google later
3. Custom picture is preserved ✅
4. Gmail photo is ignored ✅
```

## Code Flow

### First Time Google Sign Up:
```javascript
// Create new user
user = await User.create({
  username: username.toLowerCase(),
  displayName: googleUser.name,
  email: googleUser.email,
  googleId: googleUser.sub,
  profilePicture: googleUser.picture,  // ✅ Set initial picture
  // ...
});
```

### Linking Google to Existing Account:
```javascript
if (user) {
  user.googleId = googleUser.sub;
  
  // Only if no picture exists
  if (googleUser.picture && !user.profilePicture) {
    user.profilePicture = googleUser.picture;  // ✅ Set only if empty
  }
  // Otherwise keep existing picture
}
```

### Existing Google User Login:
```javascript
} else {
  console.log('✅ Existing Google user found');
  // Don't touch profile picture at all ✅
}
```

## Profile Picture Management

### Where Users Can Change Profile Picture:
1. **Profile Settings Screen** - Upload custom photo
2. **Account Setup** - Set initial photo during onboarding
3. **Edit Profile** - Change photo anytime

### Where Profile Picture Should NOT Change:
1. ❌ Google OAuth login (existing users)
2. ❌ Phone login
3. ❌ Email login
4. ❌ Any authentication method

### Where Profile Picture CAN Be Set:
1. ✅ First time Google sign up
2. ✅ Profile settings upload
3. ✅ Account setup flow
4. ✅ Linking Google (if no picture exists)

## Testing

### Test Case 1: New Google User
1. Sign up with Google
2. Verify Gmail photo is used
3. Change photo in settings
4. Log out and log in with Google
5. Verify custom photo is preserved ✅

### Test Case 2: Existing User Links Google
1. Create account with email
2. Set custom profile picture
3. Link Google account
4. Verify custom picture is preserved ✅

### Test Case 3: Existing User Without Photo
1. Create account with email (no photo)
2. Link Google account
3. Verify Gmail photo is set ✅

### Test Case 4: Multiple Logins
1. User has custom profile picture
2. Log in with Google multiple times
3. Verify picture never changes ✅

## Files Modified

- `server/controllers/authController.js` - Fixed `googleAuth` function

## Functions Updated

### googleAuth (Main Fix)
- Removed auto-update of profile picture for existing users
- Added logging for clarity

### googleCallback (Already Correct)
- Already had correct logic
- Only sets picture if user doesn't have one

## Benefits

- ✅ User profile pictures are preserved
- ✅ Users have control over their photos
- ✅ No unexpected photo changes
- ✅ Better user experience
- ✅ Consistent behavior

## Related Code

### Profile Picture Update Endpoint:
```javascript
// Only place where profile picture should be updated
PUT /api/users/profile
{
  profilePicture: "new_photo_url"
}
```

### Profile Picture Sources:
1. User upload (primary)
2. Google photo (initial only)
3. Default avatar (fallback)

## Status

✅ Auto-update removed for existing users
✅ Initial picture set only when empty
✅ User control preserved
✅ Logging added for debugging
✅ Ready to test

## Next Steps

1. Restart the server
2. Test with existing user account
3. Log in with Google OAuth
4. Verify profile picture doesn't change
5. Test new user sign up with Google
6. Verify Gmail photo is used initially
