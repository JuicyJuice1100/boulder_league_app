import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/models/base_meta_data.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/models/boulder_filters.dart';
import 'package:boulder_league_app/models/scored_boulder.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/services/boulder_scoring_service.dart';
import 'package:boulder_league_app/services/boulder_service.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:boulder_league_app/static/default_season_filters.dart';
import 'package:uuid/uuid.dart';
import 'package:boulder_league_app/static/weeks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:boulder_league_app/helpers/score_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ScoresForm extends StatefulWidget {
  final ScoredBoulder? scoredBoulder;
  const ScoresForm({super.key, this.scoredBoulder});

  @override
  State<ScoresForm> createState() => ScoresFormState();
}

class ScoresFormState extends State<ScoresForm> {
  final _scoreFormKey = GlobalKey<FormBuilderState>();
  final BoulderScoringService _scoreService = BoulderScoringService();
  final BoulderService _boulderService = BoulderService();
  final SeasonService _seasonService = SeasonService();

  List<Season> seasons = [];
  List<Boulder> filteredBoulders = [];
  String? selectedSeasonId;
  num? selectedWeek;
  bool isLoading = false;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    getSeasons();
    setIsUpdate();
  }

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void setIsUpdate() {
    setState(() {
      isUpdate = widget.scoredBoulder != null;
    });
  }

  void getSeasons() {
    setState(() {
      isLoading = true;
    });

    _seasonService
      .getSeasons(defaultSeasonFilters)
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

    _boulderService
      .getBoulders(BoulderFilters(seasonId: selectedSeasonId, week: week))
      .listen((boulders) {
        setState(() {
          filteredBoulders = boulders;
          isLoading = false;
        });
      });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) async {
    try {
      setIsLoading(true);
      final user = FirebaseAuth.instance.currentUser!;

      final num attempts = num.parse(fields['attempts']!.value);
      final bool completed = fields['completed']?.value;

      final scoredBoulder = ScoredBoulder(
        id: widget.scoredBoulder?.id ?? Uuid().v4(),
        uid: user.uid, // users can only score for themselves
        boulderId: fields['boulderId']?.value,
        gymId: fields['gymId']?.value,
        seasonId: fields['seasonId']?.value,
        week: fields['week']?.value,
        attempts: attempts,
        completed: completed,
        score: calculateScore(
          attempts: attempts,
          completed: completed,
        ),
        baseMetaData: BaseMetaData(
          createdByUid: widget.scoredBoulder?.baseMetaData.createdByUid ?? user.uid,
          lastUpdateByUid: user.uid,
          createdAt: widget.scoredBoulder?.baseMetaData.createdAt ?? DateTime.now().toUtc(),
          lastUpdateAt: DateTime.now().toUtc(),
        ),
      );
      if (widget.scoredBoulder != null) {
        _scoreService.updateScore(scoredBoulder).then((value) => {
          if(value.success) {
            ToastNotification.success(value.message, null),
            _scoreFormKey.currentState?.reset(),
            Navigator.pop(context)
          } else {
            ToastNotification.error(value.message, null)
          }
        });
      } else {
        _scoreService.addScore(scoredBoulder).then((value) => {
          if(value.success) {
            ToastNotification.success(value.message, null),
            _scoreFormKey.currentState?.reset(),
            Navigator.pop(context)
          } else {
            ToastNotification.error(value.message, null)
          }
        });
      }
    } catch (e) {
      ToastNotification.error('Failed to update score: $e', null);
    } finally {
      setIsLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Update Score' : 'Add Score')
      ),
      body: FormBuilder(
        key: _scoreFormKey,
        child: Column(
          spacing: 10,
          children: [
            SizedBox(height: 10),
            FormBuilderDropdown(
              name: 'gymId',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Gym'
              ),
              initialValue: widget.scoredBoulder?.gymId ?? 'climb_kraft',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required()
              ]),
              items: const [
                DropdownMenuItem(value: 'climb_kraft', child: Text('Climb Kraft')),
              ],
            ),
            isLoading 
            ? CircularProgressIndicator() :
            FormBuilderDropdown(
              name: 'seasonId',
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
                if(val == null) return;

                setState(() {
                  selectedSeasonId = val;
                });
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
              enabled: selectedSeasonId != null,
              onChanged: (val) {
                if(val == null) return;
                
                updateBoulders(val);
              },
            ),
            FormBuilderDropdown(
              name: 'boulderId',
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
              initialValue: widget.scoredBoulder?.attempts.toString() ?? '0',
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
                FormBuilderValidators.min(1),
              ])
            ),
            FormBuilderCheckbox(
              name: 'completed',
              title: Text('Completed'),
              initialValue: widget.scoredBoulder?.completed ?? false,
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : () {
                  if (_scoreFormKey.currentState!.validate()) {
                    onSave(_scoreFormKey.currentState!.fields);
                  }
                },
                icon: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0
                      )
                    )
                  : Icon(isUpdate ? Icons.save : Icons.add),
                label: Text(isUpdate ? 'Save' : 'Add'),
              )
            )
          ]
        )
      )
    );
  }
}