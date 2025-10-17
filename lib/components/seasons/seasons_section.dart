import 'package:boulder_league_app/components/seasons/add_season_card.dart';
import 'package:boulder_league_app/components/seasons/seasons_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:flutter/material.dart';

class SeasonsSection extends StatelessWidget {
  const SeasonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionWidget(title: 'Seasons', addForm: AddSeasonCardForm(), table: SeasonsTable());
  }
}