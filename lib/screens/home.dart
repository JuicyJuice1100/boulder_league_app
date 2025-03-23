import 'package:boulder_league_app/app_global.dart';
import 'package:boulder_league_app/components/add_boulder_card.dart';
import 'package:boulder_league_app/components/leaderboard_card.dart';
import 'package:boulder_league_app/components/record_score_card.dart';
import 'package:boulder_league_app/screens/user.dart';
import 'package:boulder_league_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const routeName = '/home';
  
  int selectedIndex = 0;

  final List<Widget> widgetOptions = const [
    LeaderboardCard(),
    RecordScoreCardForm(),
    AddBoulderCardForm()
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  var currentUser = AuthService().getCurrentUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppGlobal.title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: UserScreen(),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: AuthService().logout,
            ),
          ]
        )
      ),
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar (
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.blueGrey,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Leaderboard'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add_check_outlined),
            label: 'Record Score',
            tooltip: 'Report your score',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_outlined),
            label: 'Add Boulder',
            tooltip: 'Add a new boulder for users'
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}