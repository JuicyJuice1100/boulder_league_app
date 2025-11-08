import 'package:boulder_league_app/components/scores/scores_form.dart';
import 'package:boulder_league_app/models/base_meta_data.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/models/boulder_filters.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/models/scored_boulder_filters.dart';
import 'package:boulder_league_app/services/scoring_service.dart';
import 'package:boulder_league_app/services/boulder_service.dart';
import 'package:boulder_league_app/styles/default_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boulder_league_app/models/scored_boulder.dart';
import 'dart:async';

class ScoresTable extends StatefulWidget {
  final String selectedGymId;
  final String? selectedSeasonId;
  final num? selectedWeek;
  final List<Gym> availableGyms;
  final List<Season> availableSeasons;
  final List<num> availableWeeks;

  const ScoresTable({
    super.key,
    required this.selectedGymId,
    required this.selectedSeasonId,
    required this.selectedWeek,
    required this.availableGyms,
    required this.availableSeasons,
    required this.availableWeeks
  });

  @override
  State<ScoresTable> createState() => _ScoresTableState();
}

class _ScoresTableState extends State<ScoresTable> {
  final ScoringService _scoreService = ScoringService();
  final BoulderService _boulderService = BoulderService();
  List<Boulder> boulders = [];
  Stream<List<ScoredBoulder>>? _scoresStream;

