import 'package:boulder_league_app/components/scores/scores_form.dart';
import 'package:boulder_league_app/components/scores/scores_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:flutter/material.dart';

class ScoresSection extends StatelessWidget {
  const ScoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionWidget(title: 'Scores', table: ScoresTable(), add: ScoresForm());
  }
}