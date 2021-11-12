import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/screens/notifications.dart';
import 'package:youthapp/screens/profile.dart';
import 'package:youthapp/screens/social-media.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/activities-carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youthapp/widgets/rounded-button.dart';

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
              color: Colors.white,
              child: SocialMediaScreenBody(user: widget.user),
            ),
            Container(
              color: Colors.white,
              child: InitProfileScreenBody(),
            ),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      floatingActionButton: MaterialButton(
        height: 60,
        color: kLightBlue,
        shape: CircleBorder(),
        onPressed: () {Navigator.pushNamed(context, '/create-post', arguments: widget.user);},
        child: const Icon(Icons.add, color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
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
              Icons.people_alt_outlined,
              size: 30,
            ),
            label: 'Social Media',
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
        type: BottomNavigationBarType.fixed,
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
          Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
              decoration: BoxDecoration(
                  color: kLightBlue,
                  border: Border.all(
                    width: 3,
                    color: kLightBlue,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: kLightBlue.withOpacity(0.5),
                      blurRadius: 10, // changes position of shadow
                    ),
                  ]),
              child: Column(children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        maxRadius: 50,
                        backgroundImage: AssetImage('assets/images/elixir.png',),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Column(
                        children: <Widget> [
                          Text(
                            '${widget.user.potionBalance!.values.reduce((a, b) => a + b)}',
                            style: homeElixirTitleTextStyle,
                          ),
                          Text(
                            'Equity Score',
                            style: homeElixirBodyTextStyle,
                          )
                        ]
                      )
                    ]
                ),
                SizedBox(
                  height: 15,
                ),
                Column(
                  children: <Widget>[
                    Text('Activities being boosted:', style: homeElixirSmallBodyTextStyle,),
                    SizedBox(height: 5,),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.user.multipliers!.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = widget.user.multipliers!.keys.elementAt(index);
                        print(widget.user.multipliers!);
                        return widget.user.multipliers![key] == 1
                          ? Container()
                          : Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${activityTypeMap[key]}:', style: homeElixirSmallBodyTextStyle,),
                                  SizedBox(width: 30,),
                                  Text('${widget.user.multipliers![key]}x', style: homeElixirSmallBodyTextStyle,),
                                ],
                              ),
                            );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RoundedButton(
                        func: () {
                            Navigator.pushNamed(context, '/browse-rewards');
                        },
                        colorFont: kLightBlue,
                        colorBG: Colors.white,
                        title: 'Rewards'
                    ),
                    SizedBox(
                        height: 15
                    ),
                    RoundedButton(
                        func: () {Navigator.pushNamed(context, '/leaderboard');},
                        colorFont: kLightBlue,
                        colorBG: Colors.white,
                        title: 'Leaderboards'
                    ),
                  ],
                )
              ]
            )
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.scholarship + ':',
            seeAllFunc: () {
              Navigator.of(context)
                  .pushNamed('/browse-activities', arguments: 'scholarship');
            },
            type: 'scholarship',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.internship + ':',
            seeAllFunc: () {
              Navigator.of(context)
                  .pushNamed('/browse-activities', arguments: 'internship');
            },
            type: 'internship',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.mentorship + ':',
            seeAllFunc: () {
              Navigator.of(context)
                  .pushNamed('/browse-activities', arguments: 'mentorship');
            },
            type: 'mentorship',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.onlineCourses + ':',
            seeAllFunc: () {
              Navigator.of(context)
                  .pushNamed('/browse-activities', arguments: 'onlineCourse');
            },
            type: 'onlineCourse',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.offlineCourses + ':',
            seeAllFunc: () {
              Navigator.of(context)
                  .pushNamed('/browse-activities', arguments: 'offlineCourse');
            },
            type: 'offlineCourse',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.volunteering + ':',
            seeAllFunc: () {
              Navigator.of(context)
                  .pushNamed('/browse-activities', arguments: 'volunteer');
            },
            type: 'volunteer',
          ),
          ActivitiesCarousel(
            title: AppLocalizations.of(context)!.sports + ':',
            seeAllFunc: () {
              Navigator.of(context)
                  .pushNamed('/browse-activities', arguments: 'sports');
            },
            type: 'sports',
          ),
        ],
      ),
    );
  }
}
