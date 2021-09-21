// import 'package:flutter/material.dart';
// import '../constants.dart';
//
// class NavBar extends StatefulWidget {
//   NavBar({Key? key, required this.widgetOptions, required this.initialPageIndex, required this.updateSelectedIndex}) : super(key: key);
//
//   final List<Widget> widgetOptions;
//   final int initialPageIndex;
//   final void Function(dynamic)? updateSelectedIndex;
//
//   @override
//   NavBarState createState() => NavBarState();
// }
//
// class NavBarState extends State<NavBar> {
//   int _selectedIndex = widget.initialPageIndex;
//
//   void onIconTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     widget.updateSelectedIndex;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(
//               Icons.cottage_outlined,
//               size: 30),
//           title: const Text('Home'),
//           backgroundColor: kDarkGrey,
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(
//             Icons.notifications_outlined,
//             size: 30,
//           ),
//           title: const Text('Notifications'),
//           backgroundColor: kDarkGrey,
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(
//             Icons.person_outlined,
//             size: 30,
//           ),
//           title: const Text('User'),
//           backgroundColor: kDarkGrey,
//         ),
//       ],
//       currentIndex: _selectedIndex,
//       selectedItemColor: kLightBlue,
//       onTap: onIconTapped,
//       showSelectedLabels: false,
//       showUnselectedLabels: false,
//       elevation: 0.0,
//     );
//   }
// }