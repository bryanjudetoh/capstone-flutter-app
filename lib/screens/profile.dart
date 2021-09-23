import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import '../constants.dart';

class InitProfileScreenBody extends StatefulWidget {
  const InitProfileScreenBody({Key? key}) : super(key: key);

  @override
  _InitProfileScreenBodyState createState() => _InitProfileScreenBodyState();
}

class _InitProfileScreenBodyState extends State<InitProfileScreenBody> {

  final SecureStorage secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: this.secureStorage.readSecureData('user'),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          User user = User.fromJson(jsonDecode(snapshot.data!));
          return ProfileScreenBody(user: user, secureStorage: secureStorage,);
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
                  child: Text('Error: ${snapshot.error}' , style: titleTwoTextStyleBold,),
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
                  child: Text('Loading...', style: titleTwoTextStyleBold,),
                )
              ],
            ),
          );
        }
      }
    );
  }
}

class ProfileScreenBody extends StatefulWidget {
  const ProfileScreenBody({Key? key, required this.user, required this.secureStorage}) : super(key: key);

  final User user;
  final SecureStorage secureStorage;

  @override
  _ProfileScreenBodyState createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody> {

  bool rebuildWidget = true;
  String? profilePicUrl = '';

  @override
  Widget build(BuildContext context) {
    if(widget.user.profilePicUrl != null) {
      this.profilePicUrl = widget.user.profilePicUrl;
    }

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
                  IconButton(
                    onPressed: modalBottomSheet(context, widget.secureStorage, widget.user),
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 30,
                      color: kDarkGrey,
                    ),
                  )
                ]
            ),
            SizedBox( height: 20, ),
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
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: this.profilePicUrl!.isNotEmpty ? NetworkImage('https://cdn.eq-lab-dev.me/' + this.profilePicUrl!) : Image.asset('assets/images/default-profilepic.png').image,
                          maxRadius: 40,
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              "${widget.user.firstName} ${widget.user.lastName}",
                              textAlign: TextAlign.left,
                              style: bodyTextStyleBold,
                            ),
                            Text(
                              '${widget.user.school}',
                              textAlign: TextAlign.left,
                              style: captionTextStyle,
                            ),
                            Text(
                              '${widget.user.city}',
                              textAlign: TextAlign.left,
                              style: captionTextStyle,
                            ),
                            Text(
                              'Born on ${widget.user.dob.toString().split(' ')[0]}',
                              textAlign: TextAlign.left,
                              style: captionTextStyle,
                            ),
                            Text(
                              '${widget.user.email}',
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



  VoidCallback modalBottomSheet(BuildContext context, SecureStorage secureStorage, User user) {
    return () { showModalBottomSheet(context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: new Icon(Icons.edit),
                title: new Text('Edit Account Details'),
                onTap: () async {
                  final value = await Navigator.pushReplacementNamed(context, '/edit-account-details', arguments: user);
                  setState(() {
                    this.rebuildWidget = this.rebuildWidget == value ? false : true;
                  });
                },
              ),
              ListTile(
                leading: new Icon(Icons.edit),
                title: new Text('Change Password'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/change-password', arguments: user);
                },
              ),
              ListTile(
                leading: new Icon(Icons.logout),
                title: new Text('Logout'),
                onTap: () {
                  doLogout(context, secureStorage);
                },
              ),
            ],
          );
        }
    ); };
  }

  void doLogout(BuildContext context, secureStorage) {
    secureStorage.deleteAllData();
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }
}
