import 'package:boulder_league_app/components/leaderboards/leaderboard_filters.dart';
import 'package:boulder_league_app/components/leaderboards/leaderboard_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/models/season_filters.dart';
import 'package:boulder_league_app/services/gym_service.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({super.key});

  @override
  State<LeaderboardSection> createState() => LeaderboardSectionState();
}

class LeaderboardSectionState extends State<LeaderboardSection> {
  final SeasonService _seasonService = SeasonService();
  final GymService _gymService = GymService();

  String? selectedSeasonId;
  String? selectedGymId;
  bool isLoading = false;

  List<Gym> availableGyms = [];
  List<Season> availableSeasons = [];
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
        if (gyms.isNotEmpty && selectedGymId == null) {
          selectedGymId = gyms.first.id;
          // Don't set selectedSeasonId yet - wait for seasons to load
          _initializeLeaderboard();
        }
      });
    });
  }

  void _initializeLeaderboard() {
    setState(() => isLoading = true);

    // Subscribe to all seasons for the gym
    _seasonsSub = _seasonService.getSeasons(SeasonFilters(gymId: selectedGymId)).listen((seasons) {
      setState(() {
        availableSeasons = seasons;

        // Remove duplicates based on season ID
        final seen = <String>{};
        final uniqueSeasons = seasons.where((season) {
          return seen.add(season.id);
        }).toList();
        availableSeasons = uniqueSeasons;

        // Only set selectedSeasonId after seasons are loaded
        if (selectedSeasonId == null && uniqueSeasons.isNotEmpty) {
          // Try to find the gym's active season, or use the first available
          final gym = availableGyms.firstWhere(
            (g) => g.id == selectedGymId,
            orElse: () => availableGyms.first
          );

          final activeSeason = uniqueSeasons.firstWhere(
            (s) => s.id == gym.activeSeasonId,
            orElse: () => uniqueSeasons.first
          );

          selectedSeasonId = activeSeason.id;
        } else if (selectedSeasonId != null) {
          // Verify selectedSeasonId exists in the unique list
          final exists = uniqueSeasons.any((s) => s.id == selectedSeasonId);
          if (!exists && uniqueSeasons.isNotEmpty) {
            selectedSeasonId = uniqueSeasons.first.id;
          }
        }
      });
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
    _initializeLeaderboard();
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
      title: 'Leaderboard',
      filters: LeaderboardFilters(
        selectedGymId: selectedGymId,
        selectedSeasonId: selectedSeasonId,
        availableGyms: availableGyms,
        availableSeasons: availableSeasons,
        onGymChanged: _onGymChanged,
        onSeasonChanged: _onSeasonChanged,
      ),
      table: LeaderboardTable(
        selectedGymId: selectedGymId,
        selectedSeasonId: selectedSeasonId,
      ),
    );
  }
}