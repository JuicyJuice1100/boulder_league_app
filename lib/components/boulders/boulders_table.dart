import 'package:boulder_league_app/components/boulders/boulders_form.dart';
import 'package:flutter/material.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/services/boulder_service.dart';
import 'package:boulder_league_app/static/default_boulder_filters.dart';

class BouldersTable extends StatefulWidget {
  const BouldersTable({super.key});

  @override
  State<BouldersTable> createState() => _BouldersTableState();
}

class _BouldersTableState extends State<BouldersTable> {
  final BoulderService _boulderService = BoulderService();

  void _editBoulder(Boulder boulder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.all(16.0),
              child: BouldersForm(boulder: boulder),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Boulder>>(
      stream: _boulderService.getBoulders(defaultBoulderFilters),
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

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(label: Text('Gym')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Week')),
                  DataColumn(label: Text('Season')),
                  DataColumn(label: Text('')), // Actions column
                ],
                rows: boulders.map((boulder) {
                  return DataRow(
                    cells: [
                      DataCell(Text(boulder.gymId)),
                      DataCell(Text(boulder.name)),
                      DataCell(Text(boulder.week.toString())),
                      DataCell(Text(boulder.seasonId)),
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