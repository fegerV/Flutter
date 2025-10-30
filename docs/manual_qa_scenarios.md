# Manual QA Scenarios - Onboarding and Notifications

## Test Environment Setup
1. Install the app on a physical device (preferred) or emulator
2. Ensure device has camera and notification permissions available
3. Test in both portrait and landscape orientations
4. Test with both English and Russian languages

## 1. Onboarding Flow Tests

### 1.1 First Launch Onboarding
**Steps:**
1. Clear app data or install fresh
2. Launch the app
3. Verify splash screen appears (3 seconds)
4. Verify AR onboarding starts automatically

**Expected Results:**
- Splash screen displays app logo and loading indicator
- AR onboarding page appears with welcome screen
- Page indicator shows first page (1/5)
- Navigation controls work correctly

### 1.2 Onboarding Content Validation (English)
**Steps:**
1. Go through onboarding flow in English
2. Verify each screen content

**Screen 1 - Welcome:**
- Title: "Welcome to AR Experience"
- Description: "Discover the magic of augmented reality right on your device"
- AR Features list displays 4 items:
  - "Place 3D objects in your space"
  - "Interactive animations and effects"
  - "Share your AR experiences"
  - "Discover new content daily"

**Screen 2 - Camera Permissions:**
- Title: "Permissions Required"
- Description: "We need camera access to bring AR experiences to life"
- "Grant Camera Permission" button visible and functional

**Screen 3 - Notification Permissions:**
- Title: "Notifications"
- Permission rationale displayed
- "Grant Notification Permission" button visible and functional

**Screen 4 - Safety Tips:**
- Title: "Safety First"
- Description: "Be aware of your surroundings while using AR features"
- Safety tips section with 4 items:
  - "Always be aware of your surroundings"
  - "Avoid using AR while moving or driving"
  - "Take regular breaks to prevent eye strain"
  - "Keep your device at a comfortable distance"

**Screen 5 - Get Started:**
- Title: "Start Your AR Journey"
- Description: "Ready to explore augmented reality?"
- "Finish" button to complete onboarding

### 1.3 Onboarding Content Validation (Russian)
**Steps:**
1. Change language to Russian in settings
2. Replay onboarding
3. Verify all text is properly translated

**Expected Results:**
- All titles and descriptions in Russian
- No English text visible
- Layout properly adjusted for Russian text length

### 1.4 Permission Handling
**Steps:**
1. Navigate to camera permission screen
2. Click "Grant Camera Permission"
3. Test both "Allow" and "Deny" scenarios
4. Navigate to notification permission screen
5. Test both "Allow" and "Deny" scenarios

**Expected Results:**
- Permission dialog appears when clicking grant buttons
- "Allow" proceeds to next screen
- "Deny" shows confirmation dialog with option to open settings
- Settings open correctly when requested

### 1.5 Navigation Controls
**Steps:**
1. Test navigation through all screens
2. Verify "Next" button on screens 1-4
3. Verify "Finish" button on screen 5
4. Verify "Skip" button appears on screens 2-5
5. Test page indicator functionality

**Expected Results:**
- Navigation buttons work correctly
- Page indicators update accurately
- Can navigate forward and backward
- Can skip to end if desired

### 1.6 Responsive Design Tests
**Portrait Mode:**
- Content stacked vertically
- Images/icons sized appropriately
- Text readable without horizontal scrolling

**Landscape Mode:**
- Content rearranged for horizontal layout
- Navigation controls on the right side
- No content overflow
- Touch targets remain accessible

## 2. Notification Settings Tests

### 2.1 Settings Navigation
**Steps:**
1. Complete onboarding
2. Navigate to Settings from main navigation
3. Verify "Notification Settings" section exists
4. Verify "Onboarding" section exists

**Expected Results:**
- Both sections visible and properly labeled
- Icons display correctly
- No layout issues

### 2.2 Notification Toggles
**Steps:**
1. Navigate to Settings > Notification Settings
2. Test each toggle:
   - "Enable Notifications"
   - "New Animations"
   - "AR Updates"
3. Toggle each on and off
4. Restart app and verify settings persist

**Expected Results:**
- All toggles functional
- Visual feedback when toggling
- Settings saved and restored correctly
- Default state is "enabled" for all

### 2.3 Onboarding Settings
**Steps:**
1. Navigate to Settings > Onboarding
2. Test "Replay Onboarding"
3. Test "Reset Onboarding"

