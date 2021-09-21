import 'package:flutter/material.dart';
import 'package:youthapp/models/user.dart';

import '../constants.dart';

class ProfileScreenBody extends StatelessWidget {
  const ProfileScreenBody({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    const captionTextStyle = TextStyle(
      fontFamily: 'SF Pro Display',
      fontSize: 15.0,
      height: 1.25,
      color: kDarkGrey,
    );

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
            height: 20,
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 3,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Image(
                      image: AssetImage('assets/images/profile-img.png'),
                      height: 80,
                      width: 80,
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          'Behbat',
                          textAlign: TextAlign.left,
                          style: bodyTextStyleBold,
                        ),
                        Text(
                          '77th school',
                          textAlign: TextAlign.left,
                          style: captionTextStyle,
                        ),
                        Text(
                          '12th grade',
                          textAlign: TextAlign.left,
                          style: captionTextStyle,
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/images/elixir.png'),
                          height: 40,
                          width: 40,
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              'Elixirs',
                              style: captionTextStyle,
                            ),
                            Text(
                              '1/100',
                              style: bodyTextStyleBold,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          'Friends',
                          style: captionTextStyle,
                        ),
                        Text(
                          '52',
                          style: bodyTextStyleBold,
                        ),
                      ]
                    )
                  ]
                )
              ]
            )
          )
        ],
      ),
    );
  }
}