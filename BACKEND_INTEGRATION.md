# Backend Integration Documentation

This document describes the backend integration implemented for the Flutter AR App, including authentication, data layer, MinIO/S3 integration, and AR services.

## Table of Contents

1. [Overview](#overview)
2. [Authentication Flow](#authentication-flow)
3. [Data Layer](#data-layer)
4. [MinIO/S3 Integration](#minios3-integration)
5. [AR Service](#ar-service)
6. [Error Handling](#error-handling)
7. [Testing](#testing)
8. [Configuration](#configuration)

## Overview

The backend integration follows Clean Architecture principles with three main layers:

- **Domain Layer**: Business entities and services
- **Data Layer**: Repositories, API clients, and data sources
- **Presentation Layer**: UI components and state management

All components use dependency injection via GetIt and Injectable for loose coupling and testability.

## Authentication Flow

### Components

#### 1. AuthToken Entity
**Location**: `lib/domain/entities/auth_token.dart`

Represents an authentication token with access token, refresh token, expiry date, and token type.

```dart
final token = AuthToken(
  accessToken: 'access_token',
  refreshToken: 'refresh_token',
  expiresAt: DateTime.now().add(Duration(hours: 1)),
  tokenType: 'Bearer',
);

// Check if token is expired or expiring soon
if (token.isExpired) { /* handle expired token */ }
if (token.isExpiringSoon) { /* refresh token */ }
```

#### 2. SecureStorageService
**Location**: `lib/data/datasources/local/secure_storage_service.dart`

Provides secure storage for authentication tokens using Flutter Secure Storage with encrypted shared preferences on Android.

```dart
// Save tokens
await secureStorage.saveAccessToken(token.accessToken);
await secureStorage.saveRefreshToken(token.refreshToken);
await secureStorage.saveTokenExpiry(token.expiresAt);

// Retrieve tokens
final accessToken = await secureStorage.getAccessToken();
final hasValid = await secureStorage.hasValidToken();

// Clear tokens
await secureStorage.clearTokens();
```

#### 3. AuthApiClient
**Location**: `lib/data/datasources/remote/auth_api_client.dart`

Handles authentication API calls with automatic error handling and retry logic.

```dart
// Login
final tokenModel = await authApiClient.login(
  username: 'user',
  password: 'pass',
);

// Refresh token
final newTokenModel = await authApiClient.refreshToken(refreshToken);

// Logout
await authApiClient.logout(accessToken);
```

#### 4. AuthRepository
**Location**: `lib/data/repositories/auth_repository.dart`

Implements the authentication repository with offline awareness and automatic retries.

```dart
// Login
final result = await authRepository.login(
  username: 'user',
  password: 'pass',
);

result.fold(
  (failure) => print('Login failed: $failure'),
  (token) => print('Login successful'),
);

// Check authentication status
final isAuth = await authRepository.isAuthenticated();
```

### Authentication Flow Diagram

```
User -> AuthRepository -> AuthApiClient -> API Server
                       -> SecureStorageService -> Secure Storage
```

## Data Layer

### Animation Metadata

Fetch and manage animation assets from the API.

**Components**:
- Entity: `lib/domain/entities/animation_metadata.dart`
- Model: `lib/data/models/animation_metadata_model.dart`
- API Client: `lib/data/datasources/remote/animation_api_client.dart`
- Repository: `lib/data/repositories/animation_repository.dart`

**Usage**:

```dart
// Get all animations
final result = await animationRepository.getAnimations(page: 1, limit: 20);

// Get specific animation
final result = await animationRepository.getAnimationById('animation-id');

// Search animations
final result = await animationRepository.searchAnimations(
  query: 'dancing',
  tags: ['3d', 'animated'],
);
```

### Marker Definitions

Manage AR marker definitions for object recognition.

**Components**:
- Entity: `lib/domain/entities/marker_definition.dart`
- Model: `lib/data/models/marker_definition_model.dart`
- API Client: `lib/data/datasources/remote/marker_api_client.dart`
- Repository: `lib/data/repositories/marker_repository.dart`

**Usage**:

```dart
// Get all markers
final result = await markerRepository.getMarkers(page: 1, limit: 20);

// Get specific marker
final result = await markerRepository.getMarkerById('marker-id');
```

### User Assets

Manage user-specific assets and uploaded content.

**Components**:
- Entity: `lib/domain/entities/user_asset.dart`
- Model: `lib/data/models/user_asset_model.dart`
- API Client: `lib/data/datasources/remote/user_asset_api_client.dart`
- Repository: `lib/data/repositories/user_asset_repository.dart`

**Usage**:

```dart
// Get user assets
final result = await userAssetRepository.getUserAssets(
  page: 1,
  limit: 20,
  assetType: 'image',
);

// Get specific asset
final result = await userAssetRepository.getUserAssetById('asset-id');
```

## MinIO/S3 Integration

### MinioClientService

**Location**: `lib/data/datasources/remote/minio_client.dart`

Provides S3-compatible object storage integration with MinIO.

**Features**:
- Stream objects from MinIO
- Download objects with progress callbacks
- Generate presigned URLs for temporary access
- Check object existence and get metadata

**Usage**:

```dart
// Stream an object
final stream = await minioClient.streamObject(
  objectName: 'animations/dance.mp4',
);

// Download with progress tracking
await minioClient.downloadObject(
  objectName: 'animations/dance.mp4',
  destinationPath: '/path/to/save/dance.mp4',
  onProgress: (received, total) {
    final progress = (received / total) * 100;
    print('Download progress: $progress%');
  },
);

// Get presigned URL for direct access
final url = await minioClient.getPresignedUrl(
  objectName: 'animations/dance.mp4',
  expiry: Duration(hours: 1),
);

// Check if object exists
final exists = await minioClient.objectExists(
  objectName: 'animations/dance.mp4',
);

// Get object size
final size = await minioClient.getObjectSize(
  objectName: 'animations/dance.mp4',
);
```

### AnimationRepository Integration

The AnimationRepository integrates MinIO for downloading animation files:

```dart
// Download animation file
final result = await animationRepository.downloadAnimation(
  objectName: 'animations/dance.mp4',
  destinationPath: '/local/path/dance.mp4',
  onProgress: (received, total) {
    // Update UI with download progress
  },
);

// Get stream URL
final urlResult = await animationRepository.getAnimationStreamUrl(
  objectName: 'animations/dance.mp4',
  expiry: Duration(hours: 1),
);
```

## AR Service

### ArService

**Location**: `lib/domain/services/ar_service.dart`

High-level service that combines all repositories and provides a unified API for AR features.

**Features**:
- Automatic token refresh when tokens are expiring
- Simplified API for authentication and data access
- Centralized error handling
- Offline awareness

**Usage**:

```dart
final arService = getIt<ArService>();

// Authentication
final authResult = await arService.authenticate(
  username: 'user',
  password: 'pass',
);

// Check authentication status
final isAuth = await arService.isAuthenticated();

// Fetch animations (with automatic token refresh)
final animationsResult = await arService.fetchAnimations(page: 1, limit: 20);

// Fetch markers
final markersResult = await arService.fetchMarkers();

// Fetch user assets
final assetsResult = await arService.fetchUserAssets(assetType: 'image');

// Download animation
final downloadResult = await arService.downloadAnimation(
  objectName: 'dance.mp4',
  destinationPath: '/path/to/save',
  onProgress: (received, total) {
    // Update progress
  },
);

// Sign out
await arService.signOut();
```

## Error Handling

### Failure Types

**Location**: `lib/core/error/failures.dart`

- `NetworkFailure`: Network connectivity issues
- `AuthFailure`: Authentication errors
- `ServerFailure`: Server-side errors
- `CacheFailure`: Caching errors
- `StorageFailure`: Storage errors
- `ValidationFailure`: Validation errors
- `UnknownFailure`: Unknown errors

### Exception Types

**Location**: `lib/core/error/exceptions.dart`

- `NetworkException`: Network-related exceptions
- `AuthException`: Authentication exceptions
- `ServerException`: Server-side exceptions
- `CacheException`: Cache-related exceptions
- `StorageException`: Storage exceptions
- `ValidationException`: Validation exceptions

### Error Handling Pattern

All repository methods return `Either<Failure, T>` from the dartz package:

```dart
final result = await repository.someMethod();

result.fold(
  (failure) {
    // Handle error
    if (failure is NetworkFailure) {
      showSnackBar('No internet connection');
    } else if (failure is AuthFailure) {
      navigateToLogin();
    } else {
      showSnackBar('An error occurred: ${failure.message}');
    }
  },
  (data) {
    // Handle success
    updateUI(data);
  },
);
```

### Retry Logic

Network requests automatically retry up to 3 times on transient failures:

```dart
final data = await retry(
  () => apiClient.getData(),
  retryIf: (e) => e is NetworkException,
  maxAttempts: 3,
);
```

### Offline Awareness

All repositories check network connectivity before making API calls:

```dart
if (!await networkInfo.isConnected) {
  return const Left(NetworkFailure('No internet connection'));
}
```

## Testing

### Test Structure

```
test/
└── unit/
    ├── core/
    │   └── network/
    │       └── network_info_test.dart
    ├── data/
    │   ├── datasources/
    │   │   ├── auth_api_client_test.dart
    │   │   └── secure_storage_service_test.dart
    │   └── repositories/
    │       ├── auth_repository_test.dart
    │       └── animation_repository_test.dart
    └── domain/
        └── services/
            └── ar_service_test.dart
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/data/repositories/auth_repository_test.dart

# Run with coverage
flutter test --coverage
```

### Test Example

```dart
test('should return AuthToken when login is successful', () async {
  // Arrange
  when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
  when(mockApiClient.login(username: any, password: any))
      .thenAnswer((_) async => tokenModel);

  // Act
  final result = await repository.login(
    username: 'user',
    password: 'pass',
  );

  // Assert
  expect(result.isRight(), true);
  verify(mockSecureStorage.saveAccessToken(any)).called(1);
});
```

## Configuration

### Environment Variables

Configure the backend integration in `.env` file:

```env
# API Configuration
API_BASE_URL=https://api.example.com
AUTH_TOKEN_ENDPOINT=/auth/token
AUTH_REFRESH_ENDPOINT=/auth/refresh

# MinIO/S3 Configuration
MINIO_ENDPOINT=play.min.io
MINIO_PORT=9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_USE_SSL=true
MINIO_BUCKET=ar-animations

# Feature Flags
ENABLE_LOGGING=true
ENABLE_AR_FEATURES=true
```

### Accessing Configuration

```dart
// In code
final apiBaseUrl = AppConfig.apiBaseUrl;
final minioEndpoint = AppConfig.minioEndpoint;
final enableArFeatures = AppConfig.enableArFeatures;
```

### Dependency Injection Setup

All services are registered in `lib/core/di/injection_container.dart`:

```dart
// Initialize DI
await configureDependencies();

// Access services
final arService = getIt<ArService>();
final authRepository = getIt<AuthRepository>();
final minioClient = getIt<MinioClientService>();
```

## Code Generation

Generate required code files:

```bash
# Generate JSON serialization and DI configuration
flutter packages pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `*.g.dart` files for JSON serialization
- `injection_container.config.dart` for dependency injection
- `*_test.mocks.dart` files for test mocks

## API Endpoints

### Authentication
- `POST /auth/token` - Login
- `POST /auth/refresh` - Refresh token
- `POST /auth/logout` - Logout

### Animations
- `GET /animations` - Get animations list
- `GET /animations/{id}` - Get animation by ID
- `GET /animations/search` - Search animations

### Markers
- `GET /markers` - Get markers list
- `GET /markers/{id}` - Get marker by ID

### User Assets
- `GET /user/assets` - Get user assets list
- `GET /user/assets/{id}` - Get user asset by ID

## Best Practices

1. **Always check network connectivity** before making API calls
2. **Use dependency injection** for all services
3. **Handle errors with Either pattern** for type-safe error handling
4. **Implement retry logic** for transient network failures
5. **Secure token storage** using Flutter Secure Storage
6. **Automatic token refresh** when tokens are expiring
7. **Write unit tests** for all repositories and services
8. **Use const constructors** where possible for performance
9. **Follow Clean Architecture** principles for maintainability
10. **Document API changes** in this file

## Troubleshooting

### Common Issues

1. **Token Expired**: Automatically handled by ArService with token refresh
2. **Network Error**: Check internet connectivity and retry
3. **MinIO Connection Failed**: Verify MinIO configuration in .env
4. **JSON Parsing Error**: Ensure API response matches model definitions

### Debug Logging

Enable logging in `.env`:

```env
ENABLE_LOGGING=true
DEBUG_MODE=true
```

## Future Enhancements

- [ ] Implement caching layer for offline support
- [ ] Add GraphQL support
- [ ] Implement WebSocket for real-time updates
- [ ] Add biometric authentication
- [ ] Implement request queuing for offline mode
- [ ] Add analytics integration
- [ ] Implement A/B testing framework
