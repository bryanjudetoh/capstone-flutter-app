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

    const tabTextStyle = TextStyle(
      fontFamily: 'SF Pro Display',
      fontSize: 15.0,
      height: 1.25,
      color: Colors.white,
    );

    return Container(
      margin: EdgeInsets.only(left: 35.0, right: 35.0, top: 50.0),
      child: SingleChildScrollView(
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
              margin: EdgeInsets.only(bottom: 30.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 3,
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20, // changes position of shadow
                ),
              ]
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
                          Row(
                            children: <Widget>[
                              Text(
                                '77th school / ',
                                textAlign: TextAlign.left,
                                style: captionTextStyle,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                'Mongolia',
                                textAlign: TextAlign.left,
                                style: captionTextStyle,
                              ),
                            ]
                          ),
                          Row(
                              children: <Widget>[
                                Text(
                                  'Born on 12 May 2001 / ',
                                  textAlign: TextAlign.left,
                                  style: captionTextStyle,
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  'Male',
                                  textAlign: TextAlign.left,
                                  style: captionTextStyle,
                                ),
                              ]
                          ),
                          Text(
                            'behbat@77.com',
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        width: 10,
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
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 100,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: kLightBlue,
                    border: Border.all(
                      width: 1,
                      color: kLightBlue,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Upcoming',
                    style: tabTextStyle,
                  ),
                ),
                Container(
                  width: 100,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: kGrey,
                    border: Border.all(
                      width: 1,
                      color: kGrey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Progress',
                    style: captionTextStyle,
                  ),
                ),
                Container(
                  width: 100,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: kGrey,
                    border: Border.all(
                      width: 1,
                      color: kGrey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Posts',
                    style: captionTextStyle,
                  ),
                ),
              ]
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage('assets/images/profile-sample-activity.png'),
                  height: 360,
                  width: 300,
                ),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Fun Mangrove Swamp Cleanup',
                      textAlign: TextAlign.left,
                      style: bodyTextStyleBold,
                    ),
                    Row(
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/images/elixir.png'),
                          height: 16,
                          width: 16,
                        ),
                        Text(
                          '15',
                          style: bodyTextStyleBold,
                        )
                      ]
                    ),
                  ]
                ) */
              ]
            )
          ],
        ),
      ),
    );
  }
}