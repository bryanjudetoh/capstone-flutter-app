import 'package:flutter/material.dart';
import 'package:youthapp/models/user.dart';

class NotificationsScreenBody extends StatelessWidget {
  const NotificationsScreenBody({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: Text(
              'This is the notifications'
          ),
        ),
      ],
    );
  }
}