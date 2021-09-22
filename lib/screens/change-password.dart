import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/onboarding-datepicker.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/widgets/onboarding-textfield.dart';
import 'package:youthapp/widgets/onboarding-dropdown.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:youthapp/widgets/text-button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String password = '';

  @override
  Widget build(BuildContext context) {
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
                              "Edit Profile",
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
                                  title: 'Password:',
                                  hintText: 'Enter your password',
                                  obscureText: true,
                                  callback: (value) => this.password = value!,
                                ),
                                OnboardingTextfield(
                                  title: 'Password:',
                                  hintText: 'Enter your password',
                                  obscureText: true,
                                  callback: (value) => this.password = value!,
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