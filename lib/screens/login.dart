import 'package:boulder_league_app/components/login_card.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoginCard()
      ),
      bottomNavigationBar: 
        BottomAppBar(
          color: Color.fromARGB(0, 255, 255, 255),
          child: Text('Don\'t have an account? Sign up here!')
        ),
    );
  }
}