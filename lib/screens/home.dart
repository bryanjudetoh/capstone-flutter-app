import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/rounded-button.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);


  final SecureStorage secureStorage = SecureStorage();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User>(
        future: retrieveUserFromStorage(widget.secureStorage),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            User user = snapshot.data!;
            children = <Widget>[
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              Padding(padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Received ${user.firstName}\'s user data',
                    style: titleTwoTextStyleBold,
                  ),
              ),
              RoundedButton(
                  title: 'Clear secure storage',
                  func: widget.secureStorage.deleteAllData,
                  colorBG: kLightBlue,
                  colorFont: kWhite
              )
            ];
          }
          else if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}' , style: titleTwoTextStyleBold,),
              ),
            ];
          }
          else {
            children = const <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Loading user...', style: titleTwoTextStyleBold,),
              )
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }

  Future<User> retrieveUserFromStorage(SecureStorage secureStorage) async {
    final jsonUser = await secureStorage.readSecureData('user');
    return User.fromJson(jsonDecode(jsonUser));
  }
}

