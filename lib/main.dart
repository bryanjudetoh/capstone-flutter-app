import 'package:flutter/material.dart';
import 'Screens/Welcome/welcome_screen.dart';
import 'package:youthapp/constants.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kWhite,
      ),
      home: WelcomeScreen(),
    );
  }
}
