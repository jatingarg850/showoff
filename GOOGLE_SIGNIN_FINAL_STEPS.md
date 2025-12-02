# Google Sign-In Final Configuration Steps

## ✅ What You Just Did
Created OAuth 2.0 Client ID in Google Cloud Console with:
- Package name: `com.showofflife.app`
- SHA-1: `0F:EC:A5:BE:CF:83:10:37:1B:4E:D2:71:7A:55:C8:E5:70:62:0B:47`

## 📋 Remaining Steps

### 1. Verify Firebase Console
Go to: https://console.firebase.google.com/project/showofflife-21/settings/general

Check if you have an Android app with:
- Package name: `com.showofflife.app`
- SHA-1 fingerprint: `0F:EC:A5:BE:CF:83:10:37:1B:4E:D2:71:7A:55:C8:E5:70:62:0B:47`

**If NOT, add it:**
1. Click "Add app" → Android
2. Package name: `com.showofflife.app`
3. Add SHA-1 fingerprint
4. Download new `google-services.json`
5. Replace in `apps/android/app/google-services.json`

### 2. Wait for Propagation
Google's changes can take 5-10 minutes to propagate.

### 3. Rebuild and Test
```bash
cd apps
flutter clean
flutter build appbundle --release
```

### 4. Test on Device
1. Uninstall old app completely
2. Install new AAB
3. Try Google Sign-In
4. Should work now!

## 🔍 Verification Checklist

- [ ] OAuth client created in Google Cloud Console
- [ ] Package name is `com.showofflife.app`
- [ ] SHA-1 fingerprint matches keystore
- [ ] Firebase has Android app with same package name
- [ ] Firebase has same SHA-1 fingerprint
- [ ] Downloaded latest google-services.json
- [ ] Replaced in project
- [ ] Rebuilt app
- [ ] Tested on device

## 🐛 If Still Not Working

1. **Check OAuth Consent Screen:**
   - Go to Google Cloud Console → OAuth consent screen
   - Make sure it's configured and published

2. **Check API Enabled:**
   - Go to APIs & Services → Library
   - Search for "Google Sign-In API"
   - Make sure it's enabled

3. **Check google-services.json:**
   - Open `apps/android/app/google-services.json`
   - Verify package_name is `com.showofflife.app`
   - Verify oauth_client section has entries

4. **Clear App Data:**
   - Uninstall app completely
   - Clear Google Play Services cache
   - Reinstall and test

## 📱 Expected Behavior

After all steps:
- Google Sign-In button should open Google account picker
- Select account
- Sign in successfully
- No error code 10

## ⏰ Timeline

- OAuth client creation: Immediate
- Firebase changes: 5-10 minutes
- Full propagation: Up to 1 hour (usually faster)

---

**Current Status:** OAuth client created ✅  
**Next:** Verify Firebase configuration and rebuild app
