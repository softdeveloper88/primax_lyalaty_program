# App Icon Update Instructions

This document provides instructions on how to update the app icons for both Android and iOS.

## Setup

I've added the `flutter_launcher_icons` package to your `pubspec.yaml` and created a configuration file (`flutter_launcher_icons.yaml`) that will use your app logo to generate all the required icon sizes for both platforms.

## Steps to Generate Icons

1. Run the following command to install the new dependencies:

```bash
flutter pub get
```

2. Run the following command to generate the icons:

```bash
flutter pub run flutter_launcher_icons
```

3. This will:
   - Generate all required Android icons in the `mipmap` folders
   - Generate all required iOS icons in the `Assets.xcassets/AppIcon.appiconset` folder
   - Create adaptive icons for modern Android versions

## Notes

- The configuration uses the app logo from `assets/images/app_logo.png`
- For Android adaptive icons, it uses a green background color that matches your app's theme
- The generated icons will replace the existing ones in both platforms
- No code changes are required as the icon file names will remain the same

## Manual Adjustments (if needed)

If you need to make manual adjustments to any specific icon size:

- For Android: Replace the specific PNG file in the appropriate `mipmap-*` folder
- For iOS: Replace the specific PNG file in the `Assets.xcassets/AppIcon.appiconset` folder

## Verification

After generating the icons, build the app for both platforms to verify the changes:

```bash
flutter build apk --debug
flutter build ios --debug
```