import 'package:boulder_league_app/app_global.dart';
import 'package:boulder_league_app/components/sign_up_card.dart';
import 'package:boulder_league_app/screens/login.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static const routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SignUpCardForm(),
            Text('Already have an account?'),
            TextButton(onPressed: () {
              AppGlobal.navigatorKey.currentState!.pushNamed(LoginScreen.routeName);
            }, child: Text(
              'Sign In'
              )
            )
          ]
        )
      ),
    );
  }
}