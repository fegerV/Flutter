# Quick Start Guide - Onboarding and Notifications

## 🚀 Setup Instructions

### 1. Firebase Configuration
```bash
# 1. Create Firebase project
# Visit: https://console.firebase.google.com

# 2. Add Android app
# Package name: com.example.flutterArApp
# Download google-services.json

# 3. Add iOS app  
# Bundle ID: com.example.flutterArApp
# Download GoogleService-Info.plist

# 4. Update firebase_options.dart
# Replace placeholder values with actual Firebase config
```

### 2. Install Dependencies
```bash
flutter pub get
flutter pub run build_runner build
```

### 3. Platform Configuration

#### Android
- Place `google-services.json` in `android/app/`
- FCM permissions already configured in `AndroidManifest.xml`

#### iOS
- Place `GoogleService-Info.plist` in `ios/Runner/`
- Configure capabilities in Xcode (Push Notifications, Background Modes)

## 📱 Usage Guide

### First Launch Experience
1. **Splash Screen** (3 seconds)
2. **AR Onboarding** automatically starts if not completed
3. **5-Step Flow**:
   - Welcome to AR Experience
   - Camera Permissions
   - Notification Permissions  
   - Safety Tips
   - Get Started

### Accessing Settings

#### Notification Controls
1. Go to Settings app tab
2. Find "Notification Settings" section
3. Toggle:
   - Enable Notifications (master switch)
   - New Animations
   - AR Updates

#### Onboarding Controls
1. Go to Settings app tab
2. Find "Onboarding" section
3. Options:
   - **Replay Onboarding**: Start onboarding immediately
   - **Reset Onboarding**: Show on next app launch

### Testing Notifications

#### Manual Testing
```bash
# Send test notification via Firebase Console
# 1. Go to Firebase Console > Cloud Messaging
# 2. Create new campaign
# 3. Target your app
# 4. Send test notification
```

#### Deep Links
Test these URL patterns:
- `app://ar` - Opens AR page
- `app://media?animation=123` - Opens media with specific animation
- `app://settings` - Opens settings
- `app://home` - Opens home

## 🌐 Localization

### Language Switching
1. Go to Settings > Language
2. Select English or Russian
3. Changes apply immediately

### Supported Languages
- **English**: Full localization
- **Russian**: Full localization with cultural adaptation

## 📊 Testing

### Automated Tests
```bash
# Run localization tests
flutter test test/unit/onboarding_localization_test.dart

# Run notification flow tests  
flutter test test/unit/notification_flow_test.dart
```

### Manual Testing
Follow `docs/manual_qa_scenarios.md` for comprehensive testing guide.

## 🔧 Development

### Adding New Notification Types
1. Add localization strings to `app_en.arb` and `app_ru.arb`
2. Update `NotificationRepository` with new setting methods
3. Add provider in `notification_provider.dart`
4. Update settings UI in `settings_page.dart`
5. Handle new type in `notification_service.dart`

### Extending Onboarding
1. Add new `OnboardingItem` to `_onboardingItems` list
2. Add localization strings
3. Update page indicator count
4. Test responsive design

## 🐛 Troubleshooting

### Common Issues

#### Firebase Not Initialized
```
Error: [core/no-app] No Firebase App '[DEFAULT]' has been created
```
**Solution**: Check Firebase configuration in `firebase_options.dart`

#### Notifications Not Working
1. Verify Firebase project setup
2. Check device notification permissions
3. Ensure app is properly signed (release builds)
4. Test with physical device (emulator limitations)

#### Onboarding Not Showing
1. Clear app data
2. Check `onboardingCompleted` state in SharedPreferences
3. Verify router configuration

#### Deep Links Not Working
1. Verify Android manifest configuration
2. Check URL scheme registration
3. Test with actual device

### Debug Mode
Enable debug logging:
```dart
// In notification_service.dart
debugPrint('FCM Token: $token');
debugPrint('Notification received: $message');
```

## 📈 Performance

### Optimizations Implemented
- Lazy loading of onboarding content
- Efficient state management with Riverpod
- Minimal Firebase SDK usage
- Optimized animation performance

### Memory Management
- Proper disposal of controllers
- Stream-based architecture
- Efficient resource cleanup

## 🔒 Security

### Permissions
- Camera: Required for AR functionality
- Notifications: Optional, user-controlled
- Storage: Required for media caching
- Internet: Required for Firebase services

### Data Privacy
- FCM tokens stored securely
- No sensitive data in notifications
- User control over all settings

## 🎨 UI/UX

### Design Principles
- **Responsive**: Adapts to all screen sizes
- **Accessible**: Screen reader support, proper touch targets
- **Intuitive**: Clear navigation, visual feedback
- **Consistent**: Follows Material Design guidelines

### Animations
- Smooth page transitions
- Loading indicators
- Interactive feedback
- Performance optimized

## 📱 Platform Support

### Android
- ✅ All features supported
- ✅ FCM fully functional
- ✅ Deep links working
- ✅ Permissions handled

### iOS
- ✅ All features supported  
- ✅ FCM fully functional
- ✅ Deep links working
- ✅ Permissions handled

### Future Platforms
- Web: Limited AR support
- Desktop: Notification support possible

## 🔄 Updates and Maintenance

### Regular Tasks
- Monitor Firebase console
- Update localization as needed
- Test on new OS versions
- Review analytics data

### Version Compatibility
- Flutter 3.10.0+
- Android API 26+ (Android 8.0+)
- iOS 12.0+

## 📞 Support

### Documentation
- `ONBOARDING_NOTIFICATIONS_IMPLEMENTATION.md` - Technical details
- `VERIFICATION_CHECKLIST.md` - Implementation status
- `docs/manual_qa_scenarios.md` - Testing guide

### Common Questions
**Q: How do I change onboarding content?**
A: Update `_onboardingItems` in `ar_onboarding_page.dart`

**Q: Can I add more languages?**
A: Yes, add new `.arb` files and update supported locales

**Q: How do I customize notification appearance?**
A: Modify notification payload in Firebase console or backend

This implementation provides a complete, production-ready solution for AR onboarding and push notifications with excellent user experience and developer-friendly architecture.