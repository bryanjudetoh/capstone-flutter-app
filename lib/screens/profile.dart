import 'package:flutter/material.dart';
import 'package:youthapp/models/user.dart';

import '../constants.dart';

class ProfileScreenBody extends StatelessWidget {
  const ProfileScreenBody({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 35.0, right: 35.0, top: 50.0),
      child: Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Profile',
                  style: titleOneTextStyleBold,
                ),
                Icon(
                  Icons.settings_outlined,
                  size: 24,
                  color: kDarkGrey,
                ),
              ]
          ),
          SizedBox(
            height: 150,
          ),
        ],
      ),
    );
  }
}