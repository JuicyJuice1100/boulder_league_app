import 'package:boulder_league_app/components/leaderboards/leaderboard_filters.dart';
import 'package:boulder_league_app/components/leaderboards/leaderboard_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:boulder_league_app/models/leaderboard_entry.dart';
import 'package:boulder_league_app/models/scored_boulder.dart';
import 'package:boulder_league_app/models/scored_boulder_filters.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/models/season_filters.dart';
import 'package:boulder_league_app/services/scoring_service.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({super.key});

  @override
  State<LeaderboardSection> createState() => LeaderboardSectionState();
}

class LeaderboardSectionState extends State<LeaderboardSection> {
  final ScoringService _scoringService = ScoringService();
  final SeasonService _seasonService = SeasonService();

  String? selectedSeasonId;
  String selectedGymId = 'climb_kraft';
  bool isLoading = false;

  List<Season> availableSeasons = [];
  Stream<List<LeaderboardEntry>>? _leaderboardStream;
  StreamSubscription<Season?>? _currentSeasonSub;
  StreamSubscription<List<Season>>? _seasonsSub;

  @override
  void initState() {
    super.initState();
    _initializeLeaderboard();
  }

  @override
  void dispose() {
    _currentSeasonSub?.cancel();
    _seasonsSub?.cancel();
    super.dispose();
  }

  void _initializeLeaderboard() {
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
        _updateLeaderboard();
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  void _updateLeaderboard() {
    if (selectedSeasonId == null) {
      setState(() {
        _leaderboardStream = null;
      });
      return;
    }

    // Get all scores for the gym and season, then aggregate by uid
    setState(() {
      _leaderboardStream = _scoringService
          .getScores(ScoredBoulderFilters(
            gymId: selectedGymId,
            seasonId: selectedSeasonId,
          ))
          .map((scores) => _aggregateScores(scores));
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

    _updateLeaderboard();
  }

  List<LeaderboardEntry> _aggregateScores(List<ScoredBoulder> scores) {
    // Group scores by uid
    final Map<String, List<ScoredBoulder>> groupedByUser = {};

    for (var score in scores) {
      if (!groupedByUser.containsKey(score.uid)) {
        groupedByUser[score.uid] = [];
      }
      groupedByUser[score.uid]!.add(score);
    }

    // Aggregate scores for each user
    final List<LeaderboardEntry> entries = groupedByUser.entries.map((entry) {
      final uid = entry.key;
      final userScores = entry.value;
      final totalScore = userScores.fold<num>(0, (sum, score) => sum + score.score);
      final boulderCount = userScores.length;

      // Get displayName from the most recent score (they should all be the same for a user)
      final displayName = userScores.first.displayName;

      return LeaderboardEntry(
        uid: uid,
        totalScore: totalScore,
        boulderCount: boulderCount,
        displayName: displayName,
      );
    }).toList();

    // Sort by total score in descending order
    entries.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: 'Leaderboard',
      filters: LeaderboardFilters(
        selectedGymId: selectedGymId,
        selectedSeasonId: selectedSeasonId,
        availableSeasons: availableSeasons,
        onGymChanged: _onGymChanged,
        onSeasonChanged: _onSeasonChanged,
      ),
      table: LeaderboardTable(
        leaderboardStream: _leaderboardStream,
        isLoading: isLoading,
        selectedSeasonId: selectedSeasonId,
      ),
    );
  }
}