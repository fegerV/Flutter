# Flutter AR App

A comprehensive Flutter application with Augmented Reality capabilities, featuring a layered architecture, internationalization, and modern development practices.

## 🚀 Features

- **Augmented Reality**: ARCore integration for Android devices
- **Media Management**: Photo and video capture with gallery functionality
- **Internationalization**: Support for English and Russian languages
- **Responsive Design**: Adaptive UI for different screen sizes
- **Modern Architecture**: Clean architecture with dependency injection
- **State Management**: Riverpod for reactive state management
- **Navigation**: Go Router for type-safe navigation
- **Environment Configuration**: Development and production environments

## 📱 Architecture

### Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── config/             # App configuration
│   ├── di/                 # Dependency injection
│   ├── l10n/               # Internationalization
│   ├── router/             # App routing
│   └── theme/              # App theming
├── data/                   # Data layer (repositories, models)
├── domain/                 # Business logic (use cases, entities)
├── presentation/           # UI layer
│   ├── pages/              # Screen widgets
│   │   ├── ar/            # AR features
│   │   ├── home/          # Home screen
│   │   ├── media/         # Media management
│   │   ├── onboarding/    # App introduction
│   │   ├── settings/      # App settings
│   │   └── splash/        # Splash screen
│   ├── providers/         # Riverpod providers
│   └── widgets/           # Reusable UI components
└── main.dart              # App entry point
```

### Technology Stack

- **Framework**: Flutter 3.16.0+
- **Language**: Dart 3.0+
- **State Management**: Riverpod
- **Dependency Injection**: GetIt + Injectable
- **Navigation**: Go Router
- **Networking**: Dio
- **Local Storage**: Flutter Secure Storage, Shared Preferences
- **AR**: ARCore Plugin
- **Media**: Video Player, Camera
- **Internationalization**: Flutter Intl
- **Responsive Design**: Flutter ScreenUtil

## 🛠 Development Setup

### Prerequisites

- Flutter SDK 3.16.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android device/emulator with ARCore support

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/flutter-ar-app.git
   cd flutter-ar-app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code:
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Environment Configuration

Copy `.env.example` to `.env` and configure your environment variables:

```bash
cp .env.example .env
```

Available environment variables:
- `ENVIRONMENT`: development|production
- `API_BASE_URL`: Base URL for API calls
- `ENABLE_LOGGING`: Enable debug logging
- `ENABLE_AR_FEATURES`: Enable AR functionality

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## 📦 Build

### Android Debug APK
```bash
flutter build apk --debug
```

### Android Release APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

## 🔧 Code Generation

The project uses code generation for:
- Dependency injection configuration
- JSON serialization

Run code generation when making changes:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 📱 Supported Features

### AR Features
- ARCore integration for Android
- Camera permission handling
- AR object placement (placeholder)
- AR settings (placeholder)

### Media Features
- Camera capture
- Video recording
- Gallery browsing
- Media management

### Settings
- Language selection (English/Russian)
- Theme configuration
- Cache management
- Privacy settings

## 🌍 Internationalization

The app supports:
- English (en)
- Russian (ru)

Localization files are located in `lib/l10n/`:
- `app_en.arb` - English translations
- `app_ru.arb` - Russian translations

## 🔄 CI/CD

The project includes GitHub Actions workflows for:
- Code analysis (`flutter analyze`)
- Unit testing (`flutter test`)
- APK/AAB building

Workflows are triggered on:
- Push to main/develop branches
- Pull requests to main/develop branches

## 📝 Code Style

The project follows:
- Flutter official style guide
- `flutter_lints` for static analysis
- Clean Architecture principles
- SOLID principles

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Run code analysis
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation
- Review existing issues

## 🗺 Roadmap

- [ ] iOS AR support with ARKit
- [ ] Advanced AR features (object recognition, tracking)
- [ ] Cloud storage integration
- [ ] Social features
- [ ] Performance optimizations
- [ ] More language support

## 📊 Requirements

### Android
- **Minimum SDK**: 24 (Android 7.0)
- **Target SDK**: 34 (Android 14)
- **ARCore**: Compatible device required

### iOS
- **Minimum iOS Version**: 12.0 (future support)
- **ARKit**: Compatible device required (future support)
