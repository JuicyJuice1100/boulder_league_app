import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class UpdatePasswordCardForm extends StatefulWidget {
  const UpdatePasswordCardForm({super.key});

  @override
  State<UpdatePasswordCardForm> createState() => UpdatePasswordCardFormState();
}

class UpdatePasswordCardFormState extends State<UpdatePasswordCardForm> {
  final _passwordFormKey = GlobalKey<FormBuilderState>();

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
    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _passwordFormKey,
            child: Column(
              spacing: 10,
              children: [
                FormBuilderTextField(
                  name: 'currentPassword',
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(), 
                    labelText: 'Current Password *'
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ])
                ),
                FormBuilderTextField(
                  name: 'newPassword',
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(), 
                    labelText: 'New Password *'
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ])
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : ()  {
                      if (_passwordFormKey.currentState!.saveAndValidate()) {
                        onSave(_passwordFormKey.currentState!.value);
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
                    label: Text('Update Password'),
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