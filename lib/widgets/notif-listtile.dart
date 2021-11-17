import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:youthapp/models/notification.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import '../constants.dart';

class NotifListTile extends StatefulWidget {
  const NotifListTile({Key? key,
    required this.notification,
    required this.currentIndex,
    required this.maxIndex,
    required this.updateNumUnreadNotifications,
    required this.dismiss,
    required this.http,
  }) : super(key: key);

  final Notif notification;
  final int currentIndex;
  final int maxIndex;
  final Function updateNumUnreadNotifications;
  final Function dismiss;
  final InterceptedHttp http;

  @override
  _NotifListTileState createState() => _NotifListTileState();
}

class _NotifListTileState extends State<NotifListTile> {

  late bool hasRead;

  @override
  void initState() {
    super.initState();
    this.hasRead = widget.notification.hasRead;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Dismissible(
          key: Key(widget.notification.notificationId),
          background: slideLeftBackground(),
          direction: DismissDirection.endToStart,
          dismissThresholds: {
            DismissDirection.endToStart: 0.3
          },
          onDismissed: (DismissDirection direction) async {
            await doDismiss();
          },
          child: FocusedMenuHolder(
            menuWidth: MediaQuery.of(context).size.width*0.50,
            blurSize: 5.0,
            menuItemExtent: 45,
            menuOffset: 5,
            menuBoxDecoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.all(Radius.circular(30.0))),
            duration: Duration(milliseconds: 100),
            animateMenuItems: false,
            blurBackgroundColor: Colors.black54,
            bottomOffsetHeight: 100,
            menuItems: <FocusedMenuItem>[
              FocusedMenuItem(
                title: Text('Open', style: smallBodyTextStyle,),
                trailingIcon: Icon(Icons.open_in_new) ,
                onPressed: () {},
              ),
              if (!this.hasRead)
                FocusedMenuItem(
                  title: Text('Mark as read', style: smallBodyTextStyle,),
                  trailingIcon: Icon(Icons.mark_chat_read_outlined),
                  onPressed: () async {
                    await doMarkAsRead();
                  },
                ),
              if (this.hasRead)
                FocusedMenuItem(
                  title: Text('Mark as unread', style: smallBodyTextStyle,),
                  trailingIcon: Icon(Icons.mark_chat_unread),
                  onPressed: () async {
                    await doMarkAsUnread();
                  },
                ),
              FocusedMenuItem(
                title: Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 15.0,
                    height: 1.25,
                    color: Colors.redAccent,
                  ),
                ),
                trailingIcon: Icon(Icons.delete,color: Colors.redAccent,),
                onPressed: () async {
                  await doDismiss();
                },
              ),
            ],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    print('tapped');
                  },
                  child: ListTile(
                    minVerticalPadding: 15,
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 7, 10, 0),
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: this.hasRead ? Colors.transparent : Colors.red,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.8,
                              child: Text(
                                '${widget.notification.isSystemTriggered ? '[System] ' : ''}'
                                    '${widget.notification.title}',
                                style: titleThreeTextStyleBold,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Container(
                              width: MediaQuery.of(context).size.width*0.8,
                              child: Text(
                                '${widget.notification.content}',
                                style: titleThreeTextStyle,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text(
                              '${dateTimeFormat.format(widget.notification.scheduledTime.toLocal())}',
                              style: subtitleTextStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            onPressed: () {},
          ),
        ),
        if (widget.currentIndex < widget.maxIndex)
          Divider(
            indent: 10,
            endIndent: 10,
            height: 30,
            thickness: 1,
            color: Colors.black54,
          ),
      ],
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: tabTextStyle,
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Future<void> doMarkAsRead() async {
    String message = '';
    try {
      message = await doMarkNotification(true);
      setState(() {
        this.hasRead = true;
      });
      widget.updateNumUnreadNotifications(-1);
    }
    on Exception catch (err) {
      message = formatExceptionMessage(err.toString());
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: bodyTextStyle,
          ),
          duration: const Duration(seconds: 1),
        )
    );
  }

  Future<void> doMarkAsUnread() async {
    String message = '';
    try {
      message = await doMarkNotification(false);
      setState(() {
        this.hasRead = false;
      });
      widget.updateNumUnreadNotifications(1);
    }
    on Exception catch (err) {
      message = formatExceptionMessage(err.toString());
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: bodyTextStyle,
          ),
          duration: const Duration(seconds: 1),
        )
    );
  }

  Future<String> doMarkNotification(bool isMarkRead) async {
    var response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/notification-svc/mp/received-notification/${widget.notification.notificationId}?read=$isMarkRead'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody['msg'];
    }
    else if (response.statusCode == 400) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print('Mark Notification error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      throw Exception('A problem occured while marking this notification as ${isMarkRead ? 'read' : 'unread'}');
    }
  }

  Future<void> doDismiss() async {
    String message = '';
    try {
      message = await doDeleteNotification();
      if (!this.hasRead) {
        setState(() {
          this.hasRead = true;
        });
        widget.updateNumUnreadNotifications(-1);
      }
      widget.dismiss(widget.currentIndex);
    }
    on Exception catch (err) {
      message = formatExceptionMessage(err.toString());
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: bodyTextStyle,
          ),
          duration: const Duration(seconds: 1),
        )
    );
  }

  Future<String> doDeleteNotification() async {
    print('dismissing : ${widget.notification.notificationId}');
    var response = await widget.http.delete(
        Uri.parse('https://eq-lab-dev.me/api/notification-svc/mp/received-notification/${widget.notification.notificationId}'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody['msg'];
    }
    else if (response.statusCode == 400) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print('Delete Notification error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      throw Exception('A problem occured while deleteing this notification');
    }
  }
}
