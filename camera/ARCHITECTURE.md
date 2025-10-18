# Architecture Flutter Standardisée

## 📁 Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée de l'application
├── app.dart                     # Configuration principale de l'app
├── constants/                   # Constantes globales
│   ├── app_constants.dart      # Constantes générales
│   ├── api_endpoints.dart      # Endpoints API
│   └── app_strings.dart        # Chaînes de caractères
├── core/                       # Fonctionnalités transversales
│   ├── error/                  # Gestion des erreurs
│   ├── network/                # Gestion réseau
│   ├── storage/                # Stockage local et sécurisé
│   ├── theme/                  # Système de thèmes
│   ├── utils/                  # Utilitaires transversaux
│   └── di/                     # Injection de dépendances
├── features/                   # Fonctionnalités métier
│   └── auth/                   # Exemple de feature complète
│       ├── data/               # Couche données
│       ├── domain/             # Couche métier
│       ├── presentation/       # Couche présentation
│       └── auth.dart           # Export barrel
└── shared/                     # Éléments partagés
    ├── widgets/                # Widgets réutilisables
    ├── services/               # Services globaux
    └── utils/                  # Utilitaires partagés
```

## 🏗️ Architecture Clean Architecture

### Principe de Séparation des Couches

1. **Presentation Layer** : Interface utilisateur (UI)
   - Pages
   - Widgets
   - BLoCs/Providers
   - Navigation

2. **Domain Layer** : Logique métier pure
   - Entities
   - Use Cases
   - Repository Interfaces

3. **Data Layer** : Gestion des données
   - Models
   - Data Sources (Remote/Local)
   - Repository Implementations

### Flux de Données

```
UI → BLoC → Use Case → Repository → Data Source
 ↑                                    ↓
 ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
```

## 🎨 Système de Thèmes

### Structure
- `AppColors` : Palette de couleurs standardisée
- `AppTextStyles` : Styles de texte cohérents
- `AppSpacing` : Espacements standardisés
- `AppBorderRadius` : Rayons de bordure uniformes

### Thèmes Disponibles
- Thème clair (LightTheme)
- Thème sombre (DarkTheme)
- Support du mode système

## 🔧 Injection de Dépendances

### Service Locator Pattern
Utilisation de `get_it` pour la gestion des dépendances :

```dart
// Enregistrement
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));

// Utilisation
final authRepo = sl<AuthRepository>();
```

## 📱 Gestion d'État avec BLoC

### Structure BLoC
- **Event** : Événements utilisateur
- **State** : États de l'application
- **Bloc** : Logique de gestion d'état

### Exemple d'utilisation
```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    // Gestion des effets de bord
  },
  builder: (context, state) {
    // Construction de l'UI
  },
)
```

## 🌐 Gestion Réseau

### API Client
- Client HTTP centralisé
- Gestion des timeouts
- Intercepteurs personnalisables
- Gestion d'erreurs automatique

### Network Info
- Vérification de connectivité
- Gestion hors ligne/en ligne

## 💾 Stockage

### Stockage Local
- `SharedPreferences` pour les données simples
- Gestion des erreurs centralisée

### Stockage Sécurisé
- `FlutterSecureStorage` pour les données sensibles
- Tokens d'authentification
- Clés API

## 🛡️ Gestion des Erreurs

### Types d'Erreurs
- `ServerException` : Erreurs serveur
- `CacheException` : Erreurs de cache
- `NetworkException` : Erreurs réseau
- `ValidationException` : Erreurs de validation

### Error Handler
Conversion automatique des exceptions en `Failure` avec gestion centralisée.

## 📋 Validation et Formatage

### Validators
- Validation d'email
- Validation de mot de passe
- Validation de téléphone
- Validation personnalisée

### Formatters
- Formatage de dates
- Formatage de devises
- Formatage de nombres
- Formatage de texte

## 🎯 Widgets Partagés

### Boutons
- `PrimaryButton` : Bouton principal
- `SecondaryButton` : Bouton secondaire

### Champs de Saisie
- `CustomTextField` : Champ de texte personnalisé
- `EmailTextField` : Champ email avec validation
- `PasswordTextField` : Champ mot de passe

### Cartes et Dialogs
- `CustomCard` : Carte personnalisée
- `LoadingDialog` : Dialog de chargement
- `ConfirmationDialog` : Dialog de confirmation

## 🚀 Services Globaux

### Navigation Service
- Navigation centralisée
- Gestion des routes
- Snackbars automatiques

### Notification Service
- Gestion des notifications
- Toast messages
- Notifications push

### Analytics Service
- Tracking d'événements
- Métriques utilisateur
- Analytics Firebase

## 📝 Conventions de Nommage

### Fichiers
- **Pages** : `*_page.dart`
- **Widgets** : `*_widget.dart`
- **Blocs** : `*_bloc.dart`
- **Modèles** : `*_model.dart`
- **Entités** : `*_entity.dart`
- **Use Cases** : `*_use_case.dart`

### Classes
- **Pages** : `*Page`
- **Widgets** : `*Widget`
- **Blocs** : `*Bloc`
- **Events** : `*Event`
- **States** : `*State`

## 🔄 Cycle de Développement

### 1. Créer une Feature
```bash
# Structure à créer pour une nouvelle feature
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

### 2. Implémentation
1. Créer les entités du domaine
2. Définir les interfaces des repositories
3. Créer les use cases
4. Implémenter les data sources
5. Créer les modèles de données
6. Implémenter les repositories
7. Créer les BLoCs
8. Développer l'interface utilisateur

### 3. Tests
- Tests unitaires pour les use cases
- Tests d'intégration pour les repositories
- Tests de widgets pour l'UI

## 📦 Dépendances Principales

- **flutter_bloc** : Gestion d'état
- **get_it** : Injection de dépendances
- **dartz** : Programmation fonctionnelle
- **equatable** : Comparaison d'objets
- **http** : Client HTTP
- **shared_preferences** : Stockage local
- **flutter_secure_storage** : Stockage sécurisé
- **intl** : Internationalisation

## 🎯 Bonnes Pratiques

1. **Séparation des responsabilités** : Chaque couche a un rôle défini
2. **Dépendances inversées** : Le domaine ne dépend pas de l'infrastructure
3. **Testabilité** : Code facilement testable avec des mocks
4. **Réutilisabilité** : Widgets et services réutilisables
5. **Maintenabilité** : Code organisé et documenté
6. **Performance** : Optimisations et bonnes pratiques Flutter

## 🔧 Configuration

### Variables d'Environnement
```dart
// Dans constants/app_constants.dart
static const String baseUrl = 'https://api.example.com';
static const Duration apiTimeout = Duration(seconds: 30);
```

### Thèmes
```dart
// Personnalisation des couleurs dans core/theme/colors.dart
static const Color primary = Color(0xFF1562D9);
static const Color secondary = Color(0xFF6C757D);
```

Cette architecture fournit une base solide et évolutive pour vos projets Flutter, avec une séparation claire des responsabilités et une structure maintenable.
