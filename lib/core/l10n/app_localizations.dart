import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Flutter AR App',
      'home': 'Home',
      'ar': 'AR',
      'media': 'Media',
      'settings': 'Settings',
      'welcome': 'Welcome',
      'getStarted': 'Get Started',
      'next': 'Next',
      'skip': 'Skip',
      'finish': 'Finish',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'cameraPermission': 'Camera Permission',
      'cameraPermissionDenied': 'Camera permission is required for AR features',
      'grantPermission': 'Grant Permission',
      'arNotSupported': 'AR Not Supported',
      'arNotSupportedMessage': 'Your device does not support AR features',
      'networkError': 'Network Error',
      'networkErrorMessage': 'Please check your internet connection',
      'generalError': 'Something went wrong',
      'generalErrorMessage': 'An unexpected error occurred',
      'language': 'Language',
      'theme': 'Theme',
      'about': 'About',
      'version': 'Version',
      'privacy': 'Privacy Policy',
      'terms': 'Terms of Service',
    },
    'ru': {
      'appTitle': 'Flutter AR Приложение',
      'home': 'Главная',
      'ar': 'AR',
      'media': 'Медиа',
      'settings': 'Настройки',
      'welcome': 'Добро пожаловать',
      'getStarted': 'Начать',
      'next': 'Далее',
      'skip': 'Пропустить',
      'finish': 'Завершить',
      'loading': 'Загрузка...',
      'error': 'Ошибка',
      'retry': 'Повторить',
      'cancel': 'Отмена',
      'confirm': 'Подтвердить',
      'save': 'Сохранить',
      'delete': 'Удалить',
      'edit': 'Редактировать',
      'close': 'Закрыть',
      'yes': 'Да',
      'no': 'Нет',
      'ok': 'ОК',
      'cameraPermission': 'Разрешение камеры',
      'cameraPermissionDenied': 'Разрешение камеры требуется для AR функций',
      'grantPermission': 'Предоставить разрешение',
      'arNotSupported': 'AR не поддерживается',
      'arNotSupportedMessage': 'Ваше устройство не поддерживает AR функции',
      'networkError': 'Ошибка сети',
      'networkErrorMessage': 'Проверьте ваше интернет соединение',
      'generalError': 'Что-то пошло не так',
      'generalErrorMessage': 'Произошла непредвиденная ошибка',
      'language': 'Язык',
      'theme': 'Тема',
      'about': 'О приложении',
      'version': 'Версия',
      'privacy': 'Политика конфиденциальности',
      'terms': 'Условия использования',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get ar => _localizedValues[locale.languageCode]!['ar']!;
  String get media => _localizedValues[locale.languageCode]!['media']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get getStarted => _localizedValues[locale.languageCode]!['getStarted']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get skip => _localizedValues[locale.languageCode]!['skip']!;
  String get finish => _localizedValues[locale.languageCode]!['finish']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get yes => _localizedValues[locale.languageCode]!['yes']!;
  String get no => _localizedValues[locale.languageCode]!['no']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get cameraPermission => _localizedValues[locale.languageCode]!['cameraPermission']!;
  String get cameraPermissionDenied => _localizedValues[locale.languageCode]!['cameraPermissionDenied']!;
  String get grantPermission => _localizedValues[locale.languageCode]!['grantPermission']!;
  String get arNotSupported => _localizedValues[locale.languageCode]!['arNotSupported']!;
  String get arNotSupportedMessage => _localizedValues[locale.languageCode]!['arNotSupportedMessage']!;
  String get networkError => _localizedValues[locale.languageCode]!['networkError']!;
  String get networkErrorMessage => _localizedValues[locale.languageCode]!['networkErrorMessage']!;
  String get generalError => _localizedValues[locale.languageCode]!['generalError']!;
  String get generalErrorMessage => _localizedValues[locale.languageCode]!['generalErrorMessage']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get privacy => _localizedValues[locale.languageCode]!['privacy']!;
  String get terms => _localizedValues[locale.languageCode]!['terms']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
