import 'package:boulder_league_app/services/auth_service.dart';
import 'package:flutter/material.dart';


class SignUpCardForm extends StatefulWidget {
  const SignUpCardForm({super.key});


  @override
  State<SignUpCardForm> createState() => SignUpCardFormState();
}

class SignUpCardFormState extends State<SignUpCardForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), 
                  labelText: 'Confirm Password'
                )
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : ()  {
                    setIsLoading(true);
                    
                    LoginService().createAccount(emailController.text, passwordController.text).then(
                      (result) => {
                        print(result.message)
                      }
                    ).whenComplete(() => setIsLoading(false));
                  },
                  icon: isLoading ?
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0
                      )
                    ) : Icon(Icons.login), 
                  label: Text('Login'),
                )
              )
            ],
          )
        )
      )
    );
  }
}