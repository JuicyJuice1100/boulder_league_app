import 'package:boulder_league_app/components/seasons/seasons_form.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/styles/default_header.dart';
import 'package:flutter/material.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/models/season_filters.dart';
import 'package:boulder_league_app/services/season_service.dart';

class SeasonsTable extends StatefulWidget {
  final String selectedGymId;
  final List<Gym> availableGyms;

  const SeasonsTable({
    super.key,
    required this.selectedGymId,
    required this.availableGyms,
  });

  @override
  State<SeasonsTable> createState() => _SeasonsTableState();
}

class _SeasonsTableState extends State<SeasonsTable> {
  final SeasonService _seasonService = SeasonService();
  Stream<List<Season>>? _seasonsStream;

  @override
  void initState() {
    super.initState();
    _updateSeasons();
  }

  @override
  void didUpdateWidget(SeasonsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-fetch data when filters change
    if (oldWidget.selectedGymId != widget.selectedGymId) {
      _updateSeasons();
    }
  }

  void _updateSeasons() {
    setState(() {
      _seasonsStream = _seasonService.getSeasons(SeasonFilters(
        gymId: widget.selectedGymId,
      ));
    });
  }

  void _editSeason(Season season) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.all(16.0),
              child: SeasonsForm(
                season: season,
                availableGyms: widget.availableGyms,
              ),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Season>>(
      stream: _seasonsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading seasons: ${snapshot.error}'),
          );
        }

        final seasons = snapshot.data ?? [];

        if (seasons.isEmpty) {
          return const Center(child: Text('No seasons found.'));
        }

        // Wrap table in Expanded so it fills parent height
        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width, // full width
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Name',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Start Date',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'End Date',
                      style: defaultHeaderStyle,
                    ),
                  )
                ],
                rows: seasons.map((season) {
                  final gym = widget.availableGyms.firstWhere(
                    (g) => g.id == season.gymId,
                    orElse: () => Gym(
                      id: season.gymId,
                      name: season.gymId,
                      baseMetaData: season.baseMetaData,
                    ),
                  );

                  return DataRow(
                    color:  WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                      if (season.id == gym.activeSeasonId) {
                        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
                      }
                      return null;  // Use the default value.
                    }),
                    onSelectChanged: (selected) {
                      if(selected != null && selected) {
                        _editSeason(season);
                      }
                    },
                    cells: [
                      DataCell(Text(season.name)),
                      DataCell(Text(
                        season.startDate.toString().split(' ')[0],
                      )),
                      DataCell(Text(
                        season.endDate.toString().split(' ')[0],
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
