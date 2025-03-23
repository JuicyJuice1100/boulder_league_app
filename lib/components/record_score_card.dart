import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';


class RecordScoreCardForm extends StatefulWidget {
  const RecordScoreCardForm({super.key});

  @override
  State<RecordScoreCardForm> createState() => RecordScoreCardFormState();
}

class RecordScoreCardFormState extends State<RecordScoreCardForm> {
  final _recordScoreFormKey = GlobalKey<FormBuilderState>();

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
                      key: _recordScoreFormKey,
                      child: Column(
                        spacing: 10,
                        children: [
                          FormBuilderDropdown(
                            name: 'boulder',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Boulder'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ]), 
                            items: [
                              // TODO: update this to grab from boulders
                              DropdownMenuItem(
                                child: Text('test')
                              )
                            ],
                          ),
                          FormBuilderTextField(
                            name: 'attempts',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Attempts'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ]), 
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : ()  {
                                if (_recordScoreFormKey.currentState!.validate()) {
                                  onSave(_recordScoreFormKey.currentState!.fields);
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
                                ) : Icon(Icons.playlist_add), 
                              label: Text('Record'),
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