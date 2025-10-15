import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/models/boulder_filters.dart';
import 'package:boulder_league_app/services/boulder_service.dart';
import 'package:boulder_league_app/static/weeks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';


class RecordScoreCardForm extends StatefulWidget {
  const RecordScoreCardForm({super.key});

  @override
  State<RecordScoreCardForm> createState() => RecordScoreCardFormState();
}

class RecordScoreCardFormState extends State<RecordScoreCardForm> {
  final _recordScoreFormKey = GlobalKey<FormBuilderState>();
  final BoulderFilters filters = BoulderFilters(
    month: DateFormat.MMMM().format(DateTime.now()), 
  );

  String? selectedWeek;
  List<Boulder> filteredBoulders = [];
  bool isLoading = false;
  bool showFlashedCheckbox = false;

  void updateBouldersForWeek(String? week) {
    if (week == null) return;

    setState(() {
      isLoading = true;
      selectedWeek = week;
    });

    BoulderService()
      .getBoulders(BoulderFilters(month: filters.month, week: week))
      .listen((boulders) {
        setState(() {
          filteredBoulders = boulders;
          isLoading = false;
        });
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
                            name: 'week',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Week'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ]), 
                            items: weeksList.map((week) => DropdownMenuItem(
                              value: week,
                              child: Text(week)
                            )).toList(),
                            onChanged: (val) {
                              updateBouldersForWeek(val as String?);
                            },
                          ),
                          FormBuilderDropdown(
                            name: 'boulder',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Boulder'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ]), 
                            items: filteredBoulders.map((boulder) => DropdownMenuItem(
                              value: boulder.id,
                              child: Text(boulder.name),
                            )).toList(),
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
                          FormBuilderCheckbox(
                            name: 'Top',  
                            title: Text('Top'),
                            initialValue: false,
                            onChanged: (value) {
                              setState(() {
                                showFlashedCheckbox = value ?? false;
                                if (!(value ?? false)) {
                                  _recordScoreFormKey.currentState?.fields['Flash']?.reset();
                                }
                              });
                            },
                          ),
                          if(showFlashedCheckbox)
                            FormBuilderCheckbox(
                              name: 'Flash',  
                              title: Text('Flash'),
                              initialValue: false,
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