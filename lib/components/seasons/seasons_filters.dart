import 'package:boulder_league_app/models/gym.dart';
import 'package:flutter/material.dart';

class SeasonsFilters extends StatelessWidget {
  final String selectedGymId;
  final List<Gym> availableGyms;
  final void Function(String?) onGymChanged;

  const SeasonsFilters({
    super.key,
    required this.selectedGymId,
    required this.availableGyms,
    required this.onGymChanged,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
