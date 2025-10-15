import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/models/boulder_filters.dart';
import 'package:boulder_league_app/models/scored_boulder.dart';
import 'package:boulder_league_app/services/boulder_scoring_service.dart';
import 'package:boulder_league_app/services/boulder_service.dart';
import 'package:boulder_league_app/static/weeks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // TODO: save seasons in a collection
    season: '1', 
  );

  String? selectedWeek;
  List<Boulder> filteredBoulders = [];
  bool isLoading = false;
  bool showFlashedCheckbox = false;

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void updateBouldersForWeek(String? week) {
    if (week == null) return;

    setState(() {
      isLoading = true;
      selectedWeek = week;
    });

    BoulderService()
      .getBoulders(BoulderFilters(season: filters.season, week: week))
      .listen((boulders) {
        setState(() {
          filteredBoulders = boulders;
          isLoading = false;
        });
      });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) {
    try {
      setIsLoading(true);

      var boulder = ScoredBoulder(
        uid: FirebaseAuth.instance.currentUser!.uid,
        boulderId: fields['boulder']!.value,
        boulderName: filteredBoulders.firstWhere((b) => b.id == fields['boulder']!.value).name,
        attempts: int.parse(fields['attempts']!.value),
        top: fields['Top']?.value ?? false,
        lastUpdated: Timestamp.now(),
        score: 0,
      );

      boulder.calculateScore();

      BoulderScoringService().scoreBoulder(boulder).then((value) => {
        if(value.success) {
          ToastNotification.success(value.message, null),
          _recordScoreFormKey.currentState?.reset()
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
                              FormBuilderValidators.required(),
                              FormBuilderValidators.integer(),
                              FormBuilderValidators.min(0), 
                            ]), 
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          FormBuilderCheckbox(
                            name: 'Top',  
                            title: Text('Top'),
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