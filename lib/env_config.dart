import 'dart:io';
import 'package:flutter/foundation.dart';

/// Environment configuration for Firebase emulators
///
/// This class handles configuration for connecting to Firebase emulators
/// either locally or through a Docker proxy.
class EnvConfig {
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// Host for Firestore emulator
  /// For web builds: always use 'localhost' since the browser connects from host machine
  /// For local development: 'localhost'
  static const String firestoreHost = String.fromEnvironment(
    'FIRESTORE_HOST',
    defaultValue: 'localhost',
  );

  /// Port for Firestore emulator
  /// For Docker web: 8080 (direct to Firestore emulator via exposed port)
  /// For local development: 8080
  static const int firestorePort = int.fromEnvironment(
    'FIRESTORE_PORT',
    defaultValue: 8080,
  );

  /// Host for Auth emulator
  /// For web builds: always use 'localhost' since the browser connects from host machine
  /// For local development: 'localhost'
  static const String authHost = String.fromEnvironment(
    'AUTH_HOST',
    defaultValue: 'localhost',
  );

  /// Port for Auth emulator
  /// For Docker web: 9099 (direct to Auth emulator via exposed port)
  /// For local development: 9099
  static const int authPort = int.fromEnvironment(
    'AUTH_PORT',
    defaultValue: 9099,
  );

  static const String appCheckRecaptchaSiteKey = String.fromEnvironment(
    'APPCHECK_RECAPTCHA_SITE_KEY',
    defaultValue: ''
  );

  /// Get the appropriate emulator host based on platform
  /// - Android emulator: 10.0.2.2 (special alias to host machine)
  /// - iOS simulator/Web: localhost
  static String getEmulatorHost() {
    if (kIsWeb) {
      return 'localhost';
    }
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  /// Print current configuration (useful for debugging)
  static void printConfig() {
    // ignore: avoid_print
    print('=== Firebase Emulator Configuration ===');
    // ignore: avoid_print
    print('ENV: $environment');
    // ignore: avoid_print
    print('Platform emulator host: ${getEmulatorHost()}');
    // ignore: avoid_print
    print('FIRESTORE_HOST: $firestoreHost');
    // ignore: avoid_print
    print('FIRESTORE_PORT: $firestorePort');
    // ignore: avoid_print
    print('AUTH_HOST: $authHost');
    // ignore: avoid_print
    print('AUTH_PORT: $authPort');
    // ignore: avoid_print
    print('APPCHECK_RECAPTCHA_SITE_KEY: $appCheckRecaptchaSiteKey');
    // ignore: avoid_print
    print('=======================================');
  }
}
