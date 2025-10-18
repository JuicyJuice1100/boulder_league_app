import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final Widget add;
  final Widget table;

  const SectionWidget({
    super.key,
    required this.title,
    required this.add,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          margin: EdgeInsets.all(20.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // shrink-wrap content
              spacing: 10,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: FilledButton.icon(
                    label: Text('Add ${title}'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            padding: EdgeInsets.all(16.0),
                              child: add,
                          )
                        )
                      );
                    },
                    icon: Icon(Icons.add),
                  )
                ),
                table
              ]
            ),
          )
        ),
      )
    );
  }
}
