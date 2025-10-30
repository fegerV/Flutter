# Recording Feature QA Checklist

## Overview
This checklist covers the testing requirements for the screen/AR session recording functionality with gallery integration.

## Pre-requisites
- [ ] Android device running Android 7.0 (API level 24) or higher
- [ ] Test device has sufficient storage space (>1GB available)
- [ ] All required permissions are granted (Camera, Microphone, Storage)
- [ ] App is built in release mode for final testing

## 1. Recording Functionality

### 1.1 Start Recording
- [ ] User can start recording from AR page
- [ ] Recording indicator (REC) appears and blinks
- [ ] Timer starts counting from 00:00
- [ ] Audio icon shows if microphone is enabled
- [ ] Permissions are requested if not granted
- [ ] Error handling when permissions are denied
- [ ] Recording starts successfully on first attempt

### 1.2 Recording Controls
- [ ] Stop button is visible and functional during recording
- [ ] Pause button works (Android 7.0+)
- [ ] Resume button works after pause (Android 7.0+)
- [ ] Recording continues when app goes to background
- [ ] Recording captures AR overlay content
- [ ] Audio is recorded when enabled

### 1.3 Stop Recording
- [ ] Recording stops when stop button is pressed
- [ ] Timer stops at final duration
- [ ] Recording is saved to temporary storage
- [ ] File size is calculated correctly
- [ ] Recording appears in gallery

## 2. Gallery Integration

### 2.1 Gallery Access
- [ ] Gallery button opens recording gallery
- [ ] Gallery shows all saved recordings
- [ ] Empty state displays when no recordings exist
- [ ] Loading state shows while fetching recordings

### 2.2 Recording Display
- [ ] Recordings display with correct duration
- [ ] File size is shown correctly
- [ ] Date/time is formatted properly (Today, Yesterday, etc.)
- [ ] Saved status indicator appears for gallery-saved items
- [ ] Grid layout displays correctly on different screen sizes

### 2.3 Save to Gallery
- [ ] Save to Gallery button works for unsaved recordings
- [ ] Confirmation message appears after successful save
- [ ] Recording appears in device gallery
- [ ] Media scanner updates gallery immediately
- [ ] Save button disappears after successful save

## 3. Storage and Permissions

### 3.1 Storage Management
- [ ] Recordings are saved to app's temporary directory
- [ ] Gallery saves use Android's MediaStore
- [ ] Scoped storage compliance (Android 10+)
- [ ] Storage permissions are handled correctly
- [ ] Manage External Storage permission works on Android 11+

### 3.2 Permission Handling
- [ ] Camera permission request on first recording
- [ ] Microphone permission request when audio is enabled
- [ ] Storage permission request for gallery access
- [ ] Screen capture permission request
- [ ] Graceful handling when permissions are denied
- [ ] App provides clear permission explanations

## 4. Device Compatibility Testing

### 4.1 Android Versions
- [ ] Android 7.0 (API 24) - Basic functionality
- [ ] Android 8.0 (API 26) - Improved performance
- [ ] Android 9.0 (API 28) - Enhanced features
- [ ] Android 10 (API 29) - Scoped storage
- [ ] Android 11 (API 30) - Manage external storage
- [ ] Android 12 (API 31) - Latest features
- [ ] Android 13 (API 33) - Current version

### 4.2 Device Types
- [ ] Standard smartphones (16:9 aspect ratio)
- [ ] Tall smartphones (18:9+ aspect ratio)
- [ ] Tablets (various screen sizes)
- [ ] Low-end devices (2GB RAM or less)
- [ ] High-end devices (8GB+ RAM)

## 5. Performance Testing

### 5.1 Recording Performance
- [ ] Recording starts within 2 seconds
- [ ] No significant frame drops during recording
- [ ] Memory usage remains stable during recording
- [ ] Battery usage is reasonable
- [ ] CPU usage doesn't exceed 80% during recording

### 5.2 File Performance
- [ ] Recording files are created with correct format (MP4)
- [ ] File sizes are reasonable for recording duration
- [ ] Video quality is acceptable (1080p target)
- [ ] Audio quality is clear when enabled
- [ ] Files can be played in standard video players

## 6. Error Handling

### 6.1 Recording Errors
- [ ] Insufficient storage space warning
- [ ] Recording failure due to system limitations
- [ ] Audio recording failure fallback
- [ ] Network connectivity not required (works offline)
- [ ] App crash recovery

### 6.2 Gallery Errors
- [ ] Gallery save failure handling
- [ ] File deletion error handling
- [ ] Permission denied error messages
- [ ] Corrupted file detection
- [ ] Network timeout handling

## 7. UI/UX Testing

### 7.1 Visual Design
- [ ] Recording controls are clearly visible
- [ ] Buttons are appropriately sized for touch
- [ ] Colors contrast well with AR content
- [ ] Text is readable on different backgrounds
- [ ] Loading states provide visual feedback

### 7.2 User Experience
- [ ] Recording workflow is intuitive
- [ ] Gallery navigation is smooth
- [ ] Error messages are clear and actionable
- [ ] Confirmation messages appear for important actions
- [ ] Back navigation works correctly

## 8. Integration Testing

### 8.1 AR Integration
- [ ] Recording captures AR objects correctly
- [ ] AR overlay is visible in recordings
- [ ] Recording doesn't interfere with AR performance
- [ ] AR tracking continues during recording
- [ ] Recording works with different AR scenes

### 8.2 System Integration
- [ ] Recordings appear in device gallery app
- [ ] Files are accessible through file managers
- [ ] Recordings can be shared to other apps
- [ ] System notifications work correctly
- [ ] Do Not Disturb mode doesn't interfere

## 9. Edge Cases

### 9.1 Unusual Scenarios
- [ ] Recording during phone calls
- [ ] Recording with low battery
- [ ] Recording with storage almost full
- [ ] Recording during system updates
- [ ] Recording with multiple apps running

### 9.2 Data Integrity
- [ ] Recording interruption (app kill, power loss)
- [ ] File corruption detection
- [ ] Partial recording handling
- [ ] Duplicate file naming
- [ ] Character encoding in file names

## 10. Accessibility Testing

### 10.1 Screen Readers
- [ ] Recording controls are accessible via TalkBack
- [ ] Gallery items are properly labeled
- [ ] Status announcements are clear
- [ ] Navigation works with screen readers
- [ ] Content descriptions are meaningful

### 10.2 Visual Accessibility
- [ ] High contrast mode support
- [ ] Large text scaling support
- [ ] Color blind friendly design
- [ ] Focus indicators are visible
- [ ] Touch target sizes meet guidelines

## Test Results Summary

### Passed Tests: ___/___
### Failed Tests: ___/___
### Blocked Tests: ___/___
### Notes: _________________________________

### Overall Status: [ ] PASS [ ] FAIL [ ] NEEDS REVIEW

### Tester Name: _________________________
### Test Date: ____________________________
### Device Used: __________________________