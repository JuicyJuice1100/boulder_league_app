import 'package:boulder_league_app/app_global.dart';
import 'package:boulder_league_app/components/boulders/boulders_section.dart';
import 'package:boulder_league_app/components/leaderboards/leaderboard_section.dart';
import 'package:boulder_league_app/components/scores/scores_section.dart';
import 'package:boulder_league_app/components/seasons/seasons_section.dart';
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
    LeaderboardSection(),
    ScoresSection(),
    BouldersSection(),
    SeasonsSection()
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        centerTitle: true,
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
              decoration: BoxDecoration(
                color: Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5
                  )
                ]
              ),
              child: UserScreen(),
            ),
            // TODO: disabling for now until this feature is ready
            // ListTile(
            //   leading: const Icon(Icons.account_box),
            //   title: const Text('Account Info'),
            //   onTap: () {
            //     AppGlobal.navigatorKey.currentState!.pushNamed(AccountScreen.routeName);
            //   },
            // ),
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
            icon: Icon(Icons.check),
            label: 'Score',
            tooltip: 'Report/Update your score for boulders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc),
            label: 'Boulders',
            tooltip: 'Add/Update a new boulder for users'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.numbers),
            label: 'Seasons',
            tooltip: 'Add/Update a new boulder season for users'
          )
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}