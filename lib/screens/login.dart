import 'package:boulder_league_app/app_global.dart';
import 'package:boulder_league_app/components/login_card.dart';
import 'package:boulder_league_app/screens/signup.dart';
import 'package:flutter/material.dart';

class LoginScreenArgs {
  String? email = '';

  LoginScreenArgs({this.email});
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final args = ModalRoute.of(context)!.settings.arguments as LoginScreenArgs?;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppGlobal.title,
          style: textTheme.headlineSmall
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LoginCardForm(email: args?.email),
              Text('Don\'t have an account?'),
              TextButton(onPressed: () {
                AppGlobal.navigatorKey.currentState!.pushNamed(SignUpScreen.routeName);
              }, child: Text(
                'Create an Account'
                )
              )
            ]
          )
        ),
      ) 
    );
  }
}