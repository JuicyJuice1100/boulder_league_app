import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:flutter/material.dart';

class LeaderboardFilters extends StatelessWidget {
  final String? selectedGymId;
  final String? selectedSeasonId;
  final List<Gym> availableGyms;
  final List<Season> availableSeasons;
  final void Function(String?) onGymChanged;
  final void Function(String?) onSeasonChanged;

  const LeaderboardFilters({
    super.key,
    required this.selectedGymId,
    required this.selectedSeasonId,
    required this.availableGyms,
    required this.availableSeasons,
    required this.onGymChanged,
    required this.onSeasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Gym',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGymId,
                      isExpanded: true,
                      items: availableGyms.isNotEmpty ? availableGyms.map((gym) {
                        return DropdownMenuItem(
                          value: gym.id,
                          child: Text(gym.name),
                        );
                      }).toList() : [
                        DropdownMenuItem(
                          value: null,
                          child: Text('No Season Available')
                      )],
                      onChanged: onGymChanged,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Season',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSeasonId,
                      isExpanded: true,
                      items: availableSeasons.isNotEmpty
                        ? () {
                            // Remove duplicates based on season ID
                            final seen = <String>{};
                            final uniqueSeasons = availableSeasons.where((season) {
                              return seen.add(season.id);
                            }).toList();

                            return uniqueSeasons.map((season) {
                              return DropdownMenuItem(
                                value: season.id,
                                child: Text(season.name),
                              );
                            }).toList();
                          }()
                        : [
                            DropdownMenuItem(
                              value: null,
                              child: Text('No Season Available')
                            )
                          ],
                      onChanged: onSeasonChanged,
                      hint: const Text('Select a season'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
