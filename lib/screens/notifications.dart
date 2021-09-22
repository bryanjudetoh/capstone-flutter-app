import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';

class NotificationsScreenBody extends StatelessWidget {
  const NotificationsScreenBody({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 35.0, right: 35.0, top:50.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Notifications',
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
          Column(
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
          )
        ],
      ),
    );
  }
}