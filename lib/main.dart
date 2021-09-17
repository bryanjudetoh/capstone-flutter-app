import 'package:flutter/material.dart';
import 'package:youthapp/Screens/welcome.dart';
import 'package:youthapp/Screens/login.dart';
import 'package:youthapp/screens/onboarding.dart';
import 'package:youthapp/screens/signup.dart';
import 'package:youthapp/screens/forgotpw.dart';
import 'package:youthapp/screens/home.dart';
import 'package:youthapp/screens/verification.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

String? currentAccessToken = null;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SecureStorage secureStorage = SecureStorage();
  currentAccessToken = await secureStorage.readSecureData('accessToken');
  if (currentAccessToken == null) {
    print('no token');
  } else {
    print('THERE IS A TOKEN');
    print(currentAccessToken);
  }
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youth App',
      debugShowCheckedModeBanner: false,
      initialRoute: currentAccessToken!.isEmpty || JwtDecoder.isExpired(currentAccessToken!) ? '/' : '/home',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/forgotpw': (context) => ForgotPasswordScreen(),
        '/signup': (context) => SignUpScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/home': (context) => HomeScreen(),
        '/verification': (context) => VerificationScreen(),
      }
    );
  }
}
