import 'package:boulder_league_app/components/sign_up_card.dart';
import 'package:boulder_league_app/screens/login.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
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