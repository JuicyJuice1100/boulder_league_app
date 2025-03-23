import 'package:boulder_league_app/components/update_email_card.dart';
import 'package:boulder_league_app/components/update_password_card.dart';
import 'package:boulder_league_app/components/update_username_card.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const routeName = '/account';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Info'),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              UpdateUsernameCardForm(),
              UpdateEmailCardForm(),
              UpdatePasswordCardForm()
            ]
          )
        ),
      )
      
    );
  }
}