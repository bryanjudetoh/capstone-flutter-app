import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:youthapp/models/participant.dart';
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
  final String placeholderPicUrl = 'https://media.gettyimages.com/photos/in-this-image-released-on-may-13-marvel-shang-chi-super-hero-simu-liu-picture-id1317787772?s=612x612';

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
              ]
          ),
        ),
      ),
    );
  }

  Future<List<Participant>> getParticipantActivities({required bool isRegistered}) async {
    final String accessToken = await widget.secureStorage.readSecureData(
        'accessToken');

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://eq-lab-dev.me/api/activity-svc/mp/activity/activity-history?registered=' + isRegistered.toString()
        )
    );
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();

      List<dynamic> resultList = jsonDecode(result);
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
      String result = await response.stream.bytesToString();
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
                print('tapped');
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
                                  ? widget.placeholderPicUrl
                                  : participantList[index].activity.mediaContentUrls![0],
                              fit: BoxFit.cover,
                              width: double.infinity,
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
                                'Status: ${participantList[index].status}',
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${participantList[index].activity.name}',
                        style: carouselActivityTitleTextStyle,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage(
                                'assets/images/elixir.png'),
                            height: 25,
                            width: 25,
                          ),
                          Text('${participantList[index].activity.potions}',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF5EC8D8),
                            ),
                          )
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
