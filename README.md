# Flutter AR App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.16.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-7.0+-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

A comprehensive Flutter application with Augmented Reality capabilities, featuring a layered architecture, internationalization, and modern development practices.

[Features](#-features) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 🌟 Overview

Flutter AR App is a production-ready mobile application that demonstrates best practices in Flutter development with advanced features including:
- ✨ Augmented Reality with ARCore
- 📱 Clean Architecture with Riverpod
- 🌍 Full internationalization (English & Russian)
- 🔔 Push notifications via Firebase
- 💾 Advanced caching system
- 📸 Media capture and management
- 🔍 QR code scanning
- 📊 Performance monitoring

## 🚀 Features

### Core Functionality

- **Augmented Reality (AR)**
  - ARCore integration for Android devices
  - Real-time 3D object placement and viewing
  - Device compatibility checking
  - Performance optimization across device tiers

- **Media Management**
  - Photo and video capture
  - Gallery with system integration
  - Video recording with custom parameters
  - Media caching and offline access

- **Smart Caching**
  - Local content caching with TTL policies
  - 500MB storage limit with automatic cleanup
  - Cache management UI
  - Offline content access

- **QR Code Scanner**
  - Multiple format support (JSON, URL, simple ID)
  - Scan history tracking
  - Direct content access
  - Error handling and validation

- **Push Notifications**
  - Firebase Cloud Messaging integration
  - Deep linking support
  - Customizable notification preferences
  - Background and foreground handling

### User Experience

- **Onboarding Flow**
  - Interactive 5-step introduction
  - Permission requests handling
  - AR safety guidelines
  - Replay functionality

- **Internationalization**
  - Full English and Russian support
  - Dynamic language switching
  - Cultural content adaptation
  - Localized notifications

- **Performance Monitoring**
  - Real-time FPS tracking
  - CPU/GPU usage monitoring
  - Battery drain analysis
  - Memory usage tracking
  - Debug overlay (development mode)

## 🏃 Quick Start

### Prerequisites

```bash
# Required
- Flutter SDK 3.16.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- Android device with ARCore support (API 24+)
- JDK 11+
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/your-username/flutter-ar-app.git
cd flutter-ar-app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Configure Firebase**
- Create a Firebase project
- Download `google-services.json`
- Place in `android/app/`
- Update `firebase_options.dart`

5. **Generate code**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

6. **Run the app**
```bash
flutter run
```

For detailed setup instructions, see the [Quick Start Guide](QUICK_START_GUIDE.md).

## 📚 Documentation

### Essential Guides

- **[Project Description](PROJECT_DESCRIPTION.md)** - Complete overview in English and Russian
- **[Quick Start Guide](QUICK_START_GUIDE.md)** - Setup and first launch
- **[Documentation Index](docs/README.md)** - Complete documentation catalog

### Implementation Details

- **[Caching & QR Implementation](IMPLEMENTATION_SUMMARY.md)** - Caching and QR scanner details
- **[Testing & Performance](IMPLEMENTATION_COMPLETE.md)** - Testing infrastructure and performance
- **[Onboarding & Notifications](ONBOARDING_NOTIFICATIONS_IMPLEMENTATION.md)** - User onboarding and FCM

### Testing & QA

- **[Testing Guide](docs/TESTING_GUIDE.md)** - Testing practices and guidelines
- **[QA Procedures](docs/qa_procedures.md)** - Quality assurance methodology
- **[Troubleshooting Guide](docs/troubleshooting_guide.md)** - Common issues and solutions
- **[Manual QA Scenarios](docs/manual_qa_scenarios.md)** - Step-by-step test scenarios

## 🏗 Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│       Presentation Layer (UI)           │
│  ┌──────────┬──────────┬─────────────┐ │
│  │  Pages   │ Widgets  │  Providers  │ │
│  └──────────┴──────────┴─────────────┘ │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      Domain Layer (Business Logic)      │
│  ┌──────────┬──────────┬─────────────┐ │
│  │ Entities │ Use Cases│Repositories │ │
│  └──────────┴──────────┴─────────────┘ │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          Data Layer                      │
│  ┌──────────┬──────────┬─────────────┐ │
│  │  Repos   │ Services │Data Sources │ │
│  └──────────┴──────────┴─────────────┘ │
└─────────────────────────────────────────┘
```

### Project Structure

```
lib/
├── core/                   # Core functionality
│   ├── config/            # App configuration
│   ├── di/                # Dependency injection
│   ├── l10n/              # Localization
│   ├── router/            # Navigation
│   └── theme/             # App theming
├── data/                   # Data layer
│   ├── datasources/       # Data sources
│   ├── repositories/      # Repository implementations
│   └── services/          # Services
├── domain/                 # Business logic
│   ├── entities/          # Business models
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Use cases
├── presentation/           # UI layer
│   ├── pages/             # Screen widgets
│   ├── providers/         # State management
│   └── widgets/           # Reusable components
└── l10n/                   # Localization files
```

### Technology Stack

**Core:**
- Flutter 3.16.0+ / Dart 3.0+
- Clean Architecture
- SOLID Principles

**State Management:**
- Riverpod 2.4.9

**Dependency Injection:**
- GetIt 7.6.4
- Injectable 2.3.2

**Navigation:**
- Go Router 12.1.3

**Backend:**
- Firebase Core 2.24.2
- Firebase Messaging 14.7.9
- Firebase Analytics 10.7.4

**AR & Media:**
- AR Flutter Plugin 0.7.3
- Camera 0.10.5+5
- Video Player 2.8.1

**Storage:**
- Flutter Secure Storage 9.0.0
- Shared Preferences 2.2.2

**Networking:**
- Dio 5.4.0

**Performance:**
- Battery Plus 5.0.2
- Device Info Plus 9.1.1
- Performance Monitor 0.4.0

## 🧪 Testing

### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test/

# Specific test file
flutter test test/unit/qr_service_test.dart
```

### Test Coverage

- ✅ Unit Tests - Business logic and services
- ✅ Widget Tests - UI components
- ✅ Integration Tests - End-to-end workflows
- ✅ Performance Tests - Device tier optimization

### Device Test Matrix

**Flagship Devices:** Samsung Galaxy S23 Ultra, Pixel 7 Pro, OnePlus 11  
**Mid-Tier Devices:** Samsung Galaxy A54, Pixel 7a, OnePlus Nord 3  
**Low-End Devices:** Samsung Galaxy A14, Redmi Note 11, Moto G Play

## 📦 Building

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
# APK
flutter build apk --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release

# Split APKs by architecture (smaller size)
flutter build apk --split-per-abi --release
```

### Build Output
- **APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle:** `build/app/outputs/bundle/release/app-release.aab`

## 📊 Performance Targets

### By Device Tier

| Metric | Flagship | Mid-Tier | Low-End |
|--------|----------|----------|---------|
| App Launch | <2s | <3s | <5s |
| FPS | >55 | >30 | >15 |
| Memory | <500MB | <400MB | <300MB |
| Battery (30min) | <15% | <20% | <25% |

## 🔧 Development

### Code Generation

When modifying models, repositories, or providers:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Code Analysis
```bash
flutter analyze
```

### Formatting
```bash
flutter format .
```

### Adding a New Feature

1. Create entity in `domain/entities/`
2. Define repository interface in `domain/repositories/`
3. Create use case in `domain/usecases/`
4. Implement repository in `data/repositories/`
5. Create provider in `presentation/providers/`
6. Build UI in `presentation/pages/` or `presentation/widgets/`
7. Add localization strings to `l10n/app_en.arb` and `l10n/app_ru.arb`
8. Write tests for each layer
9. Update documentation

## 🌍 Localization

### Supported Languages
- 🇬🇧 English (en)
- 🇷🇺 Russian (ru)

### Adding Translations

1. Add keys to `lib/l10n/app_en.arb`
2. Add translations to `lib/l10n/app_ru.arb`
3. Use in code: `AppLocalizations.of(context).yourKey`

### Adding a New Language

1. Create `lib/l10n/app_[locale].arb`
2. Add locale to `supportedLocales` in `main.dart`
3. Update locale provider

## 🔐 Security & Permissions

### Required Permissions
- **Camera** - AR functionality and media capture
- **Storage** - Saving and accessing media files
- **Internet** - Firebase services and content download
- **Notifications** - Optional, user-controlled

### Environment Variables
```bash
ENV=development|production
API_BASE_URL=https://your-api.com
ENABLE_LOGGING=true|false
ENABLE_AR_FEATURES=true|false
```

## 🐛 Troubleshooting

### Common Issues

**ARCore not working:**
- Verify device supports ARCore
- Install ARCore from Play Store
- Check camera permissions

**Build failures:**
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter run
```

**Firebase issues:**
- Verify `google-services.json` is in `android/app/`
- Check Firebase configuration in console
- Ensure correct package name

For more solutions, see [Troubleshooting Guide](docs/troubleshooting_guide.md).

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow the existing code style
- Write tests for new features
- Update documentation
- Ensure all tests pass
- Follow clean architecture principles

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🛣 Roadmap

### In Progress
- [x] ARCore integration
- [x] Push notifications
- [x] Performance monitoring
- [x] Caching system
- [x] QR scanner

### Planned
- [ ] iOS ARKit support
- [ ] Advanced AR features (object recognition, tracking)
- [ ] Cloud storage integration
- [ ] Social features
- [ ] Additional language support
- [ ] Web version (limited AR)
- [ ] Desktop support

## 📞 Support

### Getting Help
- 📖 Check [Documentation](docs/README.md)
- 🔍 Search [Issues](https://github.com/your-username/flutter-ar-app/issues)
- 💬 Create a new [Issue](https://github.com/your-username/flutter-ar-app/issues/new)
- 📧 Contact the team

### Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [ARCore Documentation](https://developers.google.com/ar)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)

## 👏 Acknowledgments

Built with:
- [Flutter](https://flutter.dev) - UI framework
- [ARCore](https://developers.google.com/ar) - Augmented reality
- [Firebase](https://firebase.google.com) - Backend services
- [Riverpod](https://riverpod.dev) - State management

## 📈 Statistics

- **Lines of Code:** ~15,000+
- **Test Coverage:** 80%+
- **Supported Devices:** 100+ ARCore-compatible devices
- **Languages:** 2 (English, Russian)
- **Minimum Android Version:** 7.0 (API 24)

---

<div align="center">

**Made with ❤️ using Flutter**

[⬆ Back to Top](#flutter-ar-app)

</div>
