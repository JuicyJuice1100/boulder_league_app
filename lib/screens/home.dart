import 'package:boulder_league_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Home Screen'),
            SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: ()  {
                      AuthService().logout();
                    }, 
                    label: Text('Logout')
                  )
                )
          ]
        )
      ),
    );
  }
}