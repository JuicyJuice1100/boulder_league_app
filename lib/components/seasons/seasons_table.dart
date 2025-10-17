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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seasons')),
      body: StreamBuilder<List<Season>>(
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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Start Date')),
                DataColumn(label: Text('End Date')),
                DataColumn(label: Text('Created By')),
                DataColumn(label: Text('Active')),
              ],
              rows: seasons.map((season) {
                return DataRow(
                  cells: [
                    DataCell(Text(season.name)),
                    DataCell(Text(
                      season.startDate != null
                          ? season.startDate.toString().split(' ')[0]
                          : '-',
                    )),
                    DataCell(Text(
                      season.endDate != null
                          ? season.endDate.toString().split(' ')[0]
                          : '-',
                    )),
                    DataCell(Text(season.createdByUid ?? 'Unknown')),
                    DataCell(Icon(
                      season.isActive ? Icons.check_circle : Icons.cancel,
                      color: season.isActive ? Colors.green : Colors.red,
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
