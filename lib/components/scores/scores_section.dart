import 'package:boulder_league_app/components/scores/scores_filters.dart';
import 'package:boulder_league_app/components/scores/scores_form.dart';
import 'package:boulder_league_app/components/scores/scores_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/models/season_filters.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ScoresSection extends StatefulWidget {
  const ScoresSection({super.key});

  @override
  State<ScoresSection> createState() => _ScoresSectionState();
}

class _ScoresSectionState extends State<ScoresSection> {
  final SeasonService _seasonService = SeasonService();

  String? selectedSeasonId;
  String selectedGymId = 'climb_kraft';
  bool isLoading = false;

  List<Season> availableSeasons = [];
  StreamSubscription<Season?>? _currentSeasonSub;
  StreamSubscription<List<Season>>? _seasonsSub;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  @override
  void dispose() {
    _currentSeasonSub?.cancel();
    _seasonsSub?.cancel();
    super.dispose();
  }

  void _initializeFilters() {
    setState(() => isLoading = true);

    // Subscribe to all seasons for the gym
    _seasonsSub = _seasonService.getSeasons(SeasonFilters(gymId: selectedGymId)).listen((seasons) {
      setState(() {
        availableSeasons = seasons;
      });
    });

    // Subscribe to current active season to set as default
    _currentSeasonSub = _seasonService.getCurrentSeasonForGym(selectedGymId).listen((season) {
      if (season != null && selectedSeasonId == null) {
        setState(() {
          selectedSeasonId = season.id;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  void _onGymChanged(String? newGymId) {
    if (newGymId == null || newGymId == selectedGymId) return;

    setState(() {
      selectedGymId = newGymId;
      selectedSeasonId = null;
      availableSeasons = [];
      isLoading = true;
    });

    // Cancel previous subscriptions
    _seasonsSub?.cancel();
    _currentSeasonSub?.cancel();

    // Re-initialize with new gym
    _initializeFilters();
  }

  void _onSeasonChanged(String? newSeasonId) {
    if (newSeasonId == null || newSeasonId == selectedSeasonId) return;

    setState(() {
      selectedSeasonId = newSeasonId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: 'Scores',
      filters: ScoresFilters(
        selectedGymId: selectedGymId,
        selectedSeasonId: selectedSeasonId,
        availableSeasons: availableSeasons,
        onGymChanged: _onGymChanged,
        onSeasonChanged: _onSeasonChanged,
      ),
      table: ScoresTable(
        selectedGymId: selectedGymId,
        selectedSeasonId: selectedSeasonId,
      ),
      add: ScoresForm(),
    );
  }
}