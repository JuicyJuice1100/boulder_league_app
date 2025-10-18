import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final Widget table;

  const SectionWidget({
    super.key,
    required this.title,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min, // shrink-wrap content
            children: [
              Card(
                margin: EdgeInsets.all(20.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: table,
                )
              ),
            ],
          ),
      )
    );
  }
}
