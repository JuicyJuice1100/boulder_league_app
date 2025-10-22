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

    if (widget.selectedSeasonId != null) {
      _boulderSub = _boulderService
          .getBoulders(BoulderFilters(
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

      // update scores stream to use the new season id
      setState(() {
        _scoresStream = _scoreService.getScores(ScoredBoulderFilters(
          gymId: widget.selectedGymId,
          seasonId: widget.selectedSeasonId,
          week: widget.selectedWeek,
          uid: FirebaseAuth.instance.currentUser!.uid,
        ));
      });
    } else {
      // no season selected
      setState(() {
        boulders = [];
        _scoresStream = null;
      });
    }

    setState(() => isLoading = false);
  }

  void editScore(ScoredBoulder scoredBoulder) {
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

        if (widget.selectedSeasonId == null) {
          return const Center(
            child: Text('No season selected. Please select a season from the dropdown above.')
          );
        }

        final scoredBoulders = snapshot.data ?? [];

        if (scoredBoulders.isEmpty) {
          return const Center(child: Text('No scores found.'));
        }

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Boulder',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Attempts',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Completed',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Score',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(label: Text('')), // Actions column
                ],
                rows: scoredBoulders.map((scoredBoulder) {
                  return DataRow(
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
                      DataCell(Text(scoredBoulder.attempts.toString())),
                      DataCell(Icon(
                        scoredBoulder.completed ? Icons.check_circle : Icons.cancel,
                        color: scoredBoulder.completed ? Colors.green : Colors.red,
                      )),
                      DataCell(Text(scoredBoulder.score.toString())),
                      DataCell(Row(
                        children: [
                          ElevatedButton.icon(
                            label: const Text('Edit'),
                            icon: const Icon(Icons.edit),
                            onPressed: () => editScore(scoredBoulder),
                          ),
                        ],
                      )),
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