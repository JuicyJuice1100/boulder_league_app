import 'package:boulder_league_app/components/gyms/gyms_form.dart';
import 'package:boulder_league_app/components/gyms/gyms_table.dart';
import 'package:boulder_league_app/components/section.dart';
import 'package:flutter/material.dart';

class GymsSection extends StatelessWidget {
  const GymsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: 'Gyms',
      table: GymsTable(),
      add: GymsForm(),
    );
  }
}
