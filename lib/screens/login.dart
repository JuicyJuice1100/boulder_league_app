import 'package:boulder_league_app/components/login_card.dart';
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
              // Add navigation logic here
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Create an Account'),
                    content: Text('This feature is not yet implemented.')
                  );
                }
              );
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