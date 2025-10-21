import 'package:boulder_league_app/components/seasons/seasons_filters.dart';
import 'package:boulder_league_app/components/seasons/seasons_form.dart';
import 'package:boulder_league_app/components/seasons/seasons_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:flutter/material.dart';

class SeasonsSection extends StatefulWidget {
  const SeasonsSection({super.key});

  @override
  State<SeasonsSection> createState() => _SeasonsSectionState();
}

class _SeasonsSectionState extends State<SeasonsSection> {
  String selectedGymId = 'climb_kraft';

  void _onGymChanged(String? newGymId) {
    if (newGymId == null || newGymId == selectedGymId) return;

    setState(() {
      selectedGymId = newGymId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: 'Seasons',
      filters: SeasonsFilters(
        selectedGymId: selectedGymId,
        onGymChanged: _onGymChanged,
      ),
      table: SeasonsTable(
        selectedGymId: selectedGymId,
      ),
      add: SeasonsForm(),
    );
  }
}