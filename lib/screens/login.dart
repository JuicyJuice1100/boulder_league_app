import 'package:boulder_league_app/components/login_card.dart';
import 'package:boulder_league_app/screens/signup.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LoginCardForm(),
            Text('Don\'t have an account?'),
            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
            }, child: Text(
              'Create an Account'
              )
            )
          ]
        )
      ),
    );
  }
}