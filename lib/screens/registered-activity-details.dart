import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/participant.dart';
import 'package:youthapp/models/session.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class InitRegisteredActivityDetails extends StatelessWidget {
  InitRegisteredActivityDetails({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    final String participantId = ModalRoute.of(context)!.settings.arguments as String;
    return Container(
      color: Colors.white,
      child: FutureBuilder(
          future: initParticipantData(participantId),
          builder: (BuildContext context, AsyncSnapshot<Participant> snapshot) {
            if (snapshot.hasData) {
              final Participant participant = snapshot.data!;
              return RegisteredActivitiesScreen(participant: participant, secureStorage: secureStorage);
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
          }
      ),
    );
  }

  Future<Participant> initParticipantData(String participantId) async {
    final String accessToken = await secureStorage.readSecureData('accessToken');
    final response = await http.get(
      Uri.parse(
          'https://eq-lab-dev.me/api/activity-svc/mp/activity/activity-history/$participantId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return Participant.fromJson(Map<String, dynamic>.from(responseBody));
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}

class RegisteredActivitiesScreen extends StatefulWidget {
  const RegisteredActivitiesScreen({Key? key, required this.participant, required this.secureStorage}) : super(key: key);

  final Participant participant;
  final SecureStorage secureStorage;
  final String placeholderPicUrl =
      'https://media.gettyimages.com/photos/in-this-image-released-on-may-13-marvel-shang-chi-super-hero-simu-liu-picture-id1317787772?s=612x612';

  @override
  _RegisteredActivitiesScreenState createState() => _RegisteredActivitiesScreenState();
}

class _RegisteredActivitiesScreenState extends State<RegisteredActivitiesScreen> {

  DateFormat dateFormat = DateFormat.yMMMd('en_US');
  DateFormat timeFormat = DateFormat.jm('en-US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            children: <Widget>[
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
                    '${activityTypeMap[widget.participant.activity.type]}',
                    style: titleOneTextStyleBold,
                  ),
                  Flexible(
                    child: SizedBox(width: 65),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      widget.participant.activity.mediaContentUrls!.isEmpty
                          ? widget.placeholderPicUrl
                          : widget.participant.activity.mediaContentUrls![0],
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
                            '${widget.participant.activity.name}',
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
                              '${widget.participant.activity.potions}',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF5EC8D8),
                              ),
                            )
                          ],
                        )
                      ]),
                  SizedBox(height: 2,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${widget.participant.activity.organisation!.name}',
                      textAlign: TextAlign.left,
                      style: subtitleTextStyleBold,
                    ),
                  ),
                  SizedBox(height: 20,),
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
                            '${widget.participant.activity.activityStartTime.toString().split(' ')[0]}',
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
                            '${widget.participant.activity.activityEndTime.toString().split(' ')[0]}',
                            style: bodyTextStyleBold,
                          )
                        ]),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
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
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          Text(
                            'You registered on: ',
                            style: captionTextStyle,
                          ),
                          SizedBox(
                            height: 1,
                          ),
                          Text(
                            '${widget.participant.registeredDate.toString().split(' ')[0]}',
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
                            Text('${widget.participant.activity.participantCount}',
                                style: bodyTextStyleBold),
                            Text(' / ', style: bodyTextStyleBold),
                            Text('${widget.participant.activity.applicantPax}',
                                style: bodyTextStyleBold),
                          ]),
                        ]),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          Text(
                            'Current Status: ',
                            style: captionTextStyle,
                          ),
                          SizedBox(
                            height: 1,
                          ),
                          Text(
                            getCapitalizeString(str: '${widget.participant.status}'),
                            style: bodyTextStyleBold,
                          )
                        ]),
                        SizedBox(
                          width: 70,
                        ),
                        Column(children: [
                          Text(
                            'Your attendance: ',
                            style: captionTextStyle,
                          ),
                          SizedBox(
                            height: 1,
                          ),
                          Text('${widget.participant.attendancePercent}%',
                              style: bodyTextStyleBold),
                        ]),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Testimonial:',
                          style: bodyTextStyleBold,
                        ),
                        Text(
                          '${widget.participant.testimonial != null ?
                            widget.participant.testimonial : 'Your testimonial from the organisers is not available yet!'
                          }',
                          style: captionTextStyle,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.participant.activity.description}',
                  style: bodyTextStyle,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              RoundedButton(
                title: 'View Session Attendance',
                colorBG: kLightBlue,
                colorFont: kWhite,
                func: modalBottomSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback modalBottomSheet(BuildContext context) {
    return () {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return FutureBuilder<List<Session>>(
            future: retrieveSessions(),
            builder: (BuildContext context, AsyncSnapshot<List<Session>> snapshot) {
              if (snapshot.hasData) {
                List<Session> sessionsList = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: sessionsList.length,
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
                                Text(
                                  'Session ${index+1}',
                                  style: titleThreeTextStyleBold,
                                ),
                                SizedBox(height: 3,),
                                Text(
                                  '${sessionsList[index].venue}',
                                  style: subtitleTextStyleBold,
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
                                          '${dateFormat.format(sessionsList[index].startTime!)}, '
                                              '${timeFormat.format(sessionsList[index].startTime!)}',
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
                                          '${dateFormat.format(sessionsList[index].endTime!)}, '
                                              '${timeFormat.format(sessionsList[index].endTime!)}',
                                          style: subtitleTextStyleBold,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Text(
                                  '${sessionsList[index].description}',
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
              }
              return Container();
            }
          );
      });
    };
  }

  Future<List<Session>> retrieveSessions() async {
    final String accessToken = await widget.secureStorage.readSecureData(
        'accessToken');

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://eq-lab-dev.me/api/activity-svc/mp/activity/attendance?'
                'activityId=${widget.participant.activity.activityId}'
                '&participantId=${widget.participant.participantId}'
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
      List<Session> sessionResultList = [];
      for (dynamic item in resultList) {
        sessionResultList.add(Session.fromJson(Map<String, dynamic>.from(item)));
      }

      return sessionResultList;
    }
    else {
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occurred during intialising activity data');
    }
  }
}

