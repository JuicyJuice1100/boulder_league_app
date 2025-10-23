import 'package:boulder_league_app/models/leaderboard_entry.dart';
import 'package:boulder_league_app/models/scored_boulder.dart';
import 'package:boulder_league_app/models/scored_boulder_filters.dart';
import 'package:boulder_league_app/services/scoring_service.dart';
import 'package:boulder_league_app/styles/default_header.dart';
import 'package:flutter/material.dart';

class LeaderboardTable extends StatefulWidget {
  final String selectedGymId;
  final String? selectedSeasonId;

  const LeaderboardTable({
    super.key,
    required this.selectedGymId,
    required this.selectedSeasonId,
  });

  @override
  State<LeaderboardTable> createState() => _LeaderboardTableState();
}

class _LeaderboardTableState extends State<LeaderboardTable> {
  final ScoringService _scoringService = ScoringService();
  Stream<List<LeaderboardEntry>>? _leaderboardStream;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateLeaderboard();
  }

  @override
  void didUpdateWidget(LeaderboardTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-fetch data when filters change
    if (oldWidget.selectedGymId != widget.selectedGymId ||
        oldWidget.selectedSeasonId != widget.selectedSeasonId) {
      _updateLeaderboard();
    }
  }

  void _updateLeaderboard() {
    setState(() => isLoading = true);

    if (widget.selectedSeasonId == null) {
      setState(() {
        _leaderboardStream = null;
        isLoading = false;
      });
      return;
    }

    // Get all scores for the gym and season, then aggregate by uid
    setState(() {
      _leaderboardStream = _scoringService
          .getScores(ScoredBoulderFilters(
            gymId: widget.selectedGymId,
            seasonId: widget.selectedSeasonId,
          ))
          .map((scores) => _aggregateScores(scores));
      isLoading = false;
    });
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

      // Get displayName from the most recent score (they should all be the same for a user)
      final displayName = userScores.first.displayName;

      return LeaderboardEntry(
        uid: uid,
        totalScore: totalScore,
        displayName: displayName,
      );
    }).toList();

    // Sort by total score in descending order
    entries.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LeaderboardEntry>>(
      stream: _leaderboardStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading leaderboard: ${snapshot.error}'),
          );
        }

        if (widget.selectedSeasonId == null) {
          return const Center(
            child: Text(
              'No season selected. Please select a season from the dropdown above.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final entries = snapshot.data ?? [];

        if (entries.isEmpty) {
          return const Center(
            child: Text(
              'No scores recorded yet.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                dataRowMaxHeight: double.infinity,
                horizontalMargin: 6,
                headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Rank',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'User',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Total Score',
                      style: defaultHeaderStyle,
                    ),
                  ),
                ],
                rows: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final leaderboardEntry = entry.value;
                  final rank = index + 1;

                  // Highlight top 3
                  Color? rowColor;
                  if (rank == 1) {
                    rowColor = Colors.amber[100];
                  } else if (rank == 2) {
                    rowColor = Colors.grey[300];
                  } else if (rank == 3) {
                    rowColor = Colors.orange[100];
                  }

                  return DataRow(
                    color: rowColor != null
                        ? WidgetStateProperty.all(rowColor)
                        : null,
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            if (rank <= 3)
                              Icon(
                                Icons.emoji_events,
                                color: rank == 1
                                    ? Colors.amber[700]
                                    : rank == 2
                                        ? Colors.grey[700]
                                        : Colors.orange[700],
                                size: 20,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              '$rank',
                              style: TextStyle(
                                fontWeight: rank <= 3
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          leaderboardEntry.userName,
                          style: TextStyle(
                            fontWeight: rank <= 3
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          leaderboardEntry.totalScore.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rank <= 3
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
