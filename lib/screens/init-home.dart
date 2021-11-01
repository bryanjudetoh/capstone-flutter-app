import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/screens/home.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

class InitHomeScreen extends StatefulWidget {
  InitHomeScreen({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

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

    final response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/user'),
    );

    if (response.statusCode == 200) {
      widget.secureStorage.writeSecureData('user', response.body);
      var responseBody = jsonDecode(response.body);
      //print(responseBody);
      User user = User.fromJson(responseBody);

      return user;
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}



