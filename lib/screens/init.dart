import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/rounded-button.dart';

class InitialiseHomeScreen extends StatefulWidget {
  InitialiseHomeScreen({Key? key}) : super(key: key);


  final SecureStorage secureStorage = SecureStorage();

  @override
  _InitialiseHomeScreenState createState() => _InitialiseHomeScreenState();
}

class _InitialiseHomeScreenState extends State<InitialiseHomeScreen> {
  int selectedIndex = 0;
  List<Widget> widgetOptions = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User>(
        future: retrieveUserFromStorage(widget.secureStorage),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          Widget child = Text('');
          if (snapshot.hasData) {
            User user = snapshot.data!;
            Future.microtask(() {Navigator.pushReplacementNamed(context, '/home', arguments: user);});
          }
          else if (snapshot.hasError) {
            child = Center(
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
            child = Center(
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
                    child: Text('Loading user...', style: titleTwoTextStyleBold,),
                  )
                ],
              ),
            );
          }
          return Container(
            child: child,
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



