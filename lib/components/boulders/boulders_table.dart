import 'package:boulder_league_app/components/boulders/boulders_form.dart';
import 'package:boulder_league_app/models/base_meta_data.dart';
import 'package:boulder_league_app/models/boulder_filters.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/styles/default_header.dart';
import 'package:flutter/material.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/services/boulder_service.dart';

class BouldersTable extends StatefulWidget {
  final String selectedGymId;
  final String? selectedSeasonId;
  final num? selectedWeek;
  final List<Gym> availableGyms;
  final List<Season> availableSeasons;
  final List<num> availableWeeks;

  const BouldersTable({
    super.key,
    required this.selectedGymId,
    required this.selectedSeasonId,
    required this.selectedWeek,
    required this.availableGyms,
    required this.availableSeasons,
    required this.availableWeeks
  });

  @override
  State<BouldersTable> createState() => _BouldersTableState();
}

class _BouldersTableState extends State<BouldersTable> {
  final BoulderService _boulderService = BoulderService();

  Stream<List<Boulder>>? _bouldersStream;

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _updateBoulders();
  }

  @override
  void didUpdateWidget(BouldersTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-fetch data when filters change
    if (oldWidget.selectedGymId != widget.selectedGymId ||
        oldWidget.selectedSeasonId != widget.selectedSeasonId ||
        oldWidget.selectedWeek != widget.selectedWeek) {
      _updateBoulders();
    }
  }

  void _updateBoulders() {
    setState(() {
      _bouldersStream = _boulderService.getBoulders(BoulderFilters(
        gymId: widget.selectedGymId,
        seasonId: widget.selectedSeasonId,
        week: widget.selectedWeek
      ));
    });
  }

  void _editBoulder(Boulder boulder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.all(16.0),
              child: BouldersForm(
                boulder: boulder,
                availableGyms: widget.availableGyms,
                availableSeasons: widget.availableSeasons,
                availableWeeks: widget.availableWeeks
              ),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Boulder>>(
      stream: _bouldersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading boulders: ${snapshot.error}'),
          );
        }

        final boulders = snapshot.data ?? [];

        if (boulders.isEmpty) {
          return const Center(child: Text('No boulders found.'));
        }

        // Sort boulders based on current sort settings
        final sortedBoulders = List<Boulder>.from(boulders);
        sortedBoulders.sort((a, b) {
          int comparison = 0;

          switch (_sortColumnIndex) {
            case 0: // Name
              comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
              break;
            case 1: // Gym
              final gymA = widget.availableGyms.firstWhere(
                (g) => g.id == a.gymId,
                orElse: () => Gym(
                  id: a.gymId,
                  name: a.gymId,
                  baseMetaData: a.baseMetaData,
                ),
              );
              final gymB = widget.availableGyms.firstWhere(
                (g) => g.id == b.gymId,
                orElse: () => Gym(
                  id: b.gymId,
                  name: b.gymId,
                  baseMetaData: b.baseMetaData,
                ),
              );
              comparison = gymA.name.toLowerCase().compareTo(gymB.name.toLowerCase());
              break;
            case 2: // Week
              comparison = a.week.compareTo(b.week);
              break;
            case 3: // Season
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
                    lastUpdateByUid: ''
                  )
                )
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
                    lastUpdateByUid: ''
                  )
                )
              );
              comparison = seasonA.name.toLowerCase().compareTo(seasonB.name.toLowerCase());
              break;
          }

          return _sortAscending ? comparison : -comparison;
        });

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              showCheckboxColumn: false,
              headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
              columns: [
                DataColumn(
                  label: const Text(
                    'Name',
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
                    'Gym',
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
                    'Season',
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
              rows: sortedBoulders.map((boulder) {
                final gym = widget.availableGyms.firstWhere(
                  (g) => g.id == boulder.gymId,
                  orElse: () => Gym(
                    id: boulder.gymId,
                    name: boulder.gymId,
                    baseMetaData: boulder.baseMetaData,
                  ),
                );

                return DataRow(
                  onSelectChanged: (selected) {
                    if(selected != null && selected) {
                      _editBoulder(boulder);
                    }
                  },
                  cells: [
                    DataCell(Text(boulder.name)),
                    DataCell(Text(gym.name)),
                    DataCell(Text(boulder.week.toString())),
                    DataCell(() {
                      final season = widget.availableSeasons.firstWhere(
                        (season) => season.id == boulder.seasonId,
                        orElse: () => Season(
                          id: boulder.seasonId,
                          name: 'Unknown Season',
                          gymId: boulder.gymId,
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
                    }()),
                  ],
                );
              }).toList(),
            ),
          )
        );
      },
    );
  }
}