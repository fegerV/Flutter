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


Инструкция по сборке Flutter AR-приложения
Предварительные требования
1. Установка Flutter SDK
# Скачайте Flutter SDK с официального сайта
# https://flutter.dev/docs/get-started/install

# Для Linux/macOS:
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Проверьте установку:
flutter doctor
2. Установка Android Studio
Скачайте и установите Android Studio
Установите Android SDK (минимум API 24 / Android 7.0)
Установите Android SDK Command-line Tools
Настройте эмулятор или подключите физическое устройство
3. Проверка ARCore
Убедитесь, что ваше устройство поддерживает ARCore:

Список поддерживаемых устройств
ARCore должен быть установлен из Google Play Store
4. Java Development Kit (JDK)
# Установите JDK 11 или выше
# Проверьте версию:
java -version
Клонирование репозитория
git clone https://github.com/fegerV/Flutter.git
cd Flutter
Настройка проекта
1. Установка зависимостей
# Получить все Flutter зависимости
flutter pub get
2. Настройка окружения
Создайте файл .env в корне проекта:

# .env
ENV=dev
API_BASE_URL=https://your-backend-api.com
MINIO_ENDPOINT=https://your-minio-endpoint.com
MINIO_ACCESS_KEY=your_access_key
MINIO_SECRET_KEY=your_secret_key
3. Настройка Firebase (для push-уведомлений)
Создайте проект в Firebase Console
Скачайте google-services.json
Поместите файл в android/app/
4. Проверка конфигурации
# Проверьте, что Flutter настроен корректно
flutter doctor -v

# Убедитесь, что устройство/эмулятор доступен
flutter devices
Сборка приложения
Режим разработки (Debug)
# Запуск на подключенном устройстве/эмуляторе
flutter run

# Или с явным указанием устройства
flutter run -d <device_id>

# С включенными логами
flutter run --verbose
Режим профилирования (Profile)
# Для тестирования производительности
flutter run --profile
Режим продакшена (Release)
# Сборка APK
flutter build apk --release

# Сборка App Bundle (рекомендуется для Google Play)
flutter build appbundle --release

# Разделенные APK по архитектурам (меньший размер)
flutter build apk --split-per-abi --release
Готовые файлы будут находиться в:

APK: build/app/outputs/flutter-apk/app-release.apk
App Bundle: build/app/outputs/bundle/release/app-release.aab
Подписание приложения (для релиза)
1. Создание ключа
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
2. Настройка подписи
Создайте файл android/key.properties:

storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
3. Обновите android/app/build.gradle:
// Уже должно быть настроено в проекте
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
Установка собранного APK
# Установить на подключенное устройство
flutter install

# Или через adb
adb install build/app/outputs/flutter-apk/app-release.apk
Возможные проблемы и решения
1. Ошибки Gradle
# Очистить кэш Gradle
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
2. Проблемы с ARCore
Убедитесь, что ARCore установлен на устройстве
Проверьте права доступа к камере в настройках
Минимальная версия Android 7.0
3. Проблемы с зависимостями
# Переустановить зависимости
flutter pub cache repair
flutter pub get
4. Ошибки сборки
# Полная очистка проекта
flutter clean
cd android && ./gradlew clean && cd ..
rm -rf build/
flutter pub get
flutter run
5. Проблемы с производительностью
Используйте физическое устройство для тестирования AR
Эмуляторы не поддерживают ARCore
Проверьте, что устройство из списка поддерживаемых
Полезные команды
# Анализ кода
flutter analyze

# Запуск тестов
flutter test

# Интеграционные тесты
flutter test integration_test/

# Проверка размера APK
flutter build apk --analyze-size

# Обновление зависимостей
flutter pub upgrade

# Форматирование кода
flutter format .
Требования к устройству для тестирования
Android: 7.0+ (API level 24+)
ARCore: Обязательна поддержка
RAM: Минимум 2GB (рекомендуется 4GB+)
Камера: Обязательна
Разрешения: Камера, хранилище, интернет
Дополнительная документация
Архитектура проекта: README.md в репозитории
Flutter документация: https://flutter.dev/docs
ARCore Flutter plugin: https://pub.dev/packages/arcore_flutter_plugin
Troubleshooting: проверьте docs/troubleshooting.md в проекте
Если возникнут проблемы при сборке, проверьте логи с помощью flutter run --verbose и поделитесь ошибками для более детальной помощи.


