import 'package:boulder_league_app/components/boulders/boulders_form.dart';
import 'package:boulder_league_app/models/base_meta_data.dart';
import 'package:boulder_league_app/models/boulder_filters.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:flutter/material.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/services/boulder_service.dart';

class BouldersTable extends StatefulWidget {
  final String selectedGymId;
  final String? selectedSeasonId;
  final List<Gym> availableGyms;
  final List<Season> availableSeasons;

  const BouldersTable({
    super.key,
    required this.selectedGymId,
    required this.selectedSeasonId,
    required this.availableGyms,
    required this.availableSeasons,
  });

  @override
  State<BouldersTable> createState() => _BouldersTableState();
}

class _BouldersTableState extends State<BouldersTable> {
  final BoulderService _boulderService = BoulderService();

  Stream<List<Boulder>>? _bouldersStream;

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
        oldWidget.selectedSeasonId != widget.selectedSeasonId) {
      _updateBoulders();
    }
  }

  void _updateBoulders() {
    if (widget.selectedSeasonId == null) {
      setState(() {
        _bouldersStream = null;
      });
      return;
    }

    setState(() {
      _bouldersStream = _boulderService.getBoulders(BoulderFilters(
        gymId: widget.selectedGymId,
        seasonId: widget.selectedSeasonId,
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

        if (widget.selectedSeasonId == null) {
          return const Center(
            child: Text('No season selected. Please select a season from the dropdown above.')
          );
        }

        final boulders = snapshot.data ?? [];

        if (boulders.isEmpty) {
          return const Center(child: Text('No boulders found.'));
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
                      'Gym',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Week',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Season',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(label: Text('')), // Actions column
                ],
                rows: boulders.map((boulder) {
                  final gym = widget.availableGyms.firstWhere(
                    (g) => g.id == boulder.gymId,
                    orElse: () => Gym(
                      id: boulder.gymId,
                      name: boulder.gymId,
                      baseMetaData: boulder.baseMetaData,
                    ),
                  );

                  return DataRow(
                    cells: [
                      DataCell(Text(gym.name)),
                      DataCell(Text(boulder.name)),
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
                            isActive: false,
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
                      DataCell(Row(
                        children: [
                          ElevatedButton.icon(
                            label: const Text('Edit'),
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editBoulder(boulder),
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