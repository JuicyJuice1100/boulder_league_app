import 'package:boulder_league_app/components/scores/scores_form.dart';
import 'package:boulder_league_app/models/base_meta_data.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/models/boulder_filters.dart';
import 'package:boulder_league_app/models/scored_boulder_filters.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/services/scoring_service.dart';
import 'package:boulder_league_app/services/boulder_service.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:boulder_league_app/static/default_scored_boulder_filters.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boulder_league_app/models/scored_boulder.dart';
import 'dart:async';

class ScoresTable extends StatefulWidget {
  const ScoresTable({super.key});

  @override
  State<ScoresTable> createState() => _ScoresTableState();
}

class _ScoresTableState extends State<ScoresTable> {
  final ScoringService _scoreService = ScoringService();
  final SeasonService _seasonService = SeasonService();
  final BoulderService _boulderService = BoulderService();
  List<Boulder> boulders = [];
  Stream<List<ScoredBoulder>>? _scoresStream;

  String? currentSeasonId;
  bool isLoading = false;
  StreamSubscription<Season?>? _seasonSub;
  StreamSubscription<List<Boulder>>? _boulderSub;

  @override
  void initState() {
    super.initState();
    // Subscribe reactively to current season and update boulders/scores when it changes
    setState(() => isLoading = true);
    _seasonSub = _seasonService.getCurrentSeasonForGym('climb_kraft').listen((season) {
      final newSeasonId = season?.id;
      if (newSeasonId == currentSeasonId) {
        // no change
        setState(() => isLoading = false);
        return;
      }

      // update season id and (re)subscribe to boulders and scores
      currentSeasonId = newSeasonId;

      // cancel previous boulder subscription
      _boulderSub?.cancel();
      if (currentSeasonId != null) {
        _boulderSub = _boulderService
          .getBoulders(BoulderFilters(seasonId: currentSeasonId))
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
            gymId: defaultScoredBoulderFilters.gymId,
            seasonId: currentSeasonId,
            uid: FirebaseAuth.instance.currentUser!.uid,
          ));
        });
      } else {
        // no active season
        setState(() {
          boulders = [];
          _scoresStream = null;
        });
      }

      setState(() => isLoading = false);
    });
  }

  @override
  void dispose() {
    _seasonSub?.cancel();
    _boulderSub?.cancel();
    super.dispose();
  }

  void editScore(ScoredBoulder scoredBoulder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.all(16.0),
            child: ScoresForm(scoredBoulder: scoredBoulder),
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

        if (currentSeasonId == null) {
          return Center(
            child: Text('No active season, please set an active season by going to Season')
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
                  DataColumn(label: Text('Boulder')),
                  DataColumn(label: Text('Attempts')),
                  DataColumn(label: Text('Completed')),
                  DataColumn(label: Text('Score')),
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
                                seasonId: currentSeasonId ?? 'Unknown Season',
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