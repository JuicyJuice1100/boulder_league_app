import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/models/boulder_filters.dart';
import 'package:boulder_league_app/models/scored_boulder.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/services/boulder_scoring_service.dart';
import 'package:boulder_league_app/services/boulder_service.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:boulder_league_app/static/weeks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';


class RecordScoreCardForm extends StatefulWidget {
  const RecordScoreCardForm({super.key});

  @override
  State<RecordScoreCardForm> createState() => RecordScoreCardFormState();
}

class RecordScoreCardFormState extends State<RecordScoreCardForm> {
  final _recordScoreFormKey = GlobalKey<FormBuilderState>();
  List<Season> seasons = [];
  String? selectedSeasonId;
  num? selectedWeek;
  List<Boulder> filteredBoulders = [];
  bool isLoading = false;
  bool showFlashedCheckbox = false;

  @override
  void initState() {
    super.initState();
    getSeasons();
  }

  void setSelectedSeason(String? seasonId) {
    setState(() {
      selectedSeasonId = seasonId;
    });
  }

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void getSeasons() {
    setState(() {
      isLoading = true;
    });

    SeasonService()
      .getSeasons(null)
      .listen((seasons) {
        setState(() {
          this.seasons = seasons;
          isLoading = false;
        });
      });
  }

  void updateBoulders(num? week) {
    if (week == null || selectedSeasonId == null) return;

    setState(() {
      isLoading = true;
      selectedWeek = week;
    });

    BoulderService()
      .getBoulders(BoulderFilters(seasonId: selectedSeasonId, week: week))
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
        seasonId: selectedSeasonId!,
        seasonName: seasons.firstWhere((s) => s.id == selectedSeasonId).name,
        week: selectedWeek!,
        attempts: int.parse(fields['attempts']!.value),
        top: fields['Top']?.value ?? false,
        createdAt: DateTime.now(),
        lastUpdate: DateTime.now(),
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
                           isLoading 
                            ? CircularProgressIndicator() :
                            FormBuilderDropdown(
                              name: 'season',
                              decoration: InputDecoration(
                                border: OutlineInputBorder(), 
                                labelText: 'Season'
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required()
                              ]), 
                              items: seasons
                                .map((season) => DropdownMenuItem(
                                      value: season.id,
                                      child: Text(season.name),
                                    ))
                                .toList(),
                              onChanged: (val) {
                                setSelectedSeason(val as String);
                              }
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
                            items: weeksList.map((week) => DropdownMenuItem(
                              value: week,
                              child: Text(week.toString())
                            )).toList(),
                            onChanged: (val) {
                              updateBoulders(val);
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