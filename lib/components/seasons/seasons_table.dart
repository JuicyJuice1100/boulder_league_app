import 'package:boulder_league_app/components/seasons/season_form.dart';
import 'package:flutter/material.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:boulder_league_app/static/defaultSeasonFilters.dart';

class SeasonsTable extends StatefulWidget {
  const SeasonsTable({super.key});

  @override
  State<SeasonsTable> createState() => _SeasonsTableState();
}

class _SeasonsTableState extends State<SeasonsTable> {
  final SeasonService _seasonService = SeasonService();

  void _editSeason(Season season) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.all(16.0),
              child: SeasonCardForm(season: season),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Season>>(
      stream: _seasonService.getSeasons(defaultSeasonFilters),
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
                headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(label: Text('Gym')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Start Date')),
                  DataColumn(label: Text('End Date')),
                  DataColumn(label: Text('Active')),
                  DataColumn(label: Text('')), // New column for buttons
                ],
                rows: seasons.map((season) {
                  return DataRow(
                    cells: [
                      DataCell(Text(season.gymId)),
                      DataCell(Text(season.name)),
                      DataCell(Text(
                        season.startDate.toString().split(' ')[0],
                      )),
                      DataCell(Text(
                        season.endDate.toString().split(' ')[0],
                      )),
                      DataCell(Icon(
                        season.isActive ? Icons.check_circle : Icons.cancel,
                        color: season.isActive ? Colors.green : Colors.red,
                      )),
                      // Actions cell
                      DataCell(Row(
                        children: [
                          ElevatedButton.icon(
                            label: Text('Edit'),
                            icon: Icon(Icons.edit),
                            onPressed: () => _editSeason(season),
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
