import 'package:boulder_league_app/components/boulders/boulders_filters.dart';
import 'package:boulder_league_app/components/boulders/boulders_form.dart';
import 'package:boulder_league_app/components/boulders/boulders_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/models/season_filters.dart';
import 'package:boulder_league_app/services/gym_service.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:boulder_league_app/static/weeks.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class BouldersSection extends StatefulWidget {
  const BouldersSection({super.key});

  @override
  State<BouldersSection> createState() => _BouldersSectionState();
}

class _BouldersSectionState extends State<BouldersSection> {
  final SeasonService _seasonService = SeasonService();
  final GymService _gymService = GymService();

  String? selectedSeasonId;
  String selectedGymId = '';
  num? selectedWeek;
  bool isLoading = false;

  List<Gym> availableGyms = [];
  List<Season> availableSeasons = [];
  List<num> availableWeeks = weeksList;
  StreamSubscription<Season?>? _currentSeasonSub;
  StreamSubscription<List<Season>>? _seasonsSub;
  StreamSubscription<List<Gym>>? _gymsSub;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  @override
  void dispose() {
    _currentSeasonSub?.cancel();
    _seasonsSub?.cancel();
    _gymsSub?.cancel();
    super.dispose();
  }

  void _loadGyms() {
    _gymsSub = _gymService.getGyms().listen((gyms) {
      setState(() {
        availableGyms = gyms;
        if (gyms.isNotEmpty && selectedGymId.isEmpty) {
          selectedGymId = gyms.first.id;
          _initializeFilters();
        }
      });
    });
  }

  void _initializeFilters() {
    setState(() => isLoading = true);

    // Subscribe to all seasons for the gym
    _seasonsSub = _seasonService.getSeasons(SeasonFilters(gymId: selectedGymId)).listen((seasons) {
      setState(() {
        availableSeasons = seasons;
      });
    });
  }

  void _onGymChanged(String? newGymId) {
    if (newGymId == null || newGymId == selectedGymId) return;

    setState(() {
      selectedGymId = newGymId;
      selectedSeasonId = null;
      selectedWeek = null;
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
    setState(() {
      selectedSeasonId = newSeasonId;
    });
  }

  void _onWeekChanged(num? newWeek) {
    setState(() {
      selectedWeek = newWeek;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: 'Boulders',
      filters: BouldersFilters(
        selectedGymId: selectedGymId,
        selectedSeasonId: selectedSeasonId,
        selectedWeek: selectedWeek,
        availableGyms: availableGyms,
        availableSeasons: availableSeasons,
        availableWeeks: availableWeeks,
        onGymChanged: _onGymChanged,
        onSeasonChanged: _onSeasonChanged,
        onWeekChanged: _onWeekChanged,
      ),
      table: BouldersTable(
        selectedGymId: selectedGymId,
        selectedSeasonId: selectedSeasonId,
        selectedWeek: selectedWeek,
        availableGyms: availableGyms,
        availableSeasons: availableSeasons,
        availableWeeks: availableWeeks,
      ),
      add: BouldersForm(
        availableGyms: availableGyms,
        availableSeasons: availableSeasons,
        availableWeeks: availableWeeks
      ),
    );
  }
}