import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final Widget? add;
  final Widget? filters;
  final Widget table;

  const SectionWidget({
    super.key,
    required this.title,
    this.add,
    this.filters,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          // Filters Section
          if (filters != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: filters!,
            ),

          // Add Button Section
          if (add != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  label: Text('Add $title'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: EdgeInsets.all(16.0),
                          child: add,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                ),
              ),
            ),

          // Table Section
          Expanded(
            child: table,
          ),
        ],
      ),
    );
  }
}
