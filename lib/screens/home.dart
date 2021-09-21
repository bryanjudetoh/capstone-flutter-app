import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/screens/notifications.dart';
import 'package:youthapp/screens/profile.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/rounded-button.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  PageController pageController = new PageController();

  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      body: PageView(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: HomeScreenBody(user: user),
          ),
          Container(
            color: Colors.white,
            child: NotificationsScreenBody(user: user),
          ),
          Container(
            color: kBackground,
            child: ProfileScreenBody(user: user),
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
                Icons.cottage_outlined,
                size: 30),
            label: 'Home',
            backgroundColor: kDarkGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_outlined,
              size: 30,
            ),
            label: 'Notifications',
            backgroundColor: kDarkGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outlined,
              size: 30,
            ),
            label: 'Profile',
            backgroundColor: kDarkGrey,
          ),
        ],
        currentIndex: _page,
        selectedItemColor: kLightBlue,
        onTap: navigationTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
    );
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({Key? key, required this.user}) : super(key: key);

  final User user;
  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final SecureStorage secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text(
            'This is the homescreen',
            style: titleTwoTextStyle,
          ),
        ),
        RoundedButton(
            title: 'Log Out',
            func: () {
              secureStorage.deleteAllData();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            colorBG: kLightBlue,
            colorFont: kWhite
        )
      ],
    );
  }
}
