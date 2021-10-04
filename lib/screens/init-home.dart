import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/screens/home.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:http/http.dart' as http;

class InitHomeScreen extends StatefulWidget {
  InitHomeScreen({Key? key}) : super(key: key);


  final SecureStorage secureStorage = SecureStorage();

  @override
  _InitHomeScreenState createState() => _InitHomeScreenState();
}

class _InitHomeScreenState extends State<InitHomeScreen> {
  int selectedIndex = 0;
  List<Widget> widgetOptions = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<User>(
          future: initHomeData(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            Widget child = Text('');
            if (snapshot.hasData) {
              User user = snapshot.data!;
              Future.microtask(() {Navigator.pushReplacement(context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => HomeScreen(user: user),
                  )
              );});
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
                      child: Text('Error: ${snapshot.error}' , style: titleTwoTextStyleBold, textAlign: TextAlign.center,),
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
                      child: Text('Loading...', style: titleTwoTextStyleBold,),
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
      ),
    );
  }

  Future<User> initHomeData() async {
    final String accessToken = await widget.secureStorage.readSecureData('accessToken');

    final response = await http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      widget.secureStorage.writeSecureData('user', response.body);
      var responseBody = jsonDecode(response.body);

      User user = User.fromJson(responseBody);

      return user;
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}



