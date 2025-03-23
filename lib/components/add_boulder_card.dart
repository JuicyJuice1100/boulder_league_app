import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';


class AddBoulderCardForm extends StatefulWidget {
  const AddBoulderCardForm({super.key});

  @override
  State<AddBoulderCardForm> createState() => AddBoulderCardFormState();
}

class AddBoulderCardFormState extends State<AddBoulderCardForm> {
  final _addBoulderFormKey = GlobalKey<FormBuilderState>();

  bool isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) {
    ToastNotification.success('Save Button Clicked', 'Saved');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Card(
                  margin: EdgeInsets.all(20.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: FormBuilder(
                      key: _addBoulderFormKey,
                      child: Column(
                        spacing: 10,
                        children: [
                          FormBuilderTextField(
                            name: 'name',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Name'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ])
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : ()  {
                                if (_addBoulderFormKey.currentState!.validate()) {
                                  onSave(_addBoulderFormKey.currentState!.fields);
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
                                ) : Icon(Icons.add), 
                              label: Text('Add'),
                            )
                          )
                        ]
                      )
                    )
                  )
                )
              )
            )
          ]
        )
      ),
    );
  }
}