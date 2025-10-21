import 'package:boulder_league_app/models/leaderboard_entry.dart';
import 'package:flutter/material.dart';

class LeaderboardTable extends StatelessWidget {
  final Stream<List<LeaderboardEntry>>? leaderboardStream;
  final bool isLoading;
  final String? selectedSeasonId;

  const LeaderboardTable({
    super.key,
    required this.leaderboardStream,
    required this.isLoading,
    required this.selectedSeasonId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LeaderboardEntry>>(
      stream: leaderboardStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading leaderboard: ${snapshot.error}'),
          );
        }

        if (selectedSeasonId == null) {
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

        return _buildTable(context, entries);
      },
    );
  }

  Widget _buildTable(BuildContext context, List<LeaderboardEntry> entries) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 64,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Rank',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'User',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Boulders Completed',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Total Score',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                        Text(leaderboardEntry.boulderCount.toString()),
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
        ),
      ),
    );
  }
}
