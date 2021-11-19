import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/screens/notifications.dart';
import 'package:youthapp/screens/profile.dart';
import 'package:youthapp/screens/social-media.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/activities-carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youthapp/widgets/homepage-potions.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  double _iconSize = 35.0;
  PageController pageController = new PageController();
  late int numUnreadNotifications;

  @override
  void initState() {
    super.initState();
    if (widget.user.numUnreadNotifications != null) {
      this.numUnreadNotifications = widget.user.numUnreadNotifications!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: InitHomeScreenBody(
                setNumUnreadNotifications: setNumUnreadNotifications,
              ),
            ),
            Container(
              color: Colors.white,
              child: InitNotificationsScreenBody(
                updateNumUnreadNotifications: updateNumUnreadNotifications,
                setNumUnreadNotifications: setNumUnreadNotifications,
              ),
            ),
            Container(
              color: Colors.white,
              child: InitSocialMediaScreenBody(
                setNumUnreadNotifications: setNumUnreadNotifications,
              ),
            ),
            Container(
              color: Colors.white,
              child: InitProfileScreenBody(
                setNumUnreadNotifications: setNumUnreadNotifications,
              ),
            ),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      floatingActionButton: Container(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          heroTag: null,
          backgroundColor: kLightBlue,
          onPressed: () {Navigator.pushNamed(context, '/create-post', arguments: widget.user);},
          child: const Icon(Icons.add, color: Colors.white, size: 30,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: IconButton(
                  icon: Icon(
                    Icons.cottage_outlined,
                    size: _iconSize,
                    color: this._page == 0 ? kLightBlue : kDarkGrey,
                  ),
                  tooltip: 'Home',
                  onPressed: () {
                    navigationTapped(0);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        size: _iconSize,
                        color: this._page == 1 ? kLightBlue : kDarkGrey,
                      ),
                      tooltip: 'Notifications',
                      onPressed: () {
                        navigationTapped(1);
                      },
                    ),
                    if (this.numUnreadNotifications > 0)
                      Positioned(
                        top: 2.0,
                        right: 2.0,
                        child: Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${numUnreadNotifsOverflow(this.numUnreadNotifications)}',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: this.numUnreadNotifications > 9 ? 10.0 : 14.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: IconButton(
                  icon: Icon(
                    Icons.people_alt_outlined,
                    size: _iconSize,
                    color: this._page == 2 ? kLightBlue : kDarkGrey,
                  ),
                  tooltip: 'Social Media',
                  onPressed: () {
                    navigationTapped(2);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: IconButton(
                  icon: Icon(
                    Icons.person_outlined,
                    size: _iconSize,
                    color: this._page == 3 ? kLightBlue : kDarkGrey,
                  ),
                  tooltip: 'Profile',
                  onPressed: () {
                    navigationTapped(3);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  void updateNumUnreadNotifications(int changeNum) {
    setState(() {
      this.numUnreadNotifications += changeNum;
    });
  }

  void setNumUnreadNotifications(int newUnread) {
    print('setting unread notifs');
    setState(() {
      this.numUnreadNotifications = newUnread;
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}

class InitHomeScreenBody extends StatelessWidget {
  InitHomeScreenBody({Key? key, required this.setNumUnreadNotifications}) : super(key: key);

  final Function setNumUnreadNotifications;
  final SecureStorage secureStorage = SecureStorage();
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: getUserDetails(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;
          return HomeScreenBody(
            user: user,
            setNumUnreadNotifications: setNumUnreadNotifications,
          );
        }
        else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: titleTwoTextStyleBold,
                  ),
                ),
              ],
            ),
          );
        }
        else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Loading...',
                    style: titleTwoTextStyleBold,
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }

  Future<User> getUserDetails() async {
    var response = await this.http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/user'),
    );

    if (response.statusCode == 200) {
      this.secureStorage.writeSecureData('user', response.body);
      var responseBody = jsonDecode(response.body);
      //print(responseBody);
      User user = User.fromJson(responseBody);

      return user;
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}


class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({Key? key, required this.user, required this.setNumUnreadNotifications}) : super(key: key);

  final User user;
  final Function setNumUnreadNotifications;

  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final SecureStorage secureStorage = SecureStorage();
  late Map<String, int> currentMultipliers;

  @override
  void initState() {
    super.initState();
    this.currentMultipliers = widget.user.multipliers!;
    WidgetsBinding.instance!.addPostFrameCallback((_) =>
        widget.setNumUnreadNotifications(widget.user.numUnreadNotifications));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
              padding: EdgeInsets.all(10.0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            maxRadius: 30,
                            backgroundImage: AssetImage('assets/images/elixir.png',),
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Text(
                            '${widget.user.potionBalance!.values.reduce((a, b) => a + b)}',
                            style: homeElixirTitleTextStyle,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Total Potions',
                            style: homeElixirBodyTextStyle,
                          ),
                          SizedBox(
                            width: 45,
                          ),
                        ]
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    GridView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      primary: false,
                      padding: EdgeInsets.all(0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                        ),
                      children: <Widget>[
                        HomepagePotion(
                          multiplier: this.currentMultipliers,
                          potionBalance: widget.user.potionBalance!,
                          mapKey: 'scholarship',
                        ),
                        HomepagePotion(
                          multiplier: this.currentMultipliers,
                          potionBalance: widget.user.potionBalance!,
                          mapKey: 'internship',
                        ),
                        HomepagePotion(
                          multiplier: this.currentMultipliers,
                          potionBalance: widget.user.potionBalance!,
                          mapKey: 'mentorship',
                        ),
                        HomepagePotion(
                          multiplier: this.currentMultipliers,
                          potionBalance: widget.user.potionBalance!,
                          mapKey: 'onlineCourse',
                        ),
                      ],
                    ),
                    GridView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      primary: false,
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      children: <Widget>[
                        HomepagePotion(
                          multiplier: this.currentMultipliers,
                          potionBalance: widget.user.potionBalance!,
                          mapKey: 'offlineCourse',
                        ),
                        HomepagePotion(
                          multiplier: this.currentMultipliers,
                          potionBalance: widget.user.potionBalance!,
                          mapKey: 'sports',
                        ),
                        HomepagePotion(
                          multiplier: this.currentMultipliers,
                          potionBalance: widget.user.potionBalance!,
                          mapKey: 'volunteer',
                        ),
                      ],
                    ),
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
