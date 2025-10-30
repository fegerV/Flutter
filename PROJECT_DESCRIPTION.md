# Flutter AR App - Полное описание проекта / Complete Project Description

## 🌍 Языки / Languages
- [Русский](#русская-версия)
- [English](#english-version)

---

## Русская версия

### 📱 Обзор проекта

Flutter AR App — это современное мобильное приложение на Flutter с функциями дополненной реальности (AR), предназначенное для Android устройств. Приложение демонстрирует передовые практики разработки, включая чистую архитектуру, интернационализацию и оптимизацию производительности.

### 🎯 Основные возможности

#### 1. Дополненная реальность (AR)
- Интеграция ARCore для Android устройств
- Размещение и просмотр 3D объектов в реальном пространстве
- Управление камерой и обработка разрешений
- Оптимизация производительности для разных уровней устройств
- Проверка совместимости устройства с AR

#### 2. Управление медиа-контентом
- Захват фото и видео через камеру
- Запись видео с настраиваемыми параметрами
- Галерея для просмотра сохраненных медиафайлов
- Интеграция с системной галереей устройства
- Управление медиа с кэшированием

#### 3. Система кэширования
- Локальное кэширование контента с политиками размера и времени жизни (TTL)
- Автоматическая очистка устаревших данных
- Управление кэшем через UI с визуализацией состояния
- Оффлайн-доступ к загруженному контенту
- Оптимизация использования хранилища (лимит 500MB, TTL 7 дней)

#### 4. QR-сканер
- Сканирование QR-кодов для доступа к анимациям
- Поддержка JSON, простых ID и URL форматов
- История сканирований с временными метками
- Интеграция с системой кэширования
- Обработка ошибок и валидация данных

#### 5. Push-уведомления
- Firebase Cloud Messaging (FCM) интеграция
- Настройка типов уведомлений в настройках
- Deep links для навигации из уведомлений
- Обработка уведомлений в фоновом и активном режиме
- Локализованный контент уведомлений

#### 6. Онбординг
- Интерактивный 5-шаговый процесс знакомства с приложением
- Запрос разрешений (камера, уведомления)
- Советы по безопасности AR
- Возможность повторного просмотра из настроек
- Адаптивный дизайн для разных размеров экрана

#### 7. Мониторинг производительности
- Отслеживание FPS в реальном времени
- Мониторинг использования CPU/GPU
- Отслеживание расхода батареи
- Контроль использования памяти
- Debug-оверлей с метриками (доступен в режиме разработки)
- Автоматическое определение уровня устройства

#### 8. Интернационализация
- Полная поддержка английского языка
- Полная поддержка русского языка
- Динамическое переключение языков
- Локализация всех UI элементов и сообщений
- Культурная адаптация контента

#### 9. Настройки приложения
- Выбор языка интерфейса
- Настройки уведомлений
- Управление кэшем
- Настройки приватности
- Управление онбордингом
- Системная информация

### 🏗️ Архитектура

#### Чистая архитектура (Clean Architecture)

Проект следует принципам чистой архитектуры с четким разделением слоев:

```
├── Presentation Layer (UI)
│   ├── Pages - Экраны приложения
│   ├── Widgets - Переиспользуемые UI компоненты
│   └── Providers - Управление состоянием (Riverpod)
│
├── Domain Layer (Business Logic)
│   ├── Entities - Бизнес-модели
│   ├── Repositories - Интерфейсы репозиториев
│   └── Use Cases - Бизнес-логика
│
├── Data Layer
│   ├── Repositories - Реализации репозиториев
│   ├── Data Sources - Источники данных (API, локальное хранилище)
│   └── Services - Сервисные классы
│
└── Core
    ├── Config - Конфигурация приложения
    ├── DI - Dependency Injection
    ├── Router - Навигация
    ├── Theme - Темизация
    └── L10n - Локализация
```

#### Основные технологии

**Framework & Language:**
- Flutter 3.16.0+
- Dart 3.0+

**State Management:**
- flutter_riverpod 2.4.9 - Реактивное управление состоянием

**Dependency Injection:**
- get_it 7.6.4 - Service locator
- injectable 2.3.2 - Кодогенерация для DI

**Navigation:**
- go_router 12.1.3 - Декларативная навигация

**Networking:**
- dio 5.4.0 - HTTP клиент

**Storage:**
- flutter_secure_storage 9.0.0 - Безопасное хранилище
- shared_preferences 2.2.2 - Локальное хранилище

**AR & Media:**
- ar_flutter_plugin 0.7.3 - ARCore интеграция
- camera 0.10.5+5 - Работа с камерой
- video_player 2.8.1 - Воспроизведение видео

**Firebase:**
- firebase_core 2.24.2
- firebase_messaging 14.7.9 - Push-уведомления
- firebase_analytics 10.7.4 - Аналитика

**Performance:**
- battery_plus 5.0.2
- device_info_plus 9.1.1
- performance_monitor 0.4.0

**UI:**
- flutter_screenutil 5.9.0 - Адаптивный UI
- lottie 2.7.0 - Анимации

### 📂 Структура проекта

```
flutter_ar_app/
├── lib/
│   ├── core/                      # Ядро приложения
│   │   ├── config/               # Конфигурация
│   │   ├── di/                   # Dependency Injection
│   │   ├── l10n/                 # Локализация
│   │   ├── router/               # Маршрутизация
│   │   └── theme/                # Темы оформления
│   │
│   ├── data/                      # Слой данных
│   │   ├── datasources/          # Источники данных
│   │   ├── repositories/         # Реализации репозиториев
│   │   └── services/             # Сервисы
│   │
│   ├── domain/                    # Бизнес-логика
│   │   ├── entities/             # Сущности
│   │   ├── repositories/         # Интерфейсы репозиториев
│   │   └── usecases/             # Use Cases
│   │
│   ├── presentation/              # UI слой
│   │   ├── pages/                # Страницы
│   │   │   ├── ar/              # AR функционал
│   │   │   ├── cache/           # Управление кэшем
│   │   │   ├── home/            # Главный экран
│   │   │   ├── media/           # Медиа-контент
│   │   │   ├── onboarding/      # Онбординг
│   │   │   ├── qr/              # QR-сканер
│   │   │   ├── settings/        # Настройки
│   │   │   └── splash/          # Заставка
│   │   ├── providers/           # Провайдеры состояния
│   │   └── widgets/             # Переиспользуемые виджеты
│   │
│   ├── l10n/                      # Файлы локализации
│   │   ├── app_en.arb           # Английский
│   │   └── app_ru.arb           # Русский
│   │
│   └── main.dart                  # Точка входа
│
├── test/                          # Тесты
│   ├── unit/                     # Юнит-тесты
│   ├── widget/                   # Виджет-тесты
│   └── integration/              # Интеграционные тесты
│
├── docs/                          # Документация
│   ├── qa_procedures.md          # QA процедуры
│   ├── troubleshooting_guide.md  # Руководство по устранению проблем
│   ├── TESTING_GUIDE.md          # Руководство по тестированию
│   └── manual_qa_scenarios.md    # Сценарии тестирования
│
├── android/                       # Android конфигурация
├── assets/                        # Ресурсы приложения
└── pubspec.yaml                   # Зависимости
```

### 🚀 Начало работы

#### Требования

- Flutter SDK 3.16.0+
- Dart SDK 3.0.0+
- Android Studio или VS Code с Flutter расширениями
- Android устройство/эмулятор с поддержкой ARCore (API 24+)
- JDK 11+

#### Установка

1. **Клонирование репозитория:**
```bash
git clone https://github.com/your-username/flutter-ar-app.git
cd flutter-ar-app
```

2. **Установка зависимостей:**
```bash
flutter pub get
```

3. **Настройка окружения:**
```bash
cp .env.example .env
# Отредактируйте .env файл с вашими настройками
```

4. **Генерация кода:**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

5. **Настройка Firebase:**
- Создайте проект в Firebase Console
- Скачайте `google-services.json`
- Поместите в `android/app/`
- Обновите `firebase_options.dart`

6. **Запуск приложения:**
```bash
flutter run
```

### 🧪 Тестирование

#### Запуск тестов

```bash
# Все тесты
flutter test

# С покрытием
flutter test --coverage

# Интеграционные тесты
flutter test integration_test/

# Конкретный тест
flutter test test/unit/qr_service_test.dart
```

#### Матрица тестирования

Приложение тестируется на трех уровнях устройств:

**Flagship устройства:**
- Samsung Galaxy S23 Ultra
- Google Pixel 7 Pro
- OnePlus 11

**Mid-tier устройства:**
- Samsung Galaxy A54
- Google Pixel 7a
- OnePlus Nord 3

**Low-end устройства:**
- Samsung Galaxy A14
- Redmi Note 11
- Moto G Play

### 📊 Показатели производительности

#### Целевые метрики по уровням устройств

**Flagship (топовые):**
- Запуск приложения: <2 сек
- FPS: >55
- Использование памяти: <500MB
- Расход батареи: <15% за 30 мин

**Mid-tier (средний уровень):**
- Запуск приложения: <3 сек
- FPS: >30
- Использование памяти: <400MB
- Расход батареи: <20% за 30 мин

**Low-end (бюджетные):**
- Запуск приложения: <5 сек
- FPS: >15
- Использование памяти: <300MB
- Расход батареи: <25% за 30 мин

### 🔐 Безопасность и разрешения

#### Требуемые разрешения

- **Камера** - Для AR и захвата медиа
- **Хранилище** - Для сохранения медиафайлов
- **Интернет** - Для Firebase и загрузки контента
- **Уведомления** - Опционально, контролируется пользователем

#### Безопасность данных

- Безопасное хранение токенов FCM
- Валидация входных данных QR-кодов
- Безопасные файловые операции
- Контроль доступа пользователя к функциям

### 📱 Системные требования

#### Android
- **Минимальная версия:** Android 7.0 (API 24)
- **Целевая версия:** Android 14 (API 34)
- **ARCore:** Требуется совместимое устройство
- **RAM:** Минимум 2GB (рекомендуется 4GB+)
- **Хранилище:** Минимум 100MB свободного места

#### iOS (планируется)
- **Минимальная версия:** iOS 12.0
- **ARKit:** Требуется совместимое устройство

### 🛣️ Roadmap

#### Запланировано
- [ ] Поддержка iOS с ARKit
- [ ] Расширенные AR функции (распознавание объектов, отслеживание)
- [ ] Интеграция с облачным хранилищем
- [ ] Социальные функции
- [ ] Больше языков
- [ ] Web версия (ограниченные AR функции)
- [ ] Desktop версия

#### В разработке
- [x] ARCore интеграция
- [x] Система кэширования
- [x] QR-сканер
- [x] Push-уведомления
- [x] Мониторинг производительности
- [x] Интернационализация

### 📄 Лицензия

Проект распространяется под лицензией MIT. См. файл LICENSE для деталей.

---

## English Version

### 📱 Project Overview

Flutter AR App is a modern Flutter-based mobile application with Augmented Reality (AR) capabilities designed for Android devices. The application demonstrates advanced development practices including clean architecture, internationalization, and performance optimization.

### 🎯 Key Features

#### 1. Augmented Reality (AR)
- ARCore integration for Android devices
- 3D object placement and viewing in real space
- Camera management and permission handling
- Performance optimization across device tiers
- Device AR compatibility verification

#### 2. Media Management
- Photo and video capture through camera
- Video recording with customizable parameters
- Gallery for viewing saved media files
- Integration with device system gallery
- Media management with caching support

#### 3. Caching System
- Local content caching with size and TTL policies
- Automatic cleanup of outdated data
- Cache management UI with status visualization
- Offline access to downloaded content
- Storage optimization (500MB limit, 7-day TTL)

#### 4. QR Scanner
- QR code scanning for animation access
- Support for JSON, simple ID, and URL formats
- Scan history with timestamps
- Integration with caching system
- Error handling and data validation

#### 5. Push Notifications
- Firebase Cloud Messaging (FCM) integration
- Notification type configuration in settings
- Deep links for navigation from notifications
- Background and foreground notification handling
- Localized notification content

#### 6. Onboarding
- Interactive 5-step app introduction process
- Permission requests (camera, notifications)
- AR safety tips
- Replay option from settings
- Responsive design for different screen sizes

#### 7. Performance Monitoring
- Real-time FPS tracking
- CPU/GPU usage monitoring
- Battery drain tracking
- Memory usage monitoring
- Debug overlay with metrics (available in development mode)
- Automatic device tier detection

#### 8. Internationalization
- Full English language support
- Full Russian language support
- Dynamic language switching
- Localization of all UI elements and messages
- Cultural content adaptation

#### 9. App Settings
- Interface language selection
- Notification settings
- Cache management
- Privacy settings
- Onboarding management
- System information

### 🏗️ Architecture

#### Clean Architecture

The project follows clean architecture principles with clear layer separation:

```
├── Presentation Layer (UI)
│   ├── Pages - Application screens
│   ├── Widgets - Reusable UI components
│   └── Providers - State management (Riverpod)
│
├── Domain Layer (Business Logic)
│   ├── Entities - Business models
│   ├── Repositories - Repository interfaces
│   └── Use Cases - Business logic
│
├── Data Layer
│   ├── Repositories - Repository implementations
│   ├── Data Sources - Data sources (API, local storage)
│   └── Services - Service classes
│
└── Core
    ├── Config - App configuration
    ├── DI - Dependency Injection
    ├── Router - Navigation
    ├── Theme - Theming
    └── L10n - Localization
```

#### Core Technologies

**Framework & Language:**
- Flutter 3.16.0+
- Dart 3.0+

**State Management:**
- flutter_riverpod 2.4.9 - Reactive state management

**Dependency Injection:**
- get_it 7.6.4 - Service locator
- injectable 2.3.2 - Code generation for DI

**Navigation:**
- go_router 12.1.3 - Declarative navigation

**Networking:**
- dio 5.4.0 - HTTP client

**Storage:**
- flutter_secure_storage 9.0.0 - Secure storage
- shared_preferences 2.2.2 - Local storage

**AR & Media:**
- ar_flutter_plugin 0.7.3 - ARCore integration
- camera 0.10.5+5 - Camera functionality
- video_player 2.8.1 - Video playback

**Firebase:**
- firebase_core 2.24.2
- firebase_messaging 14.7.9 - Push notifications
- firebase_analytics 10.7.4 - Analytics

**Performance:**
- battery_plus 5.0.2
- device_info_plus 9.1.1
- performance_monitor 0.4.0

**UI:**
- flutter_screenutil 5.9.0 - Responsive UI
- lottie 2.7.0 - Animations

### 🚀 Getting Started

#### Prerequisites

- Flutter SDK 3.16.0+
- Dart SDK 3.0.0+
- Android Studio or VS Code with Flutter extensions
- Android device/emulator with ARCore support (API 24+)
- JDK 11+

#### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/your-username/flutter-ar-app.git
cd flutter-ar-app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Environment setup:**
```bash
cp .env.example .env
# Edit .env file with your settings
```

4. **Generate code:**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

5. **Firebase setup:**
- Create project in Firebase Console
- Download `google-services.json`
- Place in `android/app/`
- Update `firebase_options.dart`

6. **Run the app:**
```bash
flutter run
```

### 🧪 Testing

#### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test/

# Specific test
flutter test test/unit/qr_service_test.dart
```

#### Test Matrix

The app is tested on three device tiers:

**Flagship Devices:**
- Samsung Galaxy S23 Ultra
- Google Pixel 7 Pro
- OnePlus 11

**Mid-Tier Devices:**
- Samsung Galaxy A54
- Google Pixel 7a
- OnePlus Nord 3

**Low-End Devices:**
- Samsung Galaxy A14
- Redmi Note 11
- Moto G Play

### 📊 Performance Metrics

#### Target Metrics by Device Tier

**Flagship:**
- App Launch: <2s
- FPS: >55
- Memory Usage: <500MB
- Battery Drain: <15% per 30 min

**Mid-Tier:**
- App Launch: <3s
- FPS: >30
- Memory Usage: <400MB
- Battery Drain: <20% per 30 min

**Low-End:**
- App Launch: <5s
- FPS: >15
- Memory Usage: <300MB
- Battery Drain: <25% per 30 min

### 🔐 Security and Permissions

#### Required Permissions

- **Camera** - For AR and media capture
- **Storage** - For saving media files
- **Internet** - For Firebase and content download
- **Notifications** - Optional, user-controlled

#### Data Security

- Secure storage of FCM tokens
- QR code input validation
- Safe file operations
- User access control for features

### 📱 System Requirements

#### Android
- **Minimum Version:** Android 7.0 (API 24)
- **Target Version:** Android 14 (API 34)
- **ARCore:** Compatible device required
- **RAM:** Minimum 2GB (recommended 4GB+)
- **Storage:** Minimum 100MB free space

#### iOS (planned)
- **Minimum Version:** iOS 12.0
- **ARKit:** Compatible device required

### 🛣️ Roadmap

#### Planned
- [ ] iOS support with ARKit
- [ ] Advanced AR features (object recognition, tracking)
- [ ] Cloud storage integration
- [ ] Social features
- [ ] More languages
- [ ] Web version (limited AR features)
- [ ] Desktop version

#### In Development
- [x] ARCore integration
- [x] Caching system
- [x] QR scanner
- [x] Push notifications
- [x] Performance monitoring
- [x] Internationalization

### 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

### 👥 Contributing

Contributions are welcome! Please read the contributing guidelines before submitting pull requests.

### 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation in the `docs/` folder
- Review existing issues and discussions

---

**Made with ❤️ using Flutter**
