import 'package:flutter/material.dart';
import '../constants.dart';

class NavBar extends StatefulWidget {

  @override
  NavBarState createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  int selectedIndex = 0;

  static const List<Widget> widgetOptions = <Widget>[
    Text(
      'Home',
    ),
    Text(
      'Notifications',
    ),
    Text(
      'User'
    ),
  ];

  void onIconTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Bar'),
      ),
    body: Center(
      child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
                Icons.cottage_outlined,
                size: 30),
            title: const Text('Home'),
            backgroundColor: kDarkGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.notifications_outlined,
                size: 30,
            ),
            title: const Text('Notifications'),
            backgroundColor: kDarkGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.person_outlined,
                size: 30,
            ),
            title: const Text('User'),
            backgroundColor: kDarkGrey,
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: kLightBlue,
        onTap: onIconTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0.0,
      ),
    );
  }
}