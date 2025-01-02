Here's the markdown code for the README file:

```markdown
# Flutter Project Setup Guide

This guide will walk you through the steps to initialize a Flutter project and provide some essential basic and advanced commands for development.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initialize Flutter Project](#initialize-flutter-project)
3. [Basic Commands](#basic-commands)
4. [Advanced Commands](#advanced-commands)

---

## Prerequisites

Before setting up your Flutter project, ensure that the following prerequisites are met:

- **Flutter SDK**: Install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install).
- **Dart SDK**: Comes bundled with Flutter.
- **Android Studio** or **VS Code**: For a seamless Flutter development experience. Install any of these IDEs with the required plugins.
- **Xcode** (macOS only): For iOS development.

---

## Initialize Flutter Project

1. **Install Flutter**:
   If you haven't installed Flutter, follow the [installation guide](https://flutter.dev/docs/get-started/install) for your OS.

2. **Create a New Flutter Project**:
   Open a terminal and run the following command to create a new Flutter project:

   ```bash
   flutter create <project_name>
   ```

   Replace `<project_name>` with your desired project name.

3. **Navigate to the Project Directory**:

   ```bash
   cd <project_name>
   ```

4. **Run the Project**:
   To run the Flutter app on a connected device or simulator, use:

   ```bash
   flutter run
   ```

---

## Basic Commands

1. **Check Flutter Installation**:

   Verify that Flutter is properly installed:

   ```bash
   flutter doctor
   ```

   This command checks for missing dependencies like Android SDK, Xcode, etc.

2. **Get Dependencies**:

   Install the dependencies listed in `pubspec.yaml`:

   ```bash
   flutter pub get
   ```

3. **Build App for Specific Platform**:

   To build the app for Android:

   ```bash
   flutter build apk
   ```

   For iOS:

   ```bash
   flutter build ios
   ```

4. **Run Tests**:

   Run unit tests or widget tests:

   ```bash
   flutter test
   ```

5. **Hot Reload**:

   Use hot reload to apply changes instantly to a running app:

   ```bash
   r
   ```

---

## Advanced Commands

1. **Flutter Clean**:

   Clear the build directory and reset project settings:

   ```bash
   flutter clean
   ```

2. **Create Release APK**:

   Create a release APK for Android:

   ```bash
   flutter build apk --release
   ```

3. **Flutter Build App Bundle**:

   Create an app bundle for distribution on Google Play:

   ```bash
   flutter build appbundle
   ```

4. **Analyze Code for Issues**:

   Run the static analysis tool to check for potential issues in your code:

   ```bash
   flutter analyze
   ```

5. **Run with a Specific Device**:

   To run on a particular device, first list all available devices:

   ```bash
   flutter devices
   ```

   Then, run on the desired device:

   ```bash
   flutter run -d <device_id>
   ```

---

## Conclusion

This guide covers the basic setup of a Flutter project along with essential commands to help you get started and improve your workflow. For more detailed information, check the official Flutter documentation at [flutter.dev](https://flutter.dev/).
```