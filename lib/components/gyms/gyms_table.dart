import 'package:boulder_league_app/components/gyms/gyms_form.dart';
import 'package:boulder_league_app/styles/default_header.dart';
import 'package:flutter/material.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/services/gym_service.dart';

class GymsTable extends StatefulWidget {
  const GymsTable({super.key});

  @override
  State<GymsTable> createState() => _GymsTableState();
}

class _GymsTableState extends State<GymsTable> {
  final GymService _gymService = GymService();
  Stream<List<Gym>>? _gymsStream;

  @override
  void initState() {
    super.initState();
    _updateGyms();
  }

  void _updateGyms() {
    setState(() {
      _gymsStream = _gymService.getGyms();
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
                      'Name',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Created At',
                      style: defaultHeaderStyle,
                    ),
                  ),
                  DataColumn(label: Text('')), // Actions column
                ],
                rows: gyms.map((gym) {
                  return DataRow(
                    cells: [
                      DataCell(Text(gym.name)),
                      DataCell(Text(
                        gym.baseMetaData.createdAt.toString().split(' ')[0],
                      )),
                      DataCell(Row(
                        children: [
                          ElevatedButton.icon(
                            label: const Text('Edit'),
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editGym(gym),
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