  bool isLoading = false;
  StreamSubscription<List<Boulder>>? _boulderSub;

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _updateScoresAndBoulders();
  }

  @override
  void didUpdateWidget(ScoresTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-fetch data when filters change
    if (oldWidget.selectedGymId != widget.selectedGymId ||
        oldWidget.selectedSeasonId != widget.selectedSeasonId ||
        oldWidget.selectedWeek != widget.selectedWeek) {
      _updateScoresAndBoulders();
    }
  }

  @override
  void dispose() {
    _boulderSub?.cancel();
    super.dispose();
  }

  void _updateScoresAndBoulders() {
    setState(() => isLoading = true);

    // Cancel previous boulder subscription
    _boulderSub?.cancel();

    // Fetch boulders with current filters (null seasonId means all seasons)
    _boulderSub = _boulderService
        .getBoulders(BoulderFilters(
          gymId: widget.selectedGymId,
          seasonId: widget.selectedSeasonId,
          week: widget.selectedWeek,
        ))
        .listen((list) {
      setState(() {
        boulders = list;
      });
    }, onError: (err) {
      // ignore or log
    });

    // update scores stream to use current filters
    setState(() {
      _scoresStream = _scoreService.getScores(ScoredBoulderFilters(
        gymId: widget.selectedGymId,
        seasonId: widget.selectedSeasonId,
        week: widget.selectedWeek,
        uid: FirebaseAuth.instance.currentUser!.uid,
      ));
    });

    setState(() => isLoading = false);
  }

  void _editScore(ScoredBoulder scoredBoulder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.all(16.0),
            child: ScoresForm(
              scoredBoulder: scoredBoulder,
              availableGyms: widget.availableGyms,
              availableSeasons: widget.availableSeasons,
              availableWeeks: widget.availableWeeks,
            ),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScoredBoulder>>(
      stream: _scoresStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading scores: ${snapshot.error}'),
          );
        }

        final scoredBoulders = snapshot.data ?? [];

        if (scoredBoulders.isEmpty) {
          return const Center(child: Text('No scores found.'));
        }

        // Sort scored boulders based on current sort settings
        final sortedScoredBoulders = List<ScoredBoulder>.from(scoredBoulders);
        sortedScoredBoulders.sort((a, b) {
          int comparison = 0;

          switch (_sortColumnIndex) {
            case 0: // Boulder name
              final boulderA = boulders.firstWhere(
                (boulder) => boulder.id == a.boulderId,
                orElse: () => Boulder(
                  id: a.boulderId,
                  name: 'Unknown Boulder',
                  gymId: a.gymId,
                  week: 0,
                  seasonId: widget.selectedSeasonId ?? '',
                  baseMetaData: BaseMetaData(
                    createdAt: DateTime.now(),
                    lastUpdateAt: DateTime.now(),
                    createdByUid: '',
                    lastUpdateByUid: '',
                  ),
                ),
              );
              final boulderB = boulders.firstWhere(
                (boulder) => boulder.id == b.boulderId,
                orElse: () => Boulder(
                  id: b.boulderId,
                  name: 'Unknown Boulder',
                  gymId: b.gymId,
                  week: 0,
                  seasonId: widget.selectedSeasonId ?? '',
                  baseMetaData: BaseMetaData(
                    createdAt: DateTime.now(),
                    lastUpdateAt: DateTime.now(),
                    createdByUid: '',
                    lastUpdateByUid: '',
                  ),
                ),
              );
              comparison = boulderA.name.toLowerCase().compareTo(boulderB.name.toLowerCase());
              break;
            case 1: // Season
              final seasonA = widget.availableSeasons.firstWhere(
                (season) => season.id == a.seasonId,
                orElse: () => Season(
                  id: a.seasonId,
                  name: 'Unknown Season',
                  gymId: a.gymId,
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                  baseMetaData: BaseMetaData(
                    createdAt: DateTime.now(),
                    lastUpdateAt: DateTime.now(),
                    createdByUid: '',
                    lastUpdateByUid: '',
                  ),
                ),
              );
              final seasonB = widget.availableSeasons.firstWhere(
                (season) => season.id == b.seasonId,
                orElse: () => Season(
                  id: b.seasonId,
                  name: 'Unknown Season',
                  gymId: b.gymId,
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                  baseMetaData: BaseMetaData(
                    createdAt: DateTime.now(),
                    lastUpdateAt: DateTime.now(),
                    createdByUid: '',
                    lastUpdateByUid: '',
                  ),
                ),
              );
              comparison = seasonA.name.toLowerCase().compareTo(seasonB.name.toLowerCase());
              break;
            case 2: // Week
              comparison = a.week.compareTo(b.week);
              break;
            case 3: // Attempts
              comparison = a.attempts.compareTo(b.attempts);
              break;
            case 4: // Completed
              comparison = (a.completed ? 1 : 0).compareTo(b.completed ? 1 : 0);
              break;
            case 5: // Score
              comparison = a.score.compareTo(b.score);
              break;
          }

          return _sortAscending ? comparison : -comparison;
        });

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              showCheckboxColumn: false,
              headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
              columns: [
                DataColumn(
                  label: const Text(
                    'Boulder',
                    style: defaultHeaderStyle,
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: const Text(
                    'Season',
                    style: defaultHeaderStyle,
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: const Text(
                    'Week',
                    style: defaultHeaderStyle,
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: const Text(
                    'Attempts',
                    style: defaultHeaderStyle,
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: const Text(
                    'Completed',
                    style: defaultHeaderStyle,
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: const Text(
                    'Score',
                    style: defaultHeaderStyle,
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                )
              ],
              rows: sortedScoredBoulders.map((scoredBoulder) {
                return DataRow(
                  onSelectChanged: (selected) {
                    if(selected != null && selected) {
                      _editScore(scoredBoulder);
                    }
                  },
                  cells: [
                    DataCell(
                      Builder(
                        builder: (context) {
                          if (isLoading) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)
                            );
                          }

                          final boulder = boulders.firstWhere(
                            (b) => b.id == scoredBoulder.boulderId,
                            orElse: () => Boulder(
                              id: scoredBoulder.boulderId,
                              name: 'Unknown Boulder',
                              gymId: scoredBoulder.gymId,
                              week: 0,
                              seasonId: widget.selectedSeasonId ?? 'Unknown Season',
                              baseMetaData: BaseMetaData(
                                createdAt: DateTime.now(),
                                lastUpdateAt: DateTime.now(),
                                createdByUid: '',
                                lastUpdateByUid: ''
                              )
                            )
                          );

                          return Text(boulder.name);
                        }
                      )
                    ),
                    DataCell(
                      Builder(
                        builder: (context) {
                          if (isLoading) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)
                            );
                          }

                          final season = widget.availableSeasons.firstWhere(
                            (s) => s.id == scoredBoulder.seasonId,
                            orElse: () => Season(
                              id: scoredBoulder.seasonId,
                              name: 'Unknown Season',
                              gymId: scoredBoulder.gymId,
                              startDate: DateTime.now(),
                              endDate: DateTime.now(),
                              baseMetaData: BaseMetaData(
                                createdAt: DateTime.now(),
                                lastUpdateAt: DateTime.now(),
                                createdByUid: '',
                                lastUpdateByUid: ''
                              )
                            )
                          );

                          return Text(season.name);
                        }
                      )
                    ),
                    DataCell(Text(scoredBoulder.week.toString())),
                    DataCell(Text(scoredBoulder.attempts.toString())),
                    DataCell(Icon(
                      scoredBoulder.completed ? Icons.check_circle : Icons.cancel,
                      color: scoredBoulder.completed ? Colors.green : Colors.red,
                    )),
                    DataCell(Text(scoredBoulder.score.toString()))
                  ],
                );
              }).toList(),
              ),
            ),
          )
        );
      },
    );
  }
}