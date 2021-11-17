import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/models/notification.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/models/participant.dart';
import 'package:youthapp/models/reward.dart';
import 'package:youthapp/screens/rating-fullscreen-dialog.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/widgets/rounded-button.dart';

import '../constants.dart';

class InitNotificationDetailsScreen extends StatelessWidget {
  InitNotificationDetailsScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    final Notif notification = ModalRoute.of(context)!.settings.arguments as Notif;
    return Scaffold(
      backgroundColor: Colors.white,
      body: notification.activity == null && notification.reward == null
          ? NotificationDetailsScreen(notification: notification, http: this.http)
          : FutureBuilder<Map<String, dynamic>>(
              future: getActivityOrReward(notification),
              builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data!;
                  return NotificationDetailsScreen(
                    notification: notification,
                    activity: data['activity'],
                    reward: data['reward'],
                    http: this.http,
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
            ),
    );
  }

  Future<Map<String, dynamic>> getActivityOrReward(Notif notification) async {
    Map<String, dynamic> data = {};
    if (notification.activity != null) {
      var response = await http.get(
        Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/${notification.activity!.activityId}'),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        data['activity'] = Activity.fromJson(Map<String, dynamic>.from(responseBody));
        return data;
      }
      else {
        var result = jsonDecode(response.body);
        print('Get Activity Details error: ${response.statusCode}');
        print('error response body: ${result.toString()}');
        throw Exception(result['error']['message']);
      }
    }
    else if (notification.reward != null) {
      var response = await http.get(
        Uri.parse('https://eq-lab-dev.me/api/reward-svc/mp/reward/${notification.reward!.rewardId}'),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        data['reward'] = Reward.fromJson(Map<String, dynamic>.from(responseBody));
        return data;
      }
      else {
        var result = jsonDecode(response.body);
        print('Get Activity Details error: ${response.statusCode}');
        print('error response body: ${result.toString()}');
        throw Exception(result['error']['message']);
      }
    }
    else {
      throw Exception('you shouldn\'t have reached here... there must be some data problem');
    }
  }
}

class NotificationDetailsScreen extends StatefulWidget {
  const NotificationDetailsScreen({Key? key, required this.notification, this.activity, this.reward, required this.http}) : super(key: key);

  final Notif notification;
  final Activity? activity;
  final Reward? reward;
  final InterceptedHttp http;

  @override
  State<NotificationDetailsScreen> createState() => _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
          child: Column(
            children: [
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
                    'Notification Details',
                    style: titleOneTextStyleBold,
                  ),
                  Flexible(
                    child: SizedBox(width: 65),
                  )
                ],
              ),
              SizedBox(height: 20,),
              displayNotificationDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget displayNotificationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.notification.title}', style: titleOneTextStyle,),
        SizedBox(height: 10,),
        Text('${dateTimeFormat.format(widget.notification.scheduledTime.toLocal())}', style: subtitleTextStyle,),
        SizedBox(height: 30,),
        if (widget.activity != null || this.widget.reward != null)
          Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45, width: 1.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: GestureDetector(
                  onTap: () {
                    if (this.widget.activity != null) {
                      Navigator.pushNamed(context, '/activity-details', arguments: widget.activity!.activityId);
                    }
                    else {
                      Map<String, dynamic> data = {};
                      data['reward'] = widget.reward;
                      Navigator.pushNamed(context, '/reward-details', arguments: data);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      children: <Widget>[
                        if (widget.activity != null)
                          Container(
                            child: widget.activity!.mediaContentUrls!.isEmpty
                                ? Image.network(
                                getPlaceholderPicUrl(widget.activity!.type!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 220,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  print('bad url: ${getPlaceholderPicUrl(widget.activity!.type!)}');
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
                                aspectRatio: 4/3,
                              ),
                              items: widget.activity!.mediaContentUrls!
                                  .map(
                                      (url) => Image.network(
                                      url,
                                      fit: BoxFit.fill,
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
                        if (widget.reward != null)
                          Container(
                            child: widget.reward!.mediaContentUrls!.isEmpty
                                ? Image.network(
                                placeholderRewardsPicUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 220,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  print('bad url: $placeholderRewardsPicUrl');
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
                              items: widget.reward!.mediaContentUrls!
                                  .map(
                                      (url) => Image.network(
                                      url,
                                      fit: BoxFit.fill,
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
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: kBluishWhite,
                            border: Border.all(
                              width: 3,
                              color: kBluishWhite,
                            ),
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.activity != null
                                    ? 'Activity: ${widget.activity!.name}'
                                    : 'Reward: ${widget.reward!.name}',
                                style: bodyTextStyleBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5,),
                              Text(
                                'Description: ${widget.activity != null
                                    ? widget.activity!.description
                                    : widget.reward!.description
                                }',
                                style: smallBodyTextStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30,),
            ],
          ),
        Text('${widget.notification.content}', style: bodyTextStyle,),
        SizedBox(width: double.infinity,),
        if (widget.notification.activity != null)
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(height: 40,),
                RoundedButton(
                  title: ' Rate This Activity ',
                  colorBG: kLightBlue,
                  colorFont: kWhite,
                  func: () async {
                    Participant participant = await getParticipantData();
                    if (participant.submittedRating == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => RatingFullScreenDialog(participant: participant,),
                          fullscreenDialog: true,
                        ),
                      );
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              'You have already rated this activity',
                              style: bodyTextStyle,
                            ),
                            duration: const Duration(seconds: 1),
                          )
                      );
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<Participant> getParticipantData() async {
    final response = await widget.http.get(
      Uri.parse(
          'https://eq-lab-dev.me/api/activity-svc/mp/activity/activity-history/${widget.activity!.participantId}'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return Participant.fromJson(Map<String, dynamic>.from(responseBody));
    }
    else {
      var result = jsonDecode(response.body);
      print(result);

      throw Exception('A problem occured while initialising participant data');
    }
  }
}
