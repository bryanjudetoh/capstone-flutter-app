import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:http/http.dart' as http;

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
        future: retrieveUser(widget.secureStorage),
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
    );
  }

  Future<User> retrieveUser(SecureStorage secureStorage) async {
    final String accessToken = await secureStorage.readSecureData('accessToken');

    final response = await http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      secureStorage.writeSecureData('user', response.body);
      var responseBody = jsonDecode(response.body);
      return User.fromJson(responseBody);
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}



