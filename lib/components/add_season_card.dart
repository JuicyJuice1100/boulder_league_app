import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddSeasonCardForm extends StatefulWidget {
  const AddSeasonCardForm({super.key});

  @override
  State<AddSeasonCardForm> createState() => AddSeasonCardFormState();
}

class AddSeasonCardFormState extends State<AddSeasonCardForm> {
  final _addSeasonFormKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) async {
    try {
      setIsLoading(true);

      SeasonService().addSeason(Season(
        id: Uuid().v4(),
        name: fields['name']!.value,
        startDate: fields['daterange']!.value.start,
        endDate: fields['daterange']!.value.end,
        isActive: fields['active']!.value,
        createdByUid: FirebaseAuth.instance.currentUser!.uid,
      )).then((value) => {
        if(value.success) {
          ToastNotification.success(value.message, null),
          _addSeasonFormKey.currentState?.reset()
        } else {
          ToastNotification.error(value.message, null)
        }
      });
    } catch (e) {
      ToastNotification.error('Failed to add boulder: $e', null);
    } finally {
      setIsLoading(false);
    }
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
                      key: _addSeasonFormKey,
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
                          FormBuilderDateRangePicker(
                            name: 'daterange',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Date Range'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ]), 
                            firstDate: DateTime(DateTime.now().year),
                            lastDate: DateTime(DateTime.now().year + 1),
                            format: DateFormat('MMM dd, yyyy'),
                            initialEntryMode: DatePickerEntryMode.input
                          ),
                           FormBuilderCheckbox(
                            name: 'active',  
                            title: Text('Active Season'),
                            initialValue: false,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : ()  {
                                if (_addSeasonFormKey.currentState!.validate()) {
                                  onSave(_addSeasonFormKey.currentState!.fields);
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