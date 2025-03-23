import 'package:boulder_league_app/auth_provider.dart';
import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class UpdateEmailCardForm extends StatefulWidget {
  const UpdateEmailCardForm({super.key});

  @override
  State<UpdateEmailCardForm> createState() => UpdateEmailCardFormState();
}

class UpdateEmailCardFormState extends State<UpdateEmailCardForm> {
  final _emailFormKey = GlobalKey<FormBuilderState>();

  bool isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void onSave(Map<String, dynamic> values) {
    ToastNotification.success('Save Password Clicked', 'Clicked');
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context)!.auth;

    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        _emailFormKey.currentState?.fields['email']?.didChange(snapshot.data?.email);

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
                      key: _emailFormKey,
                      child: Column(
                        spacing: 10,
                        children: [
                          FormBuilderTextField(
                            name: 'email',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Email *'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ])
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : ()  {
                                if (_emailFormKey.currentState!.validate()) {
                                  onSave(_emailFormKey.currentState!.fields);
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