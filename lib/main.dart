import 'package:boulder_league_app/app_global.dart';
import 'package:boulder_league_app/auth_provider.dart';
import 'package:boulder_league_app/env_config.dart';
import 'package:boulder_league_app/screens/account.dart';
import 'package:boulder_league_app/screens/home.dart';
import 'package:boulder_league_app/screens/login.dart';
import 'package:boulder_league_app/screens/signup.dart';
import 'package:boulder_league_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toastification/toastification.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true
  );

  // Configure emulators based on environment variables or debug mode
  final bool shouldUseEmulator = EnvConfig.useEmulator || kDebugMode;

  if (shouldUseEmulator) {
    try {
      // Print configuration for debugging
      if (kDebugMode) {
        EnvConfig.printConfig();
      }

      FirebaseFirestore.instance.useFirestoreEmulator(
        EnvConfig.firestoreHost,
        EnvConfig.firestorePort,
      );
      await FirebaseAuth.instance.useAuthEmulator(
        EnvConfig.authHost,
        EnvConfig.authPort,
      );

      // ignore: avoid_print
      print('Connected to Firebase emulators at ${EnvConfig.firestoreHost}');
    } catch (e) {
      // ignore: avoid_print
      print('Error connecting to emulators: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: ToastificationWrapper(
        config: ToastificationConfig(
          maxTitleLines: 2,
          maxDescriptionLines: 6,
          marginBuilder: (context, alignment) =>
              const EdgeInsets.fromLTRB(0, 16, 0, 110),
        ),
        child: MaterialApp(
          navigatorKey: AppGlobal.navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => HomeController(),
            LoginScreen.routeName: (context) => LoginScreen(),
            SignUpScreen.routeName: (context) => SignUpScreen(),
            AccountScreen.routeName: (context) => AccountScreen()
          },
        )
      )
    );
  }
}

class HomeController extends StatelessWidget {
  const HomeController({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context)!.auth;

    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? HomeScreen() : LoginScreen();
        }
        return Container(
          color: Colors.black,
        );
      },
    );
  }
}