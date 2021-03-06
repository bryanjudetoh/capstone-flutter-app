import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:youthapp/models/participant.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/profile-progress-tile.dart';
import '../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';

class InitProfileScreenBody extends StatelessWidget {
  InitProfileScreenBody({Key? key, required this.setNumUnreadNotifications}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final Function setNumUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
        future: getUserDetails(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.hasData) {
            User user = snapshot.data!;
            return ProfileScreenBody(
              user: user,
              secureStorage: secureStorage,
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
        });
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

class ProfileScreenBody extends StatefulWidget {
  ProfileScreenBody({Key? key,
    required this.user,
    required this.secureStorage,
    required this.setNumUnreadNotifications,
  }) : super(key: key);

  final User user;
  final SecureStorage secureStorage;
  final String placeholderProfilePicUrl = placeholderDisplayPicUrl;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final Function setNumUnreadNotifications;

  @override
  _ProfileScreenBodyState createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody>
    with TickerProviderStateMixin {
  bool currentSelectedIsRegistered = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance!.addPostFrameCallback((_) =>
        widget.setNumUnreadNotifications(widget.user.numUnreadNotifications));
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: false,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Column(
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)!.profile,
                              style: titleOneTextStyleBold,
                            ),
                            IconButton(
                              onPressed: modalBottomSheet(
                                  context, widget.user),
                              icon: Icon(
                                Icons.settings_outlined,
                                size: 30,
                                color: kDarkGrey,
                              ),
                            )
                          ]),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              width: 3,
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 10, // changes position of shadow
                              ),
                            ]),
                        child: Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                    widget.user.profilePicUrl!.isNotEmpty ?
                                    widget.user.profilePicUrl! : widget.placeholderProfilePicUrl
                                ),
                                maxRadius: 50,
                              ),
                              SizedBox(
                                width: 25,
                              ),
                              Flexible(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "${widget.user.firstName} ${widget.user
                                          .lastName}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: bodyTextStyleBold,
                                    ),
                                    Text(
                                      '${widget.user.school}',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: captionTextStyle,
                                    ),
                                    Text(
                                      '${widget.user.city}',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: captionTextStyle,
                                    ),
                                    Text(
                                      'Born on ${dateFormat.format(widget.user.dob!)}',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: captionTextStyle,
                                    ),
                                    Text(
                                      '${widget.user.email}',
                                      overflow: TextOverflow.ellipsis,
                                      style: captionTextStyle,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                          'assets/images/elixir.png'),
                                      height: 40,
                                      width: 40,
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          'Total Potions',
                                          style: captionTextStyle,
                                        ),
                                        Text(
                                          '${widget.user.potionBalance!.values.reduce((a, b) => a + b)}',
                                          style: bodyTextStyleBold,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(children: <Widget>[
                                  Text(
                                    'Friends',
                                    style: captionTextStyle,
                                  ),
                                  Text(
                                    '${widget.user.numFriends}',
                                    style: bodyTextStyleBold,
                                  ),
                                ])
                              ])
                        ]),
                      ),
                    ],
                  ),
                ),
                expandedHeight: 300.0,
                bottom: TabBar(
                  unselectedLabelColor: Colors.blueGrey,
                  indicatorColor: kLightBlue,
                  labelColor: kLightBlue,
                  tabs: [
                    Tab(child: Text('Upcoming', style: bodyTextStyle,)),
                    Tab(child: Text('History', style: bodyTextStyle,)),
                    Tab(child: Text('Progress', style: bodyTextStyle,)),
                  ],
                  controller: tabController,
                ),
              )
            ];
          },
          body: TabBarView(
              controller: tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                FutureBuilder<List<Participant>>(
                    future: getParticipantActivities(isRegistered: true),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Participant>> snapshot) {
                      if (snapshot.hasData) {
                        List<Participant> registeredList = snapshot.data!;
                        if (registeredList.length > 0) {
                          return displayParticipantActivities(registeredList);
                        }
                        else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sentiment_dissatisfied_sharp,
                                  size: 70,
                                ),
                                Text(
                                  'You have not registered for any activities!',
                                  style: titleThreeTextStyle,
                                ),
                              ],
                            ),
                          );
                        }
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
                                size: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text('Error: ${snapshot.error}' , style: titleThreeTextStyleBold, textAlign: TextAlign.center,),
                              ),
                            ],
                          ),
                        );
                      }
                      else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: CircularProgressIndicator(),
                              width: 20,
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text(
                                  'Loading...',
                                  style: titleThreeTextStyleBold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    }
                ),
                FutureBuilder<List<Participant>>(
                    future: getParticipantActivities(isRegistered: false),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Participant>> snapshot) {
                      if (snapshot.hasData) {
                        List<Participant> historyList = snapshot.data!;
                        if (historyList.length > 0) {
                          return displayParticipantActivities(historyList);
                        }
                        else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sentiment_dissatisfied_sharp,
                                  size: 70,
                                ),
                                Text(
                                  'You do not have history for any activities!',
                                  style: titleThreeTextStyle,
                                ),
                              ],
                            ),
                          );
                        }
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
                                size: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text('Error: ${snapshot.error}' , style: titleThreeTextStyleBold, textAlign: TextAlign.center,),
                              ),
                            ],
                          ),
                        );
                      }
                      else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: CircularProgressIndicator(),
                              width: 20,
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text(
                                  'Loading...',
                                  style: titleThreeTextStyleBold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    }
                ),
                FutureBuilder<List<Participant>>(
                  future: getParticipantActivities(isRegistered: false),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Participant>> snapshot) {
                      if (snapshot.hasData) {
                        List<Participant> historyList = snapshot.data!;
                        List<Participant> completedList = [];
                        completedList.addAll(historyList.where((p) => p.status == 'completed'));
                        return displayProfileProgress(completedList);
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
                                size: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text('Error: ${snapshot.error}' , style: titleThreeTextStyleBold, textAlign: TextAlign.center,),
                              ),
                            ],
                          ),
                        );
                      }
                      else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: CircularProgressIndicator(),
                              width: 20,
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text(
                                  'Loading...',
                                  style: titleThreeTextStyleBold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    }
                ),
              ]
          ),
        ),
      ),
    );
  }

  Future<List<Participant>> getParticipantActivities({required bool isRegistered}) async {

    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/activity-history?upcoming=${isRegistered.toString()}')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Map<String, dynamic>> mapList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        mapList.add(i);
      }
      List<Participant> participantResultList =
        mapList.map((act) => Participant.fromJson(act)).toList();

      return participantResultList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during intialising activity data');
    }
  }

  ListView displayParticipantActivities(List<Participant> participantList) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: participantList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/registered-activity-details', arguments: participantList[index].participantId);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Card(
                      margin: EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      elevation: 6.0,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Image.network(
                              participantList[index].activity.mediaContentUrls!.isEmpty
                                  ? getPlaceholderPicUrl(participantList[index].activity.type!)
                                  : participantList[index].activity.mediaContentUrls![0],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                print('bad url: ${participantList[index].activity.mediaContentUrls!.isEmpty
                                    ? getPlaceholderPicUrl(participantList[index].activity.type!)
                                    : participantList[index].activity.mediaContentUrls![0]}');
                                return const Center(
                                  child: Text('Couldn\'t load image.', style: bodyTextStyle,),
                                );
                              }
                            ),
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black54
                                  ],
                                ),
                              ),
                              child: Text(
                                'Status: ${getCapitalizeString(str: participantList[index].status!)}',
                                style: TextStyle(
                                  //need to change to constant TextStyles
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            if (participantList[index].status! != 'registered')
                              Container(
                                alignment: Alignment.bottomRight,
                                padding: EdgeInsets.only(
                                    right: 16, bottom: 16),
                                child: Text(
                                  'Attendance: ${participantList[index].attendancePercent}%',
                                  style: TextStyle(
                                    //need to change to constant TextStyles
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${participantList[index].activity.name}',
                              style: carouselActivityTitleTextStyle,
                              textAlign: TextAlign.left,
                            )
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top:3),
                            child: Text('Awarded:',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF5EC8D8),
                              ),
                            ),
                          ),
                          Image(
                            image: AssetImage(
                                '${activityTypeToPotionColorPathMap[participantList[index].activity.type]}'),
                            height: 25,
                            width: 25,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top:3),
                            child: Text('${participantList[index].awardedPotions}',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Color(0xFF5EC8D8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ListView displayProfileProgress(List<Participant> completedList) {
    return ListView(
      children: [
        ProfileProgressTile(user: widget.user, completedList: completedList, type: 'scholarship'),
        ProfileProgressTile(user: widget.user, completedList: completedList, type: 'internship'),
        ProfileProgressTile(user: widget.user, completedList: completedList, type: 'mentorship'),
        ProfileProgressTile(user: widget.user, completedList: completedList, type: 'onlineCourse'),
        ProfileProgressTile(user: widget.user, completedList: completedList, type: 'offlineCourse'),
        ProfileProgressTile(user: widget.user, completedList: completedList, type: 'volunteer'),
        ProfileProgressTile(user: widget.user, completedList: completedList, type: 'sports'),
      ],
    );
  }

  VoidCallback modalBottomSheet(BuildContext context, User user) {
    return () {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: new Icon(Icons.payments_outlined),
                  title: new Text('View Transaction History'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/transaction-history');
                  },
                ),
                ListTile(
                  leading: new Icon(Icons.edit),
                  title: new Text('Edit Account Details'),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, '/edit-account-details',
                        arguments: user);
                  },
                ),
                if (user.loginType == 'email')
                  ListTile(
                    leading: new Icon(Icons.edit),
                    title: new Text('Change Password'),
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context, '/change-password',);
                    },
                  ),
                ListTile(
                  leading: new Icon(Icons.logout),
                  title: new Text('Logout'),
                  onTap: () async {
                    doLogout(context);
                  },
                ),
              ],
            );
          });
    };
  }

  void doLogout(BuildContext context) async {

    final response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/mp/auth/logout'),
      body: jsonEncode(<String, String>{
        "userId": widget.user.userId
      })
    );

    if (response.statusCode == 200) {
      print('doing log out');
      widget.secureStorage.deleteAllData();
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Successfully logged out",
              style: bodyTextStyle,
            ),
            duration: const Duration(seconds: 2),
          )
      );
    }
    else {
      print('doing force log out');
      widget.secureStorage.deleteAllData();
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Session Expired: Please log in again",
              style: bodyTextStyle,
            ),
            duration: const Duration(seconds: 2),
          )
      );
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}
