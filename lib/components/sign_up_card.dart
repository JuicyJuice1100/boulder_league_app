import 'package:boulder_league_app/app_global.dart';
import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/screens/login.dart';
import 'package:boulder_league_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';


class SignUpCardForm extends StatefulWidget {
  const SignUpCardForm({super.key});

  @override
  State<SignUpCardForm> createState() => SignUpCardFormState();
}

class SignUpCardFormState extends State<SignUpCardForm> {
  final _signUpFormKey = GlobalKey<FormBuilderState>();

  bool isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) {
    if(fields['password']!.value == fields['confirmPassword']!.value) {
      setIsLoading(true);
      AuthService().createAccount(fields['email']!.value, fields['password']!.value, fields['confirmPassword']!.value).then(
        (result) => {
          if(result.success) {
            ToastNotification.success(result.message, null),
            AppGlobal.navigatorKey.currentState!.pushNamed(LoginScreen.routeName, arguments: LoginScreenArgs(email: fields['email']!.value))
          } else {
            ToastNotification.error(result.message, null)
          }
        }
      ).whenComplete(() => setIsLoading(false));
    } else {
      _signUpFormKey.currentState!.fields['confirmPassword']?.invalidate('Passwords do not match');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _signUpFormKey,
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
                    FormBuilderValidators.range(6, 24),
                    FormBuilderValidators.hasLowercaseChars(),
                    FormBuilderValidators.hasUppercaseChars(),
                    FormBuilderValidators.hasNumericChars(),
                    FormBuilderValidators.hasSpecialChars(),
                  ])
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'confirmPassword',
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(), 
                    labelText: 'Confirm Password'
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.range(6, 24),
                    FormBuilderValidators.hasLowercaseChars(),
                    FormBuilderValidators.hasUppercaseChars(),
                    FormBuilderValidators.hasNumericChars(),
                    FormBuilderValidators.hasSpecialChars(),
                  ])
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : ()  {
                      if (_signUpFormKey.currentState!.validate()) {
                        onSave(_signUpFormKey.currentState!.fields);
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