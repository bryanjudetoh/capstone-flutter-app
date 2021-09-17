import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/rounded-button.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);


  final SecureStorage secureStorage = SecureStorage();
  late final User user;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {



  _HomeScreenState() {
    retrieveUserFromStorage(widget.secureStorage).then((value) => widget.user = value);
    print('loaded user from secure storage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('This is a home screen', style: bodyTextStyleBold,),
    );
  }

  Future<User> retrieveUserFromStorage(SecureStorage secureStorage) async {
    final jsonUser = await secureStorage.readSecureData('user');
    return User.fromJson(jsonDecode(jsonUser));
  }
}
