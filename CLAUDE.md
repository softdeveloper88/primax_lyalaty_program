# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Primax Lyalaty Program is a Flutter mobile application with customer loyalty features. The app appears to be a retail/e-commerce platform with the following features:
- User authentication (Firebase)
- Product browsing and shopping cart
- Store locator with maps integration
- News and events
- Admin dashboard for store/product management
- Payment processing with Stripe

## Key Commands

### Setup and Installation

```bash
# Install Flutter dependencies
flutter pub get

# Setup Firebase (if needed - requires Firebase CLI)
dart pub global activate flutterfire_cli
flutterfire configure
```

### Running the Application

```bash
# Run in debug mode
flutter run

# Run with specific device
flutter run -d [device_id]

# Run with flavor (if configured)
flutter run --flavor dev
```

### Building the Application

```bash
# Build Android APK
flutter build apk

# Build Android App Bundle for Play Store
flutter build appbundle

# Build iOS for App Store
flutter build ios

# Build with specific environment
flutter build apk --release --flavor prod
```

### Testing

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Analysis and Linting

```bash
# Run the analyzer
flutter analyze

# Format code
flutter format .

# Fix basic code issues
dart fix --apply
```

## Architecture Overview

### Directory Structure

- `/lib/core/` - Core utilities, models, and common functionality
- `/lib/screens/` - UI screens and components
- `/lib/widgets/` - Reusable widgets
- `/assets/` - Images, icons, and other static resources

### Key Components

1. **Authentication Flow**
   - Firebase Authentication for user login/registration
   - Social login integration (Google, Apple)

2. **Navigation**
   - Uses ZoomDrawer for side menu
   - Bottom navigation for main app sections

3. **State Management**
   - Uses Flutter Bloc pattern for state management

4. **API Integration**
   - Firebase Firestore for data storage
   - Stripe for payment processing
   - Google Maps for store locations

5. **Admin Dashboard**
   - Product management
   - User management
   - Order management
   - Store location management

## Important Libraries

- `flutter_bloc`: State management
- `flutter_stripe`: Payment processing
- `google_maps_flutter`: Maps integration
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Firebase services
- `flutter_zoom_drawer`: Navigation drawer
- `flutter_downloader`: File downloads
- `firebase_remote_config`: Remote configuration

## Permissions

The app requires several permissions to function properly:

### Android Permissions
These permissions are defined in the `AndroidManifest.xml`:
- `android.permission.INTERNET` - Required for network access
- `android.permission.ACCESS_FINE_LOCATION` - Required for precise location (Google Maps)
- `android.permission.ACCESS_COARSE_LOCATION` - Required for approximate location
- `android.permission.READ_MEDIA_IMAGES` - Required for accessing images (API level 33+)
- `android.permission.READ_EXTERNAL_STORAGE` - Required for file storage access
- `android.permission.WRITE_EXTERNAL_STORAGE` - Required for storing downloaded files

### Camera and Gallery Permissions
The app uses `permission_handler` package to request camera and gallery permissions for:
- Profile image selection/capture in the `EditProfile` screen
- Document uploads in various parts of the app

### Location Permissions
Location permissions are managed using the `geolocator` package:
- Used in `StoresMapScreen` to show the user's current location
- Used to calculate distances between user and stores
- The app provides a permission request flow when location access is needed

### Permission Request Flows
When handling permissions, the app follows this pattern:
1. Check if permission is already granted
2. If denied, request the permission
3. If permanently denied, direct the user to app settings
4. Provide fallback functionality when permissions aren't available

## Common Development Tasks

### Adding a New Screen

1. Create a new file in the appropriate directory under `/lib/screens/`
2. Implement the screen using the existing design patterns
3. Add navigation to the screen in the appropriate place

### Adding New Assets

1. Place new assets in the appropriate folder under `/assets/`
2. Ensure the asset is declared in `pubspec.yaml`

### Firebase Integration

The app uses Firebase for authentication, storage, and other services. Make sure to:
1. Use the existing Firebase configuration
2. Follow the established patterns for Firebase integration
3. Test Firebase functionality thoroughly

### Handling Environment Variables

The app uses Firebase Remote Config for configuration. Sensitive keys should be stored there rather than in the code.