# Account Setup Back Button Fix

## Problem
When clicking the back button in the account setup flow (DisplayNameScreen), the app was closing instead of navigating back to the signup screen.

## Root Cause
The DisplayNameScreen is reached via `pushAndRemoveUntil` from the signup flow, which removes all previous routes. When the user presses back, there's no route to return to, causing the app to exit.

## Solution
Added `PopScope` widget to handle back button behavior with a confirmation dialog:

### Changes Made

**File: `apps/lib/account_setup/display_name_screen.dart`**

1. **Wrapped Scaffold with PopScope**
   - Prevents immediate back navigation
   - Shows confirmation dialog before exiting

2. **Added Exit Confirmation Dialog**
   - Warns user that progress will be lost
   - Provides "Cancel" and "Exit" options
   - On exit, navigates back to onboarding screen

### Code Changes

```dart
// Before
return Scaffold(
  appBar: AppBar(
    leading: IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ),
);

// After
return PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop) {
      _showExitConfirmation(context);
    }
  },
  child: Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () {
          _showExitConfirmation(context);
        },
      ),
    ),
  ),
);
```

### New Method Added

```dart
void _showExitConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Exit Account Setup?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to go back?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/onboarding',
                (route) => false,
              );
            },
            child: const Text('Exit'),
          ),
        ],
      );
    },
  );
}
```

## User Experience

### Before
- User clicks back button → App closes immediately ❌

### After
- User clicks back button → Confirmation dialog appears
- User can choose to:
  - **Cancel**: Stay in account setup
  - **Exit**: Return to onboarding screen ✅

## Testing

1. Start the app
2. Sign up with Google (or any method that leads to account setup)
3. On the DisplayNameScreen, press the back button
4. Verify confirmation dialog appears
5. Test both "Cancel" and "Exit" options

## Notes

- Other account setup screens (InterestsScreen, BioScreen, ProfilePictureScreen) don't need this fix as they can navigate back through the normal flow
- The fix only applies to DisplayNameScreen as it's the entry point after authentication
