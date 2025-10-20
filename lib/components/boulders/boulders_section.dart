import 'package:boulder_league_app/components/boulders/boulders_form.dart';
import 'package:boulder_league_app/components/boulders/boulders_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:flutter/material.dart';

class BouldersSection extends StatelessWidget {
  const BouldersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionWidget(title: 'Boulders', table: BouldersTable(), add: BouldersForm());
  }
}