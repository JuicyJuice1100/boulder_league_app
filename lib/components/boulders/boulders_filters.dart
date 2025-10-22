import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:flutter/material.dart';

class BouldersFilters extends StatelessWidget {
  final String selectedGymId;
  final String? selectedSeasonId;
  final num? selectedWeek;
  final List<Gym> availableGyms;
  final List<Season> availableSeasons;
  final List<num> availableWeeks;
  final void Function(String?) onGymChanged;
  final void Function(String?) onSeasonChanged;
  final void Function(num?) onWeekChanged;

  const BouldersFilters({
    super.key,
    required this.selectedGymId,
    required this.selectedSeasonId,
    required this.selectedWeek,
    required this.availableGyms,
    required this.availableSeasons,
    required this.availableWeeks,
    required this.onGymChanged,
    required this.onSeasonChanged,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
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
                        items: availableGyms.map((gym) {
                          return DropdownMenuItem(
                            value: gym.id,
                            child: Text(gym.name),
                          );
                        }).toList(),
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
                        items: [ 
                           const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All'),
                          ),
                          ...availableSeasons.map((season) {
                            return DropdownMenuItem(
                              value: season.id,
                              child: Text(season.name),
                            );
                          })
                        ],
                        onChanged: onSeasonChanged,
                        hint: const Text('Select a season'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Week',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<num>(
                        value: selectedWeek,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<num>(
                            value: null,
                            child: Text('All'),
                          ),
                          ...availableWeeks.map((week) {
                            return DropdownMenuItem(
                              value: week,
                              child: Text(week.toString()),
                            );
                          }),
                        ],
                        onChanged: onWeekChanged,
                        hint: const Text('Select a week'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
