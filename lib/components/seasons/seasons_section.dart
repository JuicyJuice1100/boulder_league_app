import 'package:boulder_league_app/components/seasons/seasons_filters.dart';
import 'package:boulder_league_app/components/seasons/seasons_form.dart';
import 'package:boulder_league_app/components/seasons/seasons_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/services/gym_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SeasonsSection extends StatefulWidget {
  const SeasonsSection({super.key});

  @override
  State<SeasonsSection> createState() => _SeasonsSectionState();
}

class _SeasonsSectionState extends State<SeasonsSection> {
  final GymService _gymService = GymService();

  String selectedGymId = '';
  List<Gym> availableGyms = [];
  StreamSubscription<List<Gym>>? _gymsSub;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  @override
  void dispose() {
    _gymsSub?.cancel();
    super.dispose();
  }

  void _loadGyms() {
    _gymsSub = _gymService.getGyms().listen((gyms) {
      setState(() {
        availableGyms = gyms;
        if (gyms.isNotEmpty && selectedGymId.isEmpty) {
          selectedGymId = gyms.first.id;
        }
      });
    });
  }

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
        availableGyms: availableGyms,
        onGymChanged: _onGymChanged,
      ),
      table: SeasonsTable(
        selectedGymId: selectedGymId,
        availableGyms: availableGyms,
      ),
      add: SeasonsForm(
        availableGyms: availableGyms,
      ),
    );
  }
}