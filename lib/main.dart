import 'package:flutter/material.dart';
import 'package:youthapp/Screens/Login/login.dart';
import 'package:youthapp/Screens/Signup/signup.dart';
import 'Screens/Welcome/welcome.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}
