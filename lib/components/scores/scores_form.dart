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
    setIsUpdate();
    loadSeasonsAndInit();
  }

  void setIsUpdate() {
    isUpdate = widget.scoredBoulder != null;
  }

  /// 1️⃣ Load seasons, then chain initial values for update
  void loadSeasonsAndInit() async {
    setState(() => isLoading = true);

    _seasonService.getSeasons(defaultSeasonFilters).listen((seasons) async {
      setState(() {
        this.seasons = seasons;
        isLoading = false;
      });

      if (isUpdate) {
        final scoredBoulder = widget.scoredBoulder!;
        // Use addPostFrameCallback to ensure form fields exist
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // 1. Set seasonId
          _scoreFormKey.currentState?.fields['seasonId']?.didChange(scoredBoulder.seasonId);
          setState(() => selectedSeasonId = scoredBoulder.seasonId);

          // 2. Set week
          _scoreFormKey.currentState?.fields['week']?.didChange(scoredBoulder.week);
          setState(() {
            selectedWeek = scoredBoulder.week;
            isLoading = true;
          });
        });
      }
    });
  }

  void updateBoulders() {
    if (selectedWeek == null || selectedSeasonId == null) return;

    setState(() {
      isLoading = true;
    });

    _boulderService
        .getBoulders(BoulderFilters(seasonId: selectedSeasonId, week: selectedWeek))
        .listen((boulders) {
      setState(() {
        filteredBoulders = boulders;
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if(isUpdate) {
          _scoreFormKey.currentState?.fields['boulderId']!.didChange(widget.scoredBoulder!.boulderId);
        }
      });
    });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) async {
    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser!;
      final num attempts = num.parse(fields['attempts']!.value);
      final bool completed = fields['completed']?.value;

      final scoredBoulder = ScoredBoulder(
        id: widget.scoredBoulder?.id ?? Uuid().v4(),
        uid: user.uid,
        boulderId: fields['boulderId']?.value,
        gymId: fields['gymId']?.value,
        seasonId: fields['seasonId']?.value,
        week: fields['week']?.value,
        attempts: attempts,
        completed: completed,
        score: calculateScore(attempts: attempts, completed: completed),
        baseMetaData: BaseMetaData(
          createdByUid: widget.scoredBoulder?.baseMetaData.createdByUid ?? user.uid,
          lastUpdateByUid: user.uid,
          createdAt: widget.scoredBoulder?.baseMetaData.createdAt ?? DateTime.now().toUtc(),
          lastUpdateAt: DateTime.now().toUtc(),
        ),
      );

      final result = widget.scoredBoulder != null
          ? await _scoreService.updateScore(scoredBoulder)
          : await _scoreService.addScore(scoredBoulder);

      if (result.success) {
        ToastNotification.success(result.message, null);
        _scoreFormKey.currentState?.reset();
        Navigator.pop(context);
      } else {
        ToastNotification.error(result.message, null);
      }
    } catch (e) {
      ToastNotification.error('Failed to update score: $e', null);
    } finally {
      setState(() => isLoading = false);
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
                  selectedWeek = null;
                });

                _scoreFormKey.currentState?.fields['week']!.reset();
              },
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
                if(val == null) {
                  setState(() {
                    filteredBoulders = [];
                  });
                  _scoreFormKey.currentState?.fields['boulderId']!.reset();
                  return;
                }

                setState(() {
                  selectedWeek = val;
                });
                
                updateBoulders();
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
              enabled: selectedWeek != null,
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