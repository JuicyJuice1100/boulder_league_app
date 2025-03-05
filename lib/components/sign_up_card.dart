import 'package:flutter/material.dart';

class SignUpCard extends StatelessWidget {
  const SignUpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Username')
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Email')
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Password')
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Confirm Password')
            ),
          ],
        )
      )
    );
  }
}