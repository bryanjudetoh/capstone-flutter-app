import 'package:flutter/material.dart';
import 'package:youthapp/Screens/login.dart';
import 'package:youthapp/Screens/signup.dart';
import 'package:youthapp/Screens/forgotpw.dart';
import 'Screens/welcome.dart';
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
        '/forgotpw': (context) => ForgotPasswordScreen(),
      },
    );
  }
}
