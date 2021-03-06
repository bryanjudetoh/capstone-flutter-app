import 'package:flutter/material.dart';
import 'package:youthapp/Screens/welcome.dart';
import 'package:youthapp/Screens/login.dart';
import 'package:youthapp/screens/browse-activities.dart';
import 'package:youthapp/screens/activity-details.dart';
import 'package:youthapp/screens/browse-rewards.dart';
import 'package:youthapp/screens/change-password.dart';
import 'package:youthapp/screens/create-post-shared.dart';
import 'package:youthapp/screens/create-post.dart';
import 'package:youthapp/screens/edit-account-details.dart';
import 'package:youthapp/screens/full-post.dart';
import 'package:youthapp/screens/leaderboards.dart';
import 'package:youthapp/screens/my-rewards.dart';
import 'package:youthapp/screens/notification-details.dart';
import 'package:youthapp/screens/onboarding.dart';
import 'package:youthapp/screens/organisation-details.dart';
import 'package:youthapp/screens/registered-activity-details.dart';
import 'package:youthapp/screens/reward-details.dart';
import 'package:youthapp/screens/search-friends.dart';
import 'package:youthapp/screens/search.dart';
import 'package:youthapp/screens/signup.dart';
import 'package:youthapp/screens/fb-signup.dart';
import 'package:youthapp/screens/forgot-password.dart';
import 'package:youthapp/screens/init-home.dart';
import 'package:youthapp/screens/transaction-details.dart';
import 'package:youthapp/screens/transaction-history.dart';
import 'package:youthapp/screens/user-profile.dart';
import 'package:youthapp/screens/verification.dart';
import 'package:youthapp/utilities/navigation-service.dart';
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
  try {
    currentAccessToken = await secureStorage.readSecureData('accessToken');
  }
  on Exception catch (err) {
    currentAccessToken = '';
    print(err.toString());
  }
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
      navigatorKey: NavigationService.navigatorKey,
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
        '/browse-activities': (context) => InitBrowseActivitiesScreen(),
        '/activity-details': (context) => InitActivityDetailsScreen(),
        '/registered-activity-details': (context) => InitRegisteredActivityDetails(),
        '/browse-rewards': (context) => InitBrowseRewardsScreen(),
        '/reward-details': (context) => InitRewardDetailsScreen(),
        '/leaderboard': (context) => InitLeaderBoardScreen(),
        '/my-rewards': (context) => MyRewardsScreen(),
        '/search-friends': (context) => SearchFriendsScreen(),
        '/user-profile': (context) => InitUserProfileScreen(),
        '/full-post': (context) => InitFullPostScreen(),
        '/create-post': (context) => CreatePostScreen(),
        '/create-post-shared': (context) => InitCreatePostShared(),
        '/transaction-history': (context) => InitTransactionHistoryScreen(),
        '/transaction-details': (context) => InitTransactionDetailsScreen(),
        '/notification-details': (context) => InitNotificationDetailsScreen(),
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
