import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/screens/notifications.dart';
import 'package:youthapp/screens/profile.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/activities-carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  PageController pageController = new PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: HomeScreenBody(user: widget.user),
            ),
            Container(
              color: Colors.white,
              child: NotificationsScreenBody(user: widget.user),
            ),
            Container(
              color: kBackground,
              child: InitProfileScreenBody(),
            ),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cottage_outlined, size: 30),
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

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SvgPicture.asset('assets/images/equity-lab-homescreen-logo.svg'),
              SizedBox(
                width: 10,
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/search');
                },
                icon: Icon(Icons.search),
                iconSize: 30,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Image(
              image: AssetImage(
                  'assets/images/temp-homescreen-potions-level.png')),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.scholarship + ':',
            seeAllFunc: () {Navigator.of(context).pushNamed('/browse-activities', arguments: 'scholarship');},
            type: 'scholarship',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.internship + ':',
            seeAllFunc: () {Navigator.of(context).pushNamed('/browse-activities', arguments: 'internship');},
            type: 'internship',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.mentorship + ':',
            seeAllFunc: () {Navigator.of(context).pushNamed('/browse-activities', arguments: 'mentorship');},
            type: 'mentorship',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.onlineCourses + ':',
            seeAllFunc: () {Navigator.of(context).pushNamed('/browse-activities', arguments: 'onlineCourse');},
            type: 'onlineCourse',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.offlineCourses + ':',
            seeAllFunc: () {Navigator.of(context).pushNamed('/browse-activities', arguments: 'offlineCourse');},
            type: 'offlineCourse',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.volunteering + ':',
            seeAllFunc: () {Navigator.of(context).pushNamed('/browse-activities', arguments: 'volunteering');},
            type: 'volunteering',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.sports + ':',
            seeAllFunc: () {Navigator.of(context).pushNamed('/browse-activities', arguments: 'sports');},
            type: 'sports',
          ),
        ],
      ),
    );
  }
}
