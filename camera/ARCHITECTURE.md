# Standardized Flutter Architecture

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── app.dart                     # Main app configuration
├── constants/                   # Global constants
│   ├── app_constants.dart       # General constants
│   ├── api_endpoints.dart       # API endpoints
│   └── app_strings.dart         # String resources
├── core/                        # Cross-cutting functionalities
│   ├── error/                   # Error handling
│   ├── network/                 # Network management
│   ├── storage/                 # Local and secure storage
│   ├── theme/                   # Theme system
│   ├── utils/                   # Cross-cutting utilities
│   └── di/                      # Dependency injection
├── features/                    # Business features
│   └── auth/                    # Example of a complete feature
│       ├── data/                # Data layer
│       ├── domain/              # Domain layer
│       ├── presentation/        # Presentation layer
│       └── auth.dart            # Barrel export
└── shared/                      # Shared elements
    ├── widgets/                 # Reusable widgets
    ├── services/                # Global services
    └── utils/                   # Shared utilities
```

## Clean Architecture

### Layer Separation Principles

1. **Presentation Layer**: User interface

   * Pages
   * Widgets
   * BLoCs/Providers
   * Navigation

2. **Domain Layer**: Pure business logic

   * Entities
   * Use Cases
   * Repository Interfaces

3. **Data Layer**: Data management

   * Models
   * Data Sources (Remote/Local)
   * Repository Implementations

### Data Flow

```
UI → BLoC → Use Case → Repository → Data Source
 ↑                                    ↓
 ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
```

## Theme System

### Structure

* `AppColors` : Standardized color palette
* `AppTextStyles` : Consistent text styles
* `AppSpacing` : Standardized spacing
* `AppBorderRadius` : Uniform border radius

### Available Themes

* Light Theme
* Dark Theme
* System mode support

## Dependency Injection

### Service Locator Pattern

Using `get_it` for dependency management:

```dart
// Registration
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));

// Usage
final authRepo = sl<AuthRepository>();
```

## State Management with BLoC

### BLoC Structure

* **Event**: User-triggered events
* **State**: Application states
* **Bloc**: State management logic

### Example Usage

```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    // Side effect handling
  },
  builder: (context, state) {
    // Build UI
  },
)
```

## Network Management

### API Client

* Centralized HTTP client
* Timeout management
* Customizable interceptors
* Automatic error handling

### Network Info

* Connectivity checking
* Offline/online handling

## Storage

### Local Storage

* `SharedPreferences` for simple data
* Centralized error handling

### Secure Storage

* `FlutterSecureStorage` for sensitive data
* Authentication tokens
* API keys

## Error Handling

### Error Types

* `ServerException`: Server errors
* `CacheException`: Cache errors
* `NetworkException`: Network errors
* `ValidationException`: Validation errors

### Error Handler

Automatic conversion of exceptions to `Failure` with centralized management.

## Validation and Formatting

### Validators

* Email validation
* Password validation
* Phone validation
* Custom validation

### Formatters

* Date formatting
* Currency formatting
* Number formatting
* Text formatting

## Shared Widgets

### Buttons

* `PrimaryButton`: Main button
* `SecondaryButton`: Secondary button

### Input Fields

* `CustomTextField`: Custom text field
* `EmailTextField`: Email field with validation
* `PasswordTextField`: Password field

### Cards and Dialogs

* `CustomCard`: Custom card
* `LoadingDialog`: Loading dialog
* `ConfirmationDialog`: Confirmation dialog

## Global Services

### Navigation Service

* Centralized navigation
* Route management
* Automatic snackbars

### Notification Service

* Notification handling
* Toast messages
* Push notifications

### Analytics Service

* Event tracking
* User metrics
* Firebase analytics

## Naming Conventions

### Files

* **Pages**: `*_page.dart`
* **Widgets**: `*_widget.dart`
* **Blocs**: `*_bloc.dart`
* **Models**: `*_model.dart`
* **Entities**: `*_entity.dart`
* **Use Cases**: `*_use_case.dart`

### Classes

* **Pages**: `*Page`
* **Widgets**: `*Widget`
* **Blocs**: `*Bloc`
* **Events**: `*Event`
* **States**: `*State`

## Development Cycle

### 1. Create a Feature

```bash
features/feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/
│   ├── pages/
│   └── widgets/
└── feature_name.dart
```

### 2. Implementation

1. Create domain entities
2. Define repository interfaces
3. Create use cases
4. Implement data sources
5. Create data models
6. Implement repositories
7. Create BLoCs
8. Develop UI

### 3. Testing

* Unit tests for use cases
* Integration tests for repositories
* Widget tests for UI

## Key Dependencies

* **flutter_bloc**: State management
* **get_it**: Dependency injection
* **dartz**: Functional programming
* **equatable**: Object comparison
* **http**: HTTP client
* **shared_preferences**: Local storage
* **flutter_secure_storage**: Secure storage
* **intl**: Internationalization

## Best Practices

1. Separation of responsibilities: each layer has a defined role
2. Inverted dependencies: domain does not depend on infrastructure
3. Testability: easily testable code with mocks
4. Reusability: reusable widgets and services
5. Maintainability: organized and documented code
6. Performance: Flutter optimization best practices

## Configuration

### Environment Variables

```dart
// constants/app_constants.dart
static const String baseUrl = 'https://api.example.com';
static const Duration apiTimeout = Duration(seconds: 30);
```

### Themes

```dart
// core/theme/colors.dart
static const Color primary = Color(0xFF1562D9);
static const Color secondary = Color(0xFF6C757D);
```

This architecture provides a scalable and maintainable Flutter project foundation with clear separation of concerns.
