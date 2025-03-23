import 'package:flutter/material.dart';

class LeaderboardCard extends StatefulWidget {
  const LeaderboardCard({super.key});

  @override
  State<LeaderboardCard> createState() => LeaderboardCardState();
}

class LeaderboardCardState extends State<LeaderboardCard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Card(
                margin: EdgeInsets.all(20.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Leaderboard TBA')
                )
              )
            )
          ]
        )
      ),
    );
  }
}