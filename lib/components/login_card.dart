import 'package:boulder_league_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class LogicCardForm extends StatefulWidget {
  const LogicCardForm({super.key});

  @override
  State<LogicCardForm> createState() => LoginCardFormState();
}

class LoginCardFormState extends State<LogicCardForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), 
                  labelText: 'Email'
                )
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), 
                  labelText: 'Password'
                )
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if(await LoginService().login(emailController.text, passwordController.text)) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Login Test'),
                            content: Text('Login successful!')
                          );
                        }
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Login Test'),
                            content: Text('Login failed.')
                          );
                        }
                      );
                    }
                  }, 
                  child: Text('Login'),
                )
              )
            ],
          )
        )
      )
    );
  }
}