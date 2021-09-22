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
  String email = '';
  String firstName = '';
  String lastName = '';
  String mobile = '';
  String gender = genderList[0];
  String age = '';
  DateTime dob = DateTime.now();
  String address1 = '';
  String address2 = '';
  String address3 = '';
  String postalCode = '';
  String countryCode = countryCodesList[0];
  String city = '';
  String school = '';

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
                        func: () {Navigator.pop(context);},
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
                        title: 'First Name:',
                        hintText: 'Behbat',
                        callback: (value) => this.firstName = value!,
                      ),// FirstName
                      OnboardingTextfield(
                          title: 'Last Name:',
                          hintText: 'Wong',
                          callback: (value) => this.lastName = value!
                      ),// LastName
                      OnboardingTextfield(
                          title: 'Mobile Number:',
                          hintText: 'Enter your mobile number',
                          callback: (value) => this.mobile = value!
                      ),// Mobile
                      OnboardingTextfield(
                        title: 'Email:',
                        hintText: 'Enter your email',
                        initialValue: this.email,
                        callback: (value) => this.email = value!,
                      ),// Email
                      OnboardingDropdown(
                        title: 'Gender',
                        input: this.gender,
                        list: genderList,
                        callback: (value) => this.gender = value!,
                      ),// Gender
                      OnboardingTextfield(
                        title: 'Age:',
                        hintText: 'Enter your age',
                        callback: (value) => this.age = value!,
                      ),// Age
                      OnboardingDatepicker(
                        title: 'Date of Birth:',
                        callback: (value) => this.dob = value!,
                      ),// DOB
                      OnboardingTextfield(
                        title: 'Address Line 1:',
                        hintText: 'Enter your address',
                        callback: (value) => this.address1 = value!,
                      ),// Address1
                      OnboardingTextfield(
                        title: 'Address Line 2:',
                        hintText: 'Enter your address',
                        callback: (value) => this.address2 = value!,
                      ),// Address2
                      OnboardingTextfield(
                        title: 'Address Line 3:',
                        hintText: 'Enter your address',
                        callback: (value) => this.address3 = value!,
                      ),// Address3
                      OnboardingTextfield(
                        title: 'Postal Code:',
                        hintText: 'Enter your postal code',
                        callback: (value) => this.postalCode = value!,
                      ),// Postal Code
                      OnboardingDropdown(
                        title: 'Country Code:',
                        input: this.countryCode,
                        list: countryCodesList,
                        callback: (value) => this.countryCode = value!,
                      ),// Country Code
                      OnboardingTextfield(
                        title: 'City:',
                        hintText: 'Enter your city',
                        callback: (value) => this.city = value!,
                      ),// City
                      OnboardingTextfield(
                        title: 'School:',
                        hintText: 'Enter your school',
                        callback: (value) => this.school = value!,
                      ),/// School
                    ],
                  ),
                ),
                RoundedButton(
                  title: "Update Details",
                  func: submit,
                  colorBG: kLightBlue,
                  colorFont: kWhite,
                ),
              ],
            )
          ),
      ),
    );
  }