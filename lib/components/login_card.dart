import 'package:boulder_league_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginCardForm extends StatefulWidget {
  const LoginCardForm({super.key});


  @override
  State<LoginCardForm> createState() => LoginCardFormState();
}

class LoginCardFormState extends State<LoginCardForm> {
  final _loginFormKey = GlobalKey<FormBuilderState>();

  bool isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void onSave(Map<String, dynamic> values) {
    setIsLoading(true);
    AuthService().login(values['email'], values['password']).then(
      (result) => {
        debugPrint(result.message)
      }
    ).whenComplete(() => setIsLoading(false));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _loginFormKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'email',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(), 
                    labelText: 'Email'
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email()
                  ])
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'password',
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(), 
                    labelText: 'Password'
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ])
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : ()  {
                      if (_loginFormKey.currentState!.saveAndValidate()) {
                        onSave(_loginFormKey.currentState!.value);
                      }
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
              ]
            )
          )
        )
      )
    );
  }
}