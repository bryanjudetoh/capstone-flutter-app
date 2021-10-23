import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/models/claimed-reward.dart';
import 'package:youthapp/models/session.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:intl/intl.dart';

class InitActivityDetailsScreen extends StatelessWidget {
  InitActivityDetailsScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    final String activityId =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Activity>(
        future: retrieveActivity(activityId),
        builder: (BuildContext context, AsyncSnapshot<Activity> snapshot) {
          if (snapshot.hasData) {
            Activity activity = snapshot.data!;
            if (activity.isRegistered!) {
              Future.microtask(() {Navigator.pushReplacementNamed(context, '/registered-activity-details', arguments: activity.participantId);});
              return Container();
            }
            return ActivityDetailsScreen(activity: activity, activityType: activity.type!,);
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
      ),
    );
  }

  Future<Activity> retrieveActivity(String activityId) async {
    final response = await http.get(
      Uri.parse(
          'https://eq-lab-dev.me/api/activity-svc/mp/activity/$activityId'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return Activity.fromJson(Map<String, dynamic>.from(responseBody));
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}

class ActivityDetailsScreen extends StatefulWidget {
  ActivityDetailsScreen({Key? key, required this.activity, required String activityType}) {
    placeholderPicUrl = getPlaceholderPicUrl(activityType);
  }

  final Activity activity;
  late final String placeholderPicUrl;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _ActivityDetailsScreenState createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  DateFormat dateFormat = DateFormat.yMd();
  DateFormat timeFormat = DateFormat.jm();
  int selectedRewardIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: kBlack,
                          size: 25,
                        )
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                      primary: kGrey,
                    ),
                  ),
                  Text(
                    '${activityTypeMap[widget.activity.type]}',
                    style: titleOneTextStyleBold,
                  ),
                  Flexible(
                    child: SizedBox(width: 65),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: widget.activity.mediaContentUrls!.isEmpty
                        ? Image.network(
                      widget.placeholderPicUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 220,
                    )
                        : CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: false,
                        enableInfiniteScroll: true,
                        viewportFraction: 1.0,
                      ),
                      items: widget.activity.mediaContentUrls!
                          .map(
                              (url) => Image.network(
                            url,
                            fit: BoxFit.fitHeight,
                          )
                      ).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 300,
                          child: Text(
                            '${widget.activity.name}',
                            style: titleOneTextStyleBold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image(
                              image: AssetImage('assets/images/elixir.png'),
                              height: 40,
                              width: 40,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                '${widget.activity.potions}',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Color(0xFF5EC8D8),
                                ),
                              ),
                            ),
                          ],
                        )
                      ]),
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${widget.activity.organisation!.name}',
                        textAlign: TextAlign.left,
                        style: subtitleTextStyleBold,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            '${widget.activity.activityRating}',
                            style: bodyTextStyleBold,
                          ),
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          Text(
                            'Start date',
                            style: captionTextStyle,
                          ),
                          SizedBox(
                            height: 1,
                          ),
                          Text(
                            '${widget.activity.activityStartTime.toString().split(' ')[0]}',
                            style: bodyTextStyleBold,
                          )
                        ]),
                        SizedBox(
                          width: 70,
                        ),
                        Column(children: [
                          Text(
                            'End date',
                            style: captionTextStyle,
                          ),
                          SizedBox(
                            height: 1,
                          ),
                          Text(
                            '${widget.activity.activityEndTime.toString().split(' ')[0]}',
                            style: bodyTextStyleBold,
                          )
                        ]),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                margin: EdgeInsets.only(bottom: 30.0),
                decoration: BoxDecoration(
                  color: kBluishWhite,
                  border: Border.all(
                    width: 3,
                    color: kBluishWhite,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(children: [
                      Text(
                        'Registration ends',
                        style: captionTextStyle,
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Text(
                        '${widget.activity.registrationEndTime.toString().split(' ')[0]}',
                        style: bodyTextStyleBold,
                      )
                    ]),
                    SizedBox(
                      width: 70,
                    ),
                    Column(children: [
                      Text(
                        'No. of participants',
                        style: captionTextStyle,
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Row(children: [
                        Text('${widget.activity.participantCount}',
                            style: bodyTextStyleBold),
                        Text(' / ', style: bodyTextStyleBold),
                        Text('${widget.activity.applicantPax}',
                            style: bodyTextStyleBold),
                      ]),
                    ]),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.activity.description}',
                  style: bodyTextStyle,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              RoundedButton(
                title: 'View Sessions',
                colorBG: kWhite,
                colorFont: kLightBlue,
                func: viewSessionsModalBottomSheet(context),
              ),
              SizedBox(
                height: 15,
              ),
              RoundedButton(
                title: '       Register       ',
                colorBG: kLightBlue,
                colorFont: kWhite,
                func: () {handleRegistration(widget.activity.activityId);},
              ),
              SizedBox(
                height: 20,
              ),
            ])),
      ),
    );
  }

  void handleRegistration(String activityId) async {
    List<Session> sessionsList = await checkActivityClash(activityId);

    if (sessionsList.length == 0) {
      print('no activity clash');
      try {
        await checkforInAppRewards(activityId);
      }
      on Exception catch (err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: 'Error',
                desc: formatExceptionMessage(err.toString()),
                func: () { Navigator.of(context).pop();},
              );
            }
        );
      }
    }
    else {
      print('there is activity clash');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "The following sessions clash with this activity, please check before proceeding.",
                style: titleTwoTextStyleBold,
              ),
              content: displayActivityClash(sessionsList),
              actions: [
                TextButton(
                  child: Text("Cancel", style: bodyTextStyle,),
                  onPressed: () {Navigator.of(context).pop();},
                ),
                TextButton(
                  child: Text("Yes, proceed", style: bodyTextStyle,),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await checkforInAppRewards(activityId);
                    }
                    on Exception catch (err) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertPopup(
                              title: 'Error',
                              desc: formatExceptionMessage(err.toString()),
                              func: () { Navigator.of(context).pop();},
                            );
                          }
                      );
                    }
                  },
                )
              ],
            );
          }
      );
    }

  }

  Future<List<Session>> checkActivityClash(String activityId) async {
    print('checking activity clash');
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/register/check-clash?activityId=$activityId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Session> sessionsList = [];

      for (dynamic item in resultList) {
        sessionsList.add(Session.fromJson(Map<String, dynamic>.from(item)));
      }

      print('returning activity clash');
      return sessionsList;
    }
    else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception(result['error']['message']);
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while registering for this activity');
    }
  }

  Widget displayActivityClash(List<Session> sessionsList) {
    return Container(
      height: MediaQuery.of(context).size.height*0.5,
      width: MediaQuery.of(context).size.width*0.6,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: sessionsList.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
              child: Card(
                color: Color(0xFFFFCDD2),
                margin: EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                ),
                elevation: 6.0,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 10, 20),
                  child: Container(
                    color: Color(0xFFFFCDD2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${sessionsList[index].activity!.name}',
                          style: titleThreeTextStyleBold,
                        ),
                        SizedBox(height: 3,),
                        Text(
                          'Session ${sessionsList[index].seqNum}',
                          style: subtitleTextStyleBold,
                        ),
                        SizedBox(height: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Starting date:',
                              style: captionTextStyle,
                            ),
                            Text(
                              '${dateFormat.format(sessionsList[index].startTime!)}, '
                                  '${timeFormat.format(sessionsList[index].startTime!)}',
                              style: subtitleTextStyleBold,
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Ending date:',
                              style: captionTextStyle,
                            ),
                            Text(
                              '${dateFormat.format(sessionsList[index].endTime!)}, '
                                  '${timeFormat.format(sessionsList[index].endTime!)}',
                              style: subtitleTextStyleBold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  Future<void> checkforInAppRewards(String activityId) async {
    List<ClaimedReward> inAppRewardsList = await getUserInAppRewards();

    if (inAppRewardsList.isEmpty) {
      try {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: 'No Rewards Found',
                desc: 'We looked at your claimed rewards... and we did not find any that can be used with this activity :(',
                func: () async {
                  Navigator.of(context).pop();
                  try {
                    await doActivityRegistration(activityId: activityId);
                  }
                  on Exception catch (err) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertPopup(
                            title: 'Error',
                            desc: formatExceptionMessage(err.toString()),
                            func: () { Navigator.of(context).pop();},
                          );
                        }
                    );
                  }
                },
                buttonName: 'Continue',
              );
            }
        );
      }
      on Exception catch (err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: 'Error',
                desc: formatExceptionMessage(err.toString()),
                func: () { Navigator.of(context).pop();},
              );
            }
        );
      }
    }
    else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('We Found Rewards for this Activity!', style: titleTwoTextStyleBold,),
              content: ListView.builder(
                itemCount: inAppRewardsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          Text(
                            '${inAppRewardsList[index].reward.name}',
                            style: bodyTextStyle,
                          ),
                          Text(
                            '${inAppRewardsList[index].reward}',
                            style: subtitleTextStyle,
                          ),
                        ],
                      ),
                    ),
                    selected: index == this.selectedRewardIndex,
                    onTap: () {
                      setState(() {
                        this.selectedRewardIndex = index;
                      });
                    },
                  );
                }
              ),
              actions: [
                TextButton(
                  child: Text('Skip', style: bodyTextStyle,),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await doActivityRegistration(activityId: activityId);
                    }
                    on Exception catch (err) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertPopup(
                              title: 'Error',
                              desc: formatExceptionMessage(err.toString()),
                              func: () { Navigator.of(context).pop();},
                            );
                          }
                      );
                    }
                  },
                ),
                TextButton(
                  child: Text('Use This Reward', style: bodyTextStyle,),
                  onPressed: () async {
                    if (this.selectedRewardIndex > -1) {
                      Navigator.of(context).pop();
                      try {
                        await doActivityRegistration(activityId: activityId, claimedRewardId: inAppRewardsList[this.selectedRewardIndex].claimedRewardId);
                      }
                      on Exception catch (err) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertPopup(
                                title: 'Error',
                                desc: formatExceptionMessage(err.toString()),
                                func: () { Navigator.of(context).pop();},
                              );
                            }
                        );
                      }
                    }
                  },
                ),
              ],
            );
          }
      );
    }
  }

  Future<List<ClaimedReward>> getUserInAppRewards() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/reward-svc/mp/reward/list/claimed'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Map<String, dynamic>> mapList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        print(i);
        mapList.add(i);
      }
      List<ClaimedReward> claimedRewardsList = mapList.map((reward) => ClaimedReward.fromJson(reward)).toList();
      List<ClaimedReward> inAppRewardsList = claimedRewardsList.where((cr) => cr.reward.type! == 'inAppReward').toList(); //TODO: double check that i got the field and inAppReward correct
      return inAppRewardsList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during getting inAppRewards');
    }
  }

  Future<void> doActivityRegistration({required String activityId, String? claimedRewardId}) async {
    var response = await widget.http.post(
      Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/register'),
      body: claimedRewardId == null ?
        jsonEncode(<String, String>{
        "activityId": "$activityId",
      }) : jsonEncode(<String, String>{
        "activityId": "$activityId",
        "claimedRewardId" : "$claimedRewardId",
      }),
    );

    if (response.statusCode == 201) {
      print('registration OK');
      var result = jsonDecode(response.body);
      print(result['message']);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertPopup(
              title: 'Success!',
              desc: 'Your registration for ${widget.activity.name} is now pending for approval from the organisation',
              func: () {
                int count = 2;
                Navigator.of(context).popUntil((_) => count-- <= 0);
              },
            );
          }
      );
    }
    else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception(result['error']['message']);
    }
    else {
      var result = jsonDecode(response.body);
      print('doActivityRegistration error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      throw Exception('A problem occured while registering for this activity');
    }
  }

  VoidCallback viewSessionsModalBottomSheet(BuildContext context) {
    return () {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: widget.activity.activitySessionList!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(20, 3, 20, 3),
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
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Session ${index+1}',
                                  style: titleThreeTextStyleBold,
                                ),
                                SizedBox(height: 3,),
                                Text(
                                  '${widget.activity.activitySessionList![index].venue}',
                                  style: subtitleTextStyleBold,
                                ),
                              ],
                            ),
                            SizedBox(height: 3,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                      'Starting date:',
                                      style: captionTextStyle,
                                    ),
                                    Text(
                                      '${dateFormat.format(widget.activity.activitySessionList![index].startTime!)}, '
                                          '${timeFormat.format(widget.activity.activitySessionList![index].startTime!)}',
                                      style: subtitleTextStyleBold,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      'Ending date:',
                                      style: captionTextStyle,
                                    ),
                                    Text(
                                      '${dateFormat.format(widget.activity.activitySessionList![index].endTime!)}, '
                                          '${timeFormat.format(widget.activity.activitySessionList![index].endTime!)}',
                                      style: subtitleTextStyleBold,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Text(
                              '${widget.activity.activitySessionList![index].description}',
                              style: bodyTextStyle,
                              textAlign: TextAlign.left,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          });
    };
  }
}
