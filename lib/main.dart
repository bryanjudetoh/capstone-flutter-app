import 'package:flutter/material.dart';
import 'package:youthapp/Screens/welcome.dart';
import 'package:youthapp/Screens/login.dart';
import 'package:youthapp/screens/activity-details.dart';
import 'package:youthapp/screens/view-activities.dart';
import 'package:youthapp/screens/change-password.dart';
import 'package:youthapp/screens/edit-account-details.dart';
import 'package:youthapp/screens/onboarding.dart';
import 'package:youthapp/screens/organisation-details.dart';
import 'package:youthapp/screens/search.dart';
import 'package:youthapp/screens/signup.dart';
import 'package:youthapp/screens/fb-signup.dart';
import 'package:youthapp/screens/forgot-password.dart';
import 'package:youthapp/screens/init-home.dart';
import 'package:youthapp/screens/verification.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:youthapp/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String? currentAccessToken;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SecureStorage secureStorage = SecureStorage();
  currentAccessToken = await secureStorage.readSecureData('accessToken');
  runApp(MyApp());
}


class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, widget) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, widget!),
        maxWidth: 1200,
        minWidth: 450,
        defaultScale: true,
        breakpoints: [
          ResponsiveBreakpoint.resize(450, name: MOBILE),
          ResponsiveBreakpoint.autoScale(800, name: TABLET),
          ResponsiveBreakpoint.autoScale(1000, name: TABLET),
          ResponsiveBreakpoint.resize(1200, name: DESKTOP),
          ResponsiveBreakpoint.autoScale(2460, name: "4K"),
        ],
        background: Container(color: Colors.white)
      ),
      title: 'Youth App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
      home: SplashScreen(),
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/forgotpw': (context) => ForgotPasswordScreen(),
        '/signup': (context) => SignUpScreen(),
        '/fb-signup': (context) => FbSignUpScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/verification': (context) => VerificationScreen(),
        '/init-home': (context) => InitHomeScreen(),
        '/edit-account-details': (context) => EditAccountDetailsScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/search': (context) => SearchScreen(),
        '/organisation-details': (context) => InitOrganisationDetailsScreen(),
        '/view-activities': (context) => ViewActivitiesScreen(),
        '/activity-details': (context) => InitActivityDetailsScreen(),
      }
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 1000,
      splash: Image(image: AssetImage('assets/images/equity-lab-logo.png'),), //ask Temy to provide a SVG icon for this
      nextScreen: currentAccessToken!.isEmpty || JwtDecoder.isExpired(currentAccessToken!) ? WelcomeScreen() : InitHomeScreen(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
    );
  }
}
