/// Environment configuration for Firebase emulators
///
/// This class handles configuration for connecting to Firebase emulators
/// either locally or through a Docker proxy.
class EnvConfig {
  static const bool debugLogging = bool.fromEnvironment(
    'DEBUG_LOGGING',
    defaultValue: false,
  );

  /// Flag to enable Firebase emulator mode
  /// We default to true as we don't want to touch the real database unless this is set
  static const bool useEmulator = bool.fromEnvironment(
    'USE_EMULATOR',
    defaultValue: true,
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

  static const String firebaseDatabaseId = String.fromEnvironment(
    'FIREBASE_DATABASE_ID',
    defaultValue: ''
  );

  /// Print current configuration (useful for debugging)
  static void printConfig() {
    // ignore: avoid_print
    print('=== Firebase Emulator Configuration ===');
    // ignore: avoid_print
    print('DEBUG_LOG: $debugLogging');
    // ignore: avoid_print
    print('USE_EMULATOR: $useEmulator');
    // ignore: avoid_print
    print('FIRESTORE_HOST: $firestoreHost');
    // ignore: avoid_print
    print('FIRESTORE_PORT: $firestorePort');
    // ignore: avoid_print
    print('AUTH_HOST: $authHost');
    // ignore: avoid_print
    print('AUTH_PORT: $authPort');
    // ignore: avoid_print
    print('FIREBASE_DATABASE_ID: $firebaseDatabaseId');
    // ignore: avoid_print
    print('=======================================');
  }
}
