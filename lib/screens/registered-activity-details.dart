import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/participant.dart';
import 'package:youthapp/models/session.dart';
import 'package:youthapp/screens/rating-fullscreen-dialog.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';

class InitRegisteredActivityDetails extends StatelessWidget {
  InitRegisteredActivityDetails({Key? key}) : super(key: key);
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

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
              return RegisteredActivitiesScreen(participant: participant);
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
    final response = await http.get(
      Uri.parse(
          'https://eq-lab-dev.me/api/activity-svc/mp/activity/activity-history/$participantId'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return Participant.fromJson(Map<String, dynamic>.from(responseBody));
    }
    else {
      var result = jsonDecode(response.body);
      print(result);

      throw Exception('A problem occured while initialising activity data');
    }
  }
}

class RegisteredActivitiesScreen extends StatefulWidget {
  RegisteredActivitiesScreen({Key? key, required this.participant}) {
    placeholderPicUrl = getPlaceholderPicUrl(participant.activity.type!);
  }

  final Participant participant;
  late final String placeholderPicUrl;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _RegisteredActivitiesScreenState createState() => _RegisteredActivitiesScreenState();
}

class _RegisteredActivitiesScreenState extends State<RegisteredActivitiesScreen> {

  late bool isRated;

  @override
  void initState() {
    super.initState();
    if (widget.participant.submittedRating! > 0.0) {
      this.isRated = true;
    }
    else {
      this.isRated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
                    child: widget.participant.activity.mediaContentUrls!.isEmpty
                      ? Image.network(
                      widget.placeholderPicUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 220,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        print('bad url: ${widget.placeholderPicUrl}');
                        return const Center(
                          child: Text('Couldn\'t load image.', style: bodyTextStyle,),
                        );
                      }
                    )
                        : CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: false,
                        enableInfiniteScroll: true,
                        viewportFraction: 1.0,
                      ),
                      items: widget.participant.activity.mediaContentUrls!
                          .map(
                              (url) => Image.network(
                                url,
                                fit: BoxFit.fitHeight,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  print('bad url: $url');
                                  return const Center(
                                    child: Text('Couldn\'t load image.', style: bodyTextStyle,),
                                  );
                                }
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
                          width: MediaQuery.of(context).size.width*0.5,
                          child: Text(
                            '${widget.participant.activity.name}',
                            style: titleOneTextStyleBold,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                image: AssetImage('${activityTypeToPotionColorPathMap[widget.participant.activity.type]}'),
                                height: 40,
                                width: 40,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width*0.2,
                                ),
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  '${widget.participant.activity.potions}',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Color(0xFF5EC8D8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.participant.multiplier == 2)
                                Row(
                                  children: [
                                    SizedBox(width: 10,),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      margin: EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        color: kLightBlue,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.amberAccent,
                                            spreadRadius: 3.0,
                                            blurRadius: 3.0,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'x2',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ]),
                  SizedBox(height: 2,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${widget.participant.activity.organisation!.name}',
                        textAlign: TextAlign.left,
                        style: subtitleTextStyleBold,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            '${widget.participant.activity.activityRating}',
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
                  SizedBox(height: 20,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            '${dateFormat.format(widget.participant.activity.activityStartTime!)}',
                            style: bodyTextStyleBold,
                          )
                        ]),
                        Column(children: [
                          Text(
                            'End date',
                            style: captionTextStyle,
                          ),
                          SizedBox(
                            height: 1,
                          ),
                          Text(
                            '${dateFormat.format(widget.participant.activity.activityEndTime!)}',
                            style: bodyTextStyleBold,
                          )
                        ]),
                        Column(
                          children: <Widget>[
                            Text(
                              'Price',
                              style: captionTextStyle,
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            Text(
                              widget.participant.activity.registrationPrice! > 0
                                  ? 'USD \$${widget.participant.activity.registrationPrice!.toStringAsFixed(2)}'
                                  : 'Free'
                              ,
                              style: bodyTextStyleBold,
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(20.0),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                '${dateFormat.format(widget.participant.registeredDate!.toLocal())}',
                                style: bodyTextStyleBold,
                              )
                            ]),
                            SizedBox(
                              height: 15,
                            ),
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
                          ],
                        ),
                        SizedBox(width: 50,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                            SizedBox(
                              height: 15,
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
                      ],
                    ),
                    if (widget.participant.status != "registered" && widget.participant.status != "rejected")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 20,),
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
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
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
                            '${activityTypeToPotionColorPathMap[widget.participant.activity.type]}'),
                        height: 25,
                        width: 25,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top:3),
                        child: Text('${widget.participant.awardedPotions}',
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: kLightBlue,
                        padding: EdgeInsets.fromLTRB(10, 3, 13, 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                    onPressed: () {
                      Map<String, dynamic> data = {};
                      data['sharedActivity'] = widget.participant.activity;
                      Navigator.pushNamed(context, '/create-post-shared', arguments: data);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share,),
                        SizedBox(width: 5,),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 20.0,
                            height: 1.25,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.participant.activity.description}',
                  style: bodyTextStyle,
                ),
              ),
              SizedBox(height: 30,),
              if (widget.participant.status == 'completed')
                RoundedButton(
                  title: ' Rate This Activity ',
                  colorBG: kWhite,
                  colorFont: kLightBlue,
                  func: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => RatingFullScreenDialog(participant: widget.participant,),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  disableText: this.isRated ? '    Already Rated    ' : null,
                ),
              SizedBox(height: 20,),
              if (widget.participant.status == 'accepted' || widget.participant.status == 'completed')
                RoundedButton(
                  title: 'View Attendances',
                  colorBG: kLightBlue,
                  colorFont: kWhite,
                  func: viewAttendanceModalBottomSheet(context),
                  disableText: widget.participant.status == "registered" ? 'Pending Acceptance' : null,
                ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback viewAttendanceModalBottomSheet(BuildContext context) {
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
                    print('Session ${index + 1}, attended: ${sessionsList[index].attended!}');
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
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
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text('Attended:',
                                          style: titleThreeTextStyleBold,
                                        ),
                                        SizedBox(width: 3,),
                                        Padding(
                                          padding: EdgeInsets.only(top: 3),
                                          child: Icon(
                                            sessionsList[index].attended! ?
                                            Icons.check_circle_outline : Icons.cancel_outlined,
                                            size: 20,
                                            color: sessionsList[index].attended! ?
                                            Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    )
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
              else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: titleTwoTextStyleBold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            }
          );
      });
    };
  }

  Future<List<Session>> retrieveSessions() async {

    var response = await widget.http.get(
        Uri.parse(
            'https://eq-lab-dev.me/api/activity-svc/mp/activity/attendance?'
                'activityId=${widget.participant.activity.activityId}'
                '&participantId=${widget.participant.participantId}'
        )
    );

    if (response.statusCode == 200) {

      List<dynamic> resultList = jsonDecode(response.body);
      List<Session> sessionResultList = [];
      for (dynamic item in resultList) {
        sessionResultList.add(Session.fromJson(Map<String, dynamic>.from(item)));
      }

      return sessionResultList;
    }
    else {
      var result = jsonDecode(response.body);
      print('status code: ${response.statusCode} + $result');
      throw Exception('A problem occurred during intialising activity data');
    }
  }
}

