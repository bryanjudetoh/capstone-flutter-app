import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/notification.dart';
import 'package:youthapp/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/widgets/notif-listtile.dart';

class InitNotificationsScreenBody extends StatefulWidget {
  InitNotificationsScreenBody({Key? key,
    required this.updateNumUnreadNotifications,
    required this.setNumUnreadNotifications
  }) : super(key: key);

  final Function updateNumUnreadNotifications;
  final Function setNumUnreadNotifications;

  @override
  State<InitNotificationsScreenBody> createState() => _InitNotificationsScreenBodyState();
}

class _InitNotificationsScreenBodyState extends State<InitNotificationsScreenBody> {
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  final SecureStorage secureStorage = SecureStorage();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    this._future = initNotificationsData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data!;
          return NotificationsScreenBody(
            user: data['user'],
            initialNotifList: data['initialNotifsList'],
            updateNumUnreadNotifications: this.widget.updateNumUnreadNotifications,
            setNumUnreadNotifications: this.widget.setNumUnreadNotifications,
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
    );
  }

  Future<Map<String, dynamic>> initNotificationsData() async {
    Map<String, dynamic> data = {};
    data['initialNotifsList'] = await retrieveInitialNotifications();
    data['user'] = await getUserDetails();
    return data;
  }

  Future<List<Notif>> retrieveInitialNotifications() async {
    var response = await this.http.get(
      Uri.parse('https://eq-lab-dev.me/api/notification-svc/mp/received-notification/list?skip=0'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Notif> initialNotifList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        //print(i);
        initialNotifList.add(Notif.fromJson(i));
      }

      return initialNotifList;
    }
    else {
      var result = jsonDecode(response.body);
      print('retrieveInitialNotifications error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      throw Exception('A problem occured while retrieving your notifications');
    }
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

class NotificationsScreenBody extends StatefulWidget {
  const NotificationsScreenBody({Key? key,
    required this.user,
    required this.initialNotifList,
    required this.updateNumUnreadNotifications,
    required this.setNumUnreadNotifications,
    required this.http,
  }) : super(key: key);

  final User user;
  final List<Notif> initialNotifList;
  final Function updateNumUnreadNotifications;
  final Function setNumUnreadNotifications;
  final InterceptedHttp http;

  @override
  _NotificationsScreenBodyState createState() => _NotificationsScreenBodyState();
}

class _NotificationsScreenBodyState extends State<NotificationsScreenBody> {

  late List<Notif> notifList;
  late int skip;
  late bool isEndOfList;

  @override
  void initState() {
    super.initState();
    this.isEndOfList = false;
    this.notifList = widget.initialNotifList;
    this.skip = widget.initialNotifList.length;
    if (this.notifList.length < backendSkipLimit) {
      this.isEndOfList = true;
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) =>
        widget.setNumUnreadNotifications(widget.user.numUnreadNotifications));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10),
            child: Text(
              AppLocalizations.of(context)!.notifications,
              style: titleOneTextStyleBold,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: displayNotifList(),
          ),
        ],
      ),
    );
  }

  Widget displayNotifList() {
    if (this.notifList.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height*0.6,
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'You have no notifications',
              style: titleThreeTextStyle,
            )
          ],
        ),
      );
    }
    return LoadMore(
      isFinish: this.isEndOfList,
      onLoadMore: _loadMore,
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: this.notifList.length,
        itemBuilder: (BuildContext context, int index) {
          return NotifListTile(
            notification: this.notifList[index],
            currentIndex: index,
            maxIndex: this.notifList.length - 1,
            updateNumUnreadNotifications: widget.updateNumUnreadNotifications,
            dismiss: dismissNotification,
            http: widget.http,
          );
        }
      ),
    );
  }

  Future<bool> _loadMore() async {
    return await loadMoreNotifs();
  }

  Future<bool> loadMoreNotifs() async {
    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/notification-svc/mp/received-notification/list?skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      if (resultList.length > 0) {
        List<Notif> loadMoreNotifList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String, dynamic>.from(item);
          //print(i);
          loadMoreNotifList.add(Notif.fromJson(i));
        }
        setState(() {
          this.notifList.addAll(loadMoreNotifList);
          this.skip += resultList.length;
          if (resultList.length < backendSkipLimit) {
            print('no more to add');
            this.isEndOfList = true;
          }
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
      print('Load More Notifications error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      return false;
    }
  }

  void dismissNotification(int index) {
    setState(() {
      this.notifList.removeAt(index);
    });
  }
}
