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
    Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Home'),
          ]
        )
      ),
    ),
    Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Report'),
          ]
        )
      ),
    ),
    Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Add'),
          ]
        )
      ),
    )
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar (
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.blueGrey,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home'
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
    );
  }
}