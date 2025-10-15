import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/services/boulder_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final List<String> _weekList = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Week 6', 'Week 7', 'Week 8', 'Week 9', 'Week 10'];

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

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) async {
    try {
      setIsLoading(true);

      BoulderService().addBoulder(Boulder(
        id: Uuid().v4(),
        name: fields['name']!.value,
        week: fields['week']!.value,
        month: DateFormat.MMMM().format(DateTime.now()),
        createdByUid: FirebaseAuth.instance.currentUser!.uid,
      )).then((value) => {
        if(value.success) {
          ToastNotification.success(value.message, null),
          _addBoulderFormKey.currentState?.reset()
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
                          FormBuilderDropdown(
                            name: 'week',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Week'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ]), 
                            items: _weekList.map((week) => DropdownMenuItem(
                              value: week,
                              child: Text(week)
                            )).toList(),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
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