import 'package:boulder_league_app/components/gyms/gyms_form.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:boulder_league_app/styles/default_header.dart';
import 'package:flutter/material.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/services/gym_service.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class GymsTable extends StatefulWidget {
  const GymsTable({super.key});

  @override
  State<GymsTable> createState() => _GymsTableState();
}

class _GymsTableState extends State<GymsTable> {
  final GymService _gymService = GymService();
  final SeasonService _seasonService = SeasonService();
  Stream<List<Gym>>? _gymsStream;
  List<Season> _seasons = [];
  StreamSubscription<List<Season>>? _seasonsSub;

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _updateGyms();
    _loadSeasons();
  }

  @override
  void dispose() {
    _seasonsSub?.cancel();
    super.dispose();
  }

  void _updateGyms() {
    setState(() {
      _gymsStream = _gymService.getGyms();
    });
  }

  void _loadSeasons() {
    _seasonsSub = _seasonService.getSeasons(null).listen((seasons) {
      setState(() {
        _seasons = seasons;
      });
    });
  }

  void _editGym(Gym gym) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.all(16.0),
            child: GymsForm(gym: gym),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Gym>>(
      stream: _gymsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading gyms: ${snapshot.error}'),
          );
        }

        final gyms = snapshot.data ?? [];

        if (gyms.isEmpty) {
          return const Center(child: Text('No gyms found.'));
        }

        // Sort gyms based on current sort settings
        final sortedGyms = List<Gym>.from(gyms);
        sortedGyms.sort((a, b) {
          int comparison = 0;

          switch (_sortColumnIndex) {
            case 0: // Name
              comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
              break;
            case 1: // Active Season
              final seasonA = a.activeSeasonId != null
                  ? _seasons.firstWhere(
                      (s) => s.id == a.activeSeasonId,
                      orElse: () => Season(
                        id: '',
                        name: '',
                        gymId: a.id,
                        startDate: DateTime.now(),
                        endDate: DateTime.now(),
                        baseMetaData: a.baseMetaData,
                      ),
                    )
                  : null;
              final seasonB = b.activeSeasonId != null
                  ? _seasons.firstWhere(
                      (s) => s.id == b.activeSeasonId,
                      orElse: () => Season(
                        id: '',
                        name: '',
                        gymId: b.id,
                        startDate: DateTime.now(),
                        endDate: DateTime.now(),
                        baseMetaData: b.baseMetaData,
                      ),
                    )
                  : null;
              final nameA = seasonA?.name ?? '-';
              final nameB = seasonB?.name ?? '-';
              comparison = nameA.toLowerCase().compareTo(nameB.toLowerCase());
              break;
            case 2: // Created At
              comparison = a.baseMetaData.createdAt.compareTo(b.baseMetaData.createdAt);
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
                    'Active Season',
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
                    'Created At',
                    style: defaultHeaderStyle,
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
              ],
              rows: sortedGyms.map((gym) {
                // Get active season name or '-'
                String activeSeasonName = '-';
                if (gym.activeSeasonId != null) {
                  final activeSeason = _seasons.firstWhere(
                    (s) => s.id == gym.activeSeasonId,
                    orElse: () => Season(
                      id: '',
                      name: '-',
                      gymId: gym.id,
                      startDate: DateTime.now(),
                      endDate: DateTime.now(),
                      baseMetaData: gym.baseMetaData,
                    ),
                  );
                  activeSeasonName = activeSeason.name;
                }

                return DataRow(
                  onSelectChanged: (selected) {
                    if(selected != null && selected) {
                      _editGym(gym);
                    }
                  },
                  cells: [
                    DataCell(Text(gym.name)),
                    DataCell(Text(activeSeasonName)),
                    DataCell(Text(
                      DateFormat.yMd().format(gym.baseMetaData.createdAt),
                    )),
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
