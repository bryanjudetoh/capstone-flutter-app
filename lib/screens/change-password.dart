import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/widgets/onboarding-textfield.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:http/http.dart' as http;
import 'package:youthapp/widgets/text-button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final SecureStorage secureStorage = SecureStorage();
  final _formkey = GlobalKey<FormState>();
  String oldPassword = '';
  String newPassword = '';

  void submit() async {
    final form = _formkey.currentState!;

    if (form.validate()) {
      form.save();
      final body = jsonEncode(<String, String> {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      print(body);

      try {
        doChangePassword(body);
        Navigator.pushReplacementNamed(context, '/init-home');
      }
      on Exception catch (err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: "Error",
                desc: formatExceptionMessage(err.toString()),);
            }
        );
      }
    }
  }

  void doChangePassword(body) async {
    final String accessToken = await secureStorage.readSecureData('accessToken');

    final response = await http.put(
      Uri.parse('https://eq-lab-dev.me/api/mp/user/password'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer $accessToken'},
      body: body,
    );

    if (response.statusCode == 200) {
      print('success');
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }

  String formatExceptionMessage(String str) {
    int idx = str.indexOf(":");
    return str.substring(idx+1).trim();
  }

  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.only(left: 35.0, right: 35.0, top: 50.0),
                child: Column(
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Change Password",
                              style: titleOneTextStyleBold,
                            ),
                            PlainTextButton(
                              title: 'Back',
                              func: () {
                                Navigator.pop(context);
                              },
                              textStyle: backButtonBoldItalics,
                              textColor: kBlack,
                            ),
                          ]
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Form(
                          key: _formkey,
                          child: Column(
                              children: <Widget>[
                                OnboardingTextfield(
                                  title: 'Current Password:',
                                  hintText: 'Current password',
                                  obscureText: true,
                                  validator: passwordValidator,
                                  callback: (value) => this.oldPassword = value!,
                                ),
                                OnboardingTextfield(
                                  title: 'New Password:',
                                  hintText: 'New password',
                                  obscureText: true,
                                  validator: passwordValidator,
                                  callback: (value) => this.newPassword = value!,
                                ),
                              ]
                          )
                      ),
                      RoundedButton(
                        title: "Update Details",
                        func: submit,
                        colorBG: kLightBlue,
                        colorFont: kWhite,
                      ),
                    ]
                )
            )
        )
    );
  }
}