# Boulder League App

A Flutter application for managing boulder climbing leagues.

## Prerequisites

Before setting up the project, ensure you have the following installed:

- **Node.js**: v25.0.0 (or compatible version)
- **Java**: OpenJDK 25 (or compatible version)
- **Flutter SDK**: Latest stable version
- **Firebase CLI**: For running local emulators

## Local Development Setup

### 1. Install Flutter

If you don't have Flutter installed, follow these steps:

1. Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install)
2. Extract the downloaded archive to a desired location
3. Add Flutter to your PATH:
   ```bash
   export PATH="$PATH:[PATH_TO_FLUTTER_DIRECTORY]/flutter/bin"
   ```
4. Verify installation:
   ```bash
   flutter doctor
   ```
5. Follow any additional setup instructions from `flutter doctor` output


### 3. Install Firebase CLI

Install the Firebase CLI globally using npm:

```bash
curl -sL https://firebase.tools | bash
```

Verify installation:
```bash
firebase --version
```

### 4. Setup Firebase Emulator

The project uses Firebase emulators for local development with pre-configured test data.

#### Start the Firebase Emulator with Test Data

Run the following command from the project root:

```bash
firebase emulators:start --import ./default-test-data
```

This will:
- Start the Firebase Authentication emulator on port 9099
- Start the Firestore emulator on port 8080
- Import default test data from the `./default-test-data` directory
- Enable the Firebase Emulator UI (accessible via browser)

The emulator UI will be available at the URL shown in the terminal output (typically `http://localhost:4000`).

### 5. Run the Application

With the Firebase emulators running, start the Flutter app:

```bash
# Run on connected device or emulator
flutter run

# Or specify a device
flutter run -d <device-id>
```

To see available devices:
```bash
flutter devices
```

## Project Configuration

- **Firebase Project ID**: boulder-league-app
- **Firestore Database**: (default)
- **Emulator Ports**:
  - Auth: 9099
  - Firestore: 8080
  - UI: Enabled (default port)

## Mobile Deployment

For Android deployment using Fastlane and Firebase App Distribution, see [MOBILE_README.md](MOBILE_README.md).

---

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Mobile Deployment Guide](MOBILE_README.md)
