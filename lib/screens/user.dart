import 'package:boulder_league_app/auth_provider.dart';
import 'package:boulder_league_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {


  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context)!.auth;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        return ListView(
          children: <Widget>[
            Text.rich(
              TextSpan(
                text: 'Username: ',
                children: <TextSpan>[
                  TextSpan(
                    text: snapshot.data?.displayName ?? 'not set',
                    style: textTheme.headlineSmall
                  )
                ]
              )
            ),
            Text.rich(
              TextSpan(
                text: 'Email: ',
                children: <TextSpan>[
                  TextSpan(
                    text: snapshot.data?.email,
                    style: textTheme.headlineSmall
                  )
                ]
              )
            ),
          ]
        );
      },
    );
  }
}