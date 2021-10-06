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
    final String activityId = ModalRoute
        .of(context)!
        .settings
        .arguments as String;

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
      Uri.parse(
          'https://eq-lab-dev.me/api/activity-svc/mp/activity/' + activityId),
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
  final String placeholderPicUrl = 'https://media.gettyimages.com/photos/in-this-image-released-on-may-13-marvel-shang-chi-super-hero-simu-liu-picture-id1317787772?s=612x612';

  @override
  _ActivityDetailsScreenState createState() =>
      _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  DateFormat dateFormat = DateFormat.yMMMd(
      'en_US'
  );


  @override
  Widget build(BuildContext context) {
    Future<Activity> register(String activityId) async {
      final SecureStorage secureStorage = SecureStorage();

      final String accessToken = await secureStorage.readSecureData('accessToken');

      final response = await http.post(
        Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: activityId,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      else if (response.statusCode == 400) {
        print(jsonDecode(response.body)['error']['message']);
        throw Exception(jsonDecode(response.body)['error']['message']);
      }
      else {
        print(response.body);
        throw Exception('Unforeseen error occured');
      }
    }

      return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {Navigator.of(context).pop();},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios, color: kBlack, size: 25,)
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                        primary: kGrey,
                      ),
                    ),
                    Text(
                      '${widget.activity.type}',
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
                      child: Image.network(
                        widget.activity.mediaContentUrls!.isEmpty
                            ? widget.placeholderPicUrl
                            : widget.activity.mediaContentUrls![0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 220,
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
                                '${widget.activity.potions}',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF5EC8D8),
                                ),
                              )
                            ],
                          )
                        ]
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${widget.activity.organisation!.name}',
                        textAlign: TextAlign.left,
                        style: subtitleTextStyleBold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
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
                                    '${widget.activity.activityStartTime.toString().split(' ')[0]}',
                                    style: bodyTextStyleBold,
                                )
                              ]
                          ),
                          SizedBox(
                            width: 70,
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
                                  '${widget.activity.activityEndTime.toString().split(' ')[0]}',
                                  style: bodyTextStyleBold,
                                )
                              ]
                          ),
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
                              '${widget.activity.registrationEndTime.toString().split(' ')[0]}',
                              style: bodyTextStyleBold,
                            )
                          ]
                      ),
                      SizedBox(
                        width: 70,
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
                                      '${widget.activity.participantCount}',
                                      style: bodyTextStyleBold
                                  ),
                                  Text(
                                      ' / ',
                                      style: bodyTextStyleBold
                                  ),
                                  Text(
                                      '${widget.activity.applicantPax}',
                                      style: bodyTextStyleBold
                                  ),
                                ]
                            ),
                          ]
                      ),
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
                  title: 'Register',
                  colorBG: kLightBlue,
                  colorFont: kWhite,
                  func: () {
                    register(widget.activity.activityId);
                  },
                ),
              ]
          )
        ),
      ),
    );
    }
  }