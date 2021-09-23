import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/screens/notifications.dart';
import 'package:youthapp/screens/profile.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/activities-carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youthapp/utilities/images-titles-lists.dart';

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
            child: InitProfileScreenBody(),
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
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
      padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
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
            title: 'For you:',
            seeAllFunc: () {},
            imagesList: imagesListForYou,
            titlesList: titlesListForYou,
          ),
          ActivitiesCarousel(
            title: 'Pride Board:',
            seeAllFunc: () {},
            imagesList: imagesListPrideBoard,
            titlesList: titlesListPrideBoard,
          ),
          ActivitiesCarousel(
            title: 'Scholarship:',
            seeAllFunc: () {},
            imagesList: imagesListScholarship,
            titlesList: titlesListScholarship,
          ),
          ActivitiesCarousel(
            title: 'Internship:',
            seeAllFunc: () {},
            imagesList: imagesListInternship,
            titlesList: titlesListInternship,
          ),
          ActivitiesCarousel(
            title: 'Mentorship:',
            seeAllFunc: () {},
            imagesList: imagesListMentorship,
            titlesList: titlesListMentorship,
          ),
          ActivitiesCarousel(
            title: 'Training:',
            seeAllFunc: () {},
            imagesList: imagesListTraining,
            titlesList: titlesListTraining,
          ),
          ActivitiesCarousel(
            title: 'Activities:',
            seeAllFunc: () {},
            imagesList: imagesListActivities,
            titlesList: titlesListActivities,
          ),
        ],
      ),
    );
  }

  void doLogout(secureStorage) {
    secureStorage.deleteAllData();
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }
}
