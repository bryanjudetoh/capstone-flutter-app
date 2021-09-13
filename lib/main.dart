import 'package:flutter/material.dart';
import 'package:youthapp/Screens/login.dart';
import 'package:youthapp/screens/onboarding.dart';
import 'package:youthapp/screens/signup.dart';
import 'package:youthapp/screens/forgotpw.dart';
import 'package:youthapp/screens/home.dart';
import 'Screens/welcome.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youth App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/forgotpw': (context) => ForgotPasswordScreen(),
        '/signup': (context) => SignUpScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/home': (context) => HomeScreen(),
      }
    );
  }
}
