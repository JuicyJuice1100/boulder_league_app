import 'package:boulder_league_app/auth_provider.dart';
import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class UpdateUsernameCardForm extends StatefulWidget {
  const UpdateUsernameCardForm({super.key});

  @override
  State<UpdateUsernameCardForm> createState() => UpdateUsernameCardFormState();
}

class UpdateUsernameCardFormState extends State<UpdateUsernameCardForm> {
  final _usernameFormKey = GlobalKey<FormBuilderState>();

  bool isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) {
    ToastNotification.success('Update Username Clicked', 'Clicked');
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context)!.auth;

    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        _usernameFormKey.currentState?.fields['username']?.didChange(snapshot.data?.displayName);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Card(
                  margin: EdgeInsets.all(20.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: FormBuilder(
                      key: _usernameFormKey,
                      child: Column(
                        spacing: 10,
                        children: [
                          FormBuilderTextField(
                            name: 'username',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Username *'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ])
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : ()  {
                                if (_usernameFormKey.currentState!.validate()) {
                                  onSave(_usernameFormKey.currentState!.fields);
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
                                ) : Icon(Icons.save), 
                              label: Text('Update Username'),
                            )
                          )
                        ]
                      )
                    )
                  )
                )
              )
            ]
          )
        );
      },
    );
  }
}