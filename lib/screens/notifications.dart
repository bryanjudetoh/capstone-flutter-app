import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:loadmore/loadmore.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/models/notif.dart';


class NotificationsScreenBody extends StatefulWidget {
  NotificationsScreenBody({Key? key, required this.user})
      : super(key: key);

  final User user;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _NotificationsScreenBodyState createState() =>
      _NotificationsScreenBodyState();
}

class _NotificationsScreenBodyState extends State<NotificationsScreenBody> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.notifications,
                style: titleOneTextStyleBold,
              ),
              Icon(
                Icons.more_vert,
                size: 24,
              ),
            ]
          ),
          SizedBox(
            height: 150,
          ),
      Container(
        child: FutureBuilder<List<Notif>>(
            future: getInitialNotifications(),
            builder: (BuildContext context, AsyncSnapshot<List<Notif>> snapshot) {
              if (snapshot.hasData) {
                List<Notif> initialNotifications = snapshot.data!;
                return initialNotifications.isNotEmpty
                    ? NotificationListBody(initialNotifications: initialNotifications, http: widget.http,)
                    : Center( child: noNotifications());
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
        )
      )],
      ),
    );
  }

  Future<List<Notif>> getInitialNotifications() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/notification-svc/mp/received-notification/list?skip=0'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Notif> initialNotifications = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String,dynamic>.from(item);
        initialNotifications.add(Notif.fromJson(i));
      }
      return initialNotifications;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred while loading initial notifications');
    }
  }

  Column noNotifications() {
    return Column(
      children: <Widget>[
        Image(
          image: AssetImage('assets/images/bell-in-circle.png'),
          height: 110,
          width: 110,
        ),
        SizedBox(
          height:10,
        ),
        Text(
          'You have no notifications yet!',
          style: bodyTextStyle,
        )
      ],
    );
  }
}

class NotificationListBody extends StatefulWidget {
  const NotificationListBody({Key? key, required this.initialNotifications, required this.http}) : super(key: key);

  final List<Notif> initialNotifications;
  final InterceptedHttp http;

  @override
  _NotificationListBodyState createState() => _NotificationListBodyState();
}

class _NotificationListBodyState extends State<NotificationListBody> {

  List<Notif> notificationsList = [];
  late int skip;
  late bool isEndOfList;

  @override
  void initState() {
    super.initState();
    this.notificationsList.addAll(widget.initialNotifications);
    this.skip = widget.initialNotifications.length;
    this.isEndOfList = widget.initialNotifications.length < backendSkipLimit ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return LoadMore(
      isFinish: isEndOfList,
      onLoadMore: loadMoreNotifications,
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: this.notificationsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                'notifications',
                style: bodyTextStyle,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> loadMoreNotifications() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/notification-svc/mp/received-notification/list?skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);

      if (resultList.length > 0) {
        List<Notif> notificationsList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String,dynamic>.from(item);
          notificationsList.add(Notif.fromJson(i));
        }
        setState(() {
          this.notificationsList.addAll(notificationsList);
          this.skip += resultList.length;
        });
      }
      else {
        print('no more to add');
        setState(() {
          this.isEndOfList = true;
        });
      }

      return true;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      return false;
    }
  }
}