**Expected Results:**
- "Replay Onboarding" opens onboarding flow immediately
- "Reset Onboarding" shows confirmation dialog
- After reset, onboarding shows on next app launch
- Confirmation messages appear appropriately

## 3. Push Notification Tests

### 3.1 Notification Reception
**Prerequisites:**
- App must be connected to Firebase
- Device must have internet connection
- Notification permissions granted

**Steps:**
1. Send test notification from Firebase console
2. Verify notification appears when app is in background
3. Verify notification appears when app is closed
4. Verify in-app notification when app is in foreground

**Expected Results:**
- Notifications received in all app states
- Notification content displays correctly
- Tapping notification opens app to correct screen

### 3.2 Notification Content Types
**Test Scenarios:**
1. New Animation Notification
   - Title: "New AR Animation Available!"
   - Body: "Check out the latest animation in the app"
   - Action: Opens media page with specific animation

2. AR Update Notification
   - Title: "AR Features Updated"
   - Body: "Discover new improvements and features"
   - Action: Opens AR page

### 3.3 Deep Link Tests
**Test Scenarios:**
1. Click deep link: `app://ar`
2. Click deep link: `app://media?animation=123`
3. Click deep link: `app://settings`
4. Click deep link: `app://home`
5. Test with invalid deep link

**Expected Results:**
- Valid links navigate to correct screens
- Invalid links show error message
- App opens correctly from closed state
- Parameters passed correctly (e.g., animation ID)

## 4. Localization Tests

### 4.1 Language Switching
**Steps:**
1. Switch between English and Russian
2. Verify all UI elements update
3. Check onboarding flow in both languages
4. Check settings in both languages

**Expected Results:**
- Immediate language change
- No mixed languages visible
- All text fits properly in layout
- No truncation or overflow

### 4.2 RTL/LTR Support
**Steps:**
1. Test with Arabic or Hebrew if supported
2. Verify layout direction changes
3. Check text alignment

**Expected Results:**
- Proper text direction
- Icons and controls positioned correctly
- No layout breaking

## 5. Edge Cases and Error Handling

### 5.1 Permission Denied Scenarios
**Steps:**
1. Deny camera permission permanently
2. Deny notification permission permanently
3. Try to use AR features without permissions

**Expected Results:**
- Clear error messages
- Options to open settings
- Graceful degradation of features

### 5.2 Network Connectivity
**Steps:**
1. Test with no internet connection
2. Test with poor connection
3. Test during notification reception

**Expected Results:**
- App functions offline for core features
- Clear messaging for network-dependent features
- No crashes or hangs

### 5.3 Memory and Performance
**Steps:**
1. Navigate through onboarding multiple times
2. Toggle settings rapidly
3. Test with low memory conditions

**Expected Results:**
- No memory leaks
- Smooth animations
- Responsive UI

## 6. Accessibility Tests

### 6.1 Screen Reader Support
**Steps:**
1. Enable TalkBack/VoiceOver
2. Navigate through onboarding
3. Test settings toggles
4. Test notifications

**Expected Results:**
- All elements have proper labels
- Logical reading order
- Navigation works with screen reader

### 6.2 Touch Target Sizes
**Steps:**
1. Measure touch targets
2. Test with different screen sizes
3. Test with accessibility settings enabled

**Expected Results:**
- Minimum 44dp touch targets
- Adequate spacing between elements
- No overlapping touch areas

## 7. Device Compatibility

### 7.1 Screen Sizes
**Test on:**
- Small phone (e.g., iPhone SE)
- Large phone (e.g., iPhone Pro Max)
- Tablet (if supported)
- Various Android devices

### 7.2 OS Versions
**Test on:**
- iOS 14+
- Android 8+ (API 26+)
- Latest OS versions

## 8. Regression Tests

### 8.1 Existing Functionality
**Steps:**
1. Verify existing AR features still work
2. Check media gallery functionality
3. Test QR scanner
4. Verify cache management

**Expected Results:**
- All existing features work as before
- No breaking changes introduced
- Performance maintained or improved

## Test Reporting

For each test case, document:
- ✅ Pass / ❌ Fail
- Device and OS version
- App version
- Steps to reproduce (if failed)
- Screenshots/videos (if applicable)
- Bug severity and priority

## Automated Tests Complement

These manual tests complement the automated unit tests:
- `onboarding_localization_test.dart`
- `notification_flow_test.dart`

Run automated tests first, then proceed with manual testing for UI/UX validation.