import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import '../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class InitProfileScreenBody extends StatefulWidget {
  const InitProfileScreenBody({Key? key}) : super(key: key);

  @override
  _InitProfileScreenBodyState createState() => _InitProfileScreenBodyState();
}

class _InitProfileScreenBodyState extends State<InitProfileScreenBody> {
  final SecureStorage secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: this.secureStorage.readSecureData('user'),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            User user = User.fromJson(jsonDecode(snapshot.data!));
            return ProfileScreenBody(
              user: user,
              secureStorage: secureStorage,
            );
          } else if (snapshot.hasError) {
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
          } else {
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
}

class ProfileScreenBody extends StatefulWidget {
  const ProfileScreenBody(
      {Key? key, required this.user, required this.secureStorage})
      : super(key: key);

  final User user;
  final SecureStorage secureStorage;

  @override
  _ProfileScreenBodyState createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody>
    with TickerProviderStateMixin {
  String? profilePicUrl = '';
  bool currentSelectedIsRegistered = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.profilePicUrl != null) {
      this.profilePicUrl = widget.user.profilePicUrl;
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: false,
                backgroundColor: Colors.white,
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
                                backgroundImage: this.profilePicUrl!.isNotEmpty
                                    ? NetworkImage(
                                    'https://cdn.eq-lab-dev.me/' +
                                        this.profilePicUrl!)
                                    : Image
                                    .asset(
                                    'assets/images/default-profilepic.png')
                                    .image,
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
                                      'Born on ${widget.user.dob.toString()
                                          .split(' ')[0]}',
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
                                          'Elixirs',
                                          style: captionTextStyle,
                                        ),
                                        Text(
                                          '1/100',
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
                                    '52',
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
                    Tab(child: Text('Registered', style: bodyTextStyle,)),
                    Tab(child: Text('History', style: bodyTextStyle,)),
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
                FutureBuilder<List<Activity>>(
                    future: getParticipantActivities(isRegistered: true),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Activity>> snapshot) {
                      if (snapshot.hasData) {
                        List<Activity> registeredList = snapshot.data!;
                        print('displaying registered list: $registeredList');
                        if (registeredList.length > 0) {
                          return Center(
                            child: Text(
                              'There are registered activities!',
                              style: titleThreeTextStyle,
                            ),
                          );
                        }
                        else {
                          return Center(
                            child: Text(
                              'You have not registered for any activities!',
                              style: titleThreeTextStyle,
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
                FutureBuilder<List<Activity>>(
                    future: getParticipantActivities(isRegistered: false),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Activity>> snapshot) {
                      if (snapshot.hasData) {
                        List<Activity> historyList = snapshot.data!;
                        print('displaying history list: $historyList');
                        if (historyList.length > 0) {
                          return Center(
                            child: Text(
                              'There is a history of activities!',
                              style: titleThreeTextStyle,
                            ),
                          );
                        }
                        else {
                          return Center(
                            child: Text(
                              'You do not have history for any activities!',
                              style: titleThreeTextStyle,
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
              ]
          ),
        ),
      ),
    );
  }

  Future<List<Activity>> getParticipantActivities({required bool isRegistered}) async {
    final String accessToken = await widget.secureStorage.readSecureData(
        'accessToken');

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://eq-lab-dev.me/api/activity-svc/mp/participant/activity-history?registered=' + isRegistered.toString()
        )
    );
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print('api received ${isRegistered ? 'registered' : 'history'} activity list: ' + jsonDecode(result).toString());

      List<dynamic> resultList = jsonDecode(result);
      List<Map<String, dynamic>> mapList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        Map<String, dynamic> j = Map<String, dynamic>.from(i['activity']);
        mapList.add(j);
      }
      List<Activity> activityResultList =
        mapList.map((act) => Activity.fromJson(act)).toList();

      return activityResultList;
    }
    else if (response.statusCode == 401) {
      final String refreshToken = await widget.secureStorage.readSecureData('refreshToken');
      final refreshResponse = await http.post(
        Uri.parse('https://eq-lab-dev.me/api/auth/refresh'),
        body: <String, String>{
          "token": refreshToken,
        },
      );

      if (refreshResponse.statusCode == 200) {
        var refreshResponseBody = jsonDecode(refreshResponse.body);
        var token = refreshResponseBody['token'];

        widget.secureStorage.writeSecureData('accessToken', token['accessToken']);
        widget.secureStorage.writeSecureData('refreshToken', token['refreshToken']);

        return await getParticipantActivities(isRegistered: isRegistered);
      }
      else {
        print('from profile forcing logout due to expired refresh token');
        widget.secureStorage.deleteAllData();
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
        throw Exception('Refresh token has expired, please log in again!');
      }

    }
    else {
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occurred during intialising activity data');
    }
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
    final String accessToken = await widget.secureStorage.readSecureData(
        'accessToken');
    final response = await http.put(
      Uri.parse('https://eq-lab-dev.me/api/mp/auth/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, String>{
        "userId": widget.user.userId
      })
    );

    if (response.statusCode == 200) {
      print('doing log out');
      widget.secureStorage.deleteAllData();
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    }
    else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}
