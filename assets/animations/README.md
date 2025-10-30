# AR Onboarding Animations

This directory contains Lottie animations for the AR onboarding flow.

## Required Animations

### 1. AR Welcome Animation
- File: `ar_welcome.json`
- Description: Animated AR icon with floating effect
- Usage: Welcome screen

### 2. Camera Permission Animation
- File: `camera_permission.json`
- Description: Camera scanning animation
- Usage: Camera permission screen

### 3. Notification Animation
- File: `notification_bell.json`
- Description: Bell notification animation
- Usage: Notification permission screen

### 4. Safety Shield Animation
- File: `safety_shield.json`
- Description: Shield with checkmarks animation
- Usage: Safety tips screen

### 5. Rocket Launch Animation
- File: `rocket_launch.json`
- Description: Rocket taking off animation
- Usage: Get started screen

## Implementation Notes

These animations should be:
- Optimized for mobile performance
- Loop seamlessly
- Support both light and dark themes
- Compressed to reasonable file size (< 500KB each)

## Placeholder Usage

Until actual animations are created, the app will use Material Design icons as fallbacks.

## Adding Animations

1. Place Lottie JSON files in this directory
2. Update `ar_onboarding_page.dart` to reference the correct files
3. Test animations in both portrait and landscape orientations
4. Verify performance on low-end devices