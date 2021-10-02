import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/activity.dart';
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
        child: FutureBuilder<Map<String, dynamic>>(
          future: initHomeData(widget.secureStorage),
          builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            Widget child = Text('');
            if (snapshot.hasData) {
              Map<String, dynamic> data = snapshot.data!;
              Future.microtask(() {Navigator.pushReplacement(context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => HomeScreen(data: data),
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

  Future<Map<String, dynamic>> initHomeData(SecureStorage secureStorage) async {
    Map<String, dynamic> data = {};

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

      data['user'] = User.fromJson(responseBody);

      for (String type in activityTypesList) {
        print(type);
        data[type] = await getActivityTypeList(type, accessToken);
      }

      return data;
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }

  Future<List<Activity>> getActivityTypeList(String type, String accessToken) async {
    var request = http.Request('GET', Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/featured/list?actType=' + type));
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(jsonDecode(result));

      List<dynamic> resultList = jsonDecode(result);
      List<Map<String, dynamic>> mapList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        mapList.add(i);
      }
      List<Activity> activityResultList = mapList.map((act) => Activity.fromJson(act)).toList();

      return activityResultList;
    } else {
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occurred during intialising activity data');
    }
  }
}



