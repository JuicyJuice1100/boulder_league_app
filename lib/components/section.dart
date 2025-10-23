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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filters Section
            if (filters != null)
              Card(
                margin: EdgeInsets.all(20.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: filters!,
                ),
              ),
            Card(
              margin: EdgeInsets.all(20.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  spacing: 10,
                  children: [
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
                    table,
                  ],
                )
              )
            )
          ],
        ),
      ),
    );
  }
}
