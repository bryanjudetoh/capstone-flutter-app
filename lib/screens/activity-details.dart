import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class InitActivityDetailsScreen extends StatelessWidget {
  InitActivityDetailsScreen({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    final String activityId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Activity>(
        future: retrieveActivity(activityId),
        builder: (BuildContext context, AsyncSnapshot<Activity> snapshot) {
          if (snapshot.hasData) {
            Activity activity = snapshot.data!;
            //if activity is registered
            return ActivityDetailsScreen(activity: activity);
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
        },
      ),
    );
  }

  Future<Activity> retrieveActivity(String activityId) async {
    final String accessToken =
    await secureStorage.readSecureData('accessToken');
    final response = await http.get(
      Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/' + activityId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
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
  const ActivityDetailsScreen({Key? key, required this.activity})
      : super(key: key);

  final Activity activity;

  @override
  _ActivityDetailsScreenState createState() =>
      _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(new DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: kBluishWhite,
                      child: BackButton(
                        color: kBlack,
                      )
                    ),
                    Text(
                      'Volunteering',
                      style: titleOneTextStyle,
                    ),
                    CircleAvatar(
                        radius: 30,
                        backgroundColor: kBluishWhite,
                        child: IconButton(
                          color: kBlack,
                          icon: Icon(Icons.favorite_border),
                          onPressed: () {},
                        )
                    ),
                  ]),
              SizedBox(
                height: 20.0,
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage('assets/images/temp-homescreen-carousel-images/pride-board/pride-board-1.png',),
                      height: 360,
                      width: 300,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mangrove forest cleanup 2021',
                          style: titleOneTextStyleBold,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Image(
                                image: AssetImage('assets/images/elixir.png'),
                                height: 40,
                                width: 40,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                '15',
                                style: titleOneTextStyle,
                              ),
                            ],
                        )
                      ]
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      'Equity Lab',
                      style: subtitleTextStyleBold,
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Start date',
                              style: captionTextStyle,
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            Text(
                              '${formattedDate}'
                            )
                          ]
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                            children: [
                              Text(
                                'End date',
                                style: captionTextStyle,
                              ),
                              SizedBox(
                                height: 1,
                              ),
                              Text(
                                  '${formattedDate}'
                              )
                            ]
                        ),
                      ],
                    ),
                    Container(
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(bottom: 30.0),
                        decoration: BoxDecoration(
                            color: kBluishWhite,
                            border: Border.all(
                              width: 3,
                              color: kBluishWhite,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 20, // changes position of shadow
                              ),
                            ]),
                        child:
                          Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                  children: [
                                    Text(
                                      'Registration ends',
                                      style: captionTextStyle,
                                    ),
                                    SizedBox(
                                      height: 1,
                                    ),
                                    Text(
                                        '${formattedDate}'
                                    )
                                  ]
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                  children: [
                                    Text(
                                      'No. of participants',
                                      style: captionTextStyle,
                                    ),
                                    SizedBox(
                                      height: 1,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '23',
                                          style: bodyTextStyleBold
                                        ),
                                        Text(
                                          ' / ',
                                          style: bodyTextStyleBold
                                        ),
                                        Text(
                                          '50',
                                          style: bodyTextStyleBold
                                        ),
                                      ]
                                    ),
                                  ]
                              ),
                            ],
                          ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'This is a description',
                      style: bodyTextStyle,
                    ),
                    RoundedButton(
                      title: 'Register',
                      colorBG: kLightBlue,
                      colorFont: kWhite,
                      func: () {},
                    ),
                  ]
              )
            ],
          ),
        ),
      ),
    );
  }
}