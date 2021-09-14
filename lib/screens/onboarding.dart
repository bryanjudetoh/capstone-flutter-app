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

class OnboardingScreen extends StatefulWidget {
  final String? email;
  const OnboardingScreen({Key? key, this.email }) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formkey = GlobalKey<FormState>();
  String email = '';
  String password = '';
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
    String inputEmail = ModalRoute.of(context)!.settings.arguments as String;

    if ( inputEmail.length > 0) {
      this.email = inputEmail; //remove quotation marks
    }


    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
        child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Onboarding",
                    style: xLargeTitleTextStyle,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: mediumTitleTextStyle,
                    ),
                    onPressed: () {Navigator.pop(context);},
                    child: const Text('Back',
                      style: TextStyle( fontFamily: "SF Pro Display", fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.black),
                    ),
                  ),
                ]
            ),
            SizedBox( height: 10.0,),
            Form(
              key: _formkey,
              child: Column(
                children: <Widget>[
                  OnboardingTextfield(
                      title: 'First Name:',
                      hintText: 'John',
                      validator: RequiredValidator(errorText: "* Required"),
                      callback: (value) => this.firstName = value!,
                  ),// FirstName
                  OnboardingTextfield(
                      title: 'Last Name:',
                      hintText: 'Wong',
                      validator: RequiredValidator(errorText: "* Required"),
                      callback: (value) => this.lastName = value!
                  ),// LastName
                  OnboardingTextfield(
                      title: 'Mobile Number:',
                      hintText: 'Enter your mobile number',
                      validator: mobileNumValidator,
                      callback: (value) => this.mobile = value!
                  ),// Mobile
                  OnboardingTextfield(
                      title: 'Email:',
                      hintText: 'Enter your email',
                      initialValue: this.email,
                      validator: emailValidator,
                      callback: (value) => this.email = value!,
                  ),// Email
                  OnboardingTextfield(
                      title: 'Password:',
                      hintText: 'Enter your password',
                      obscureText: true,
                      validator: passwordValidator,
                      callback: (value) => this.password = value!,
                  ),// Password
                  OnboardingDropdown(
                      title: 'Gender',
                      input: this.gender,
                      list: genderList,
                      callback: (value) => this.gender = value!,
                  ),// Gender
                  OnboardingTextfield(
                      title: 'Age:',
                      hintText: 'Enter your age',
                      validator: ageValidator,
                      callback: (value) => this.age = value!,
                  ),// Age
                  OnboardingDatepicker(
                      title: 'Date of Birth:',
                      callback: (value) => this.dob = value!,
                  ),// DOB
                  OnboardingTextfield(
                    title: 'Address 1:',
                    hintText: 'Enter your address',
                    validator: RequiredValidator(errorText: "* Required"),
                    callback: (value) => this.address1 = value!,
                  ),// Address1
                  OnboardingTextfield(
                    title: 'Address 2:',
                    hintText: 'Enter your address',
                    callback: (value) => this.address2 = value!,
                  ),// Address2
                  OnboardingTextfield(
                    title: 'Address 3:',
                    hintText: 'Enter your address',
                    callback: (value) => this.address3 = value!,
                  ),// Address3
                  OnboardingTextfield(
                    title: 'Postal Code:',
                    hintText: 'Enter your postal code',
                    validator: postalCodeValidator,
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
                    validator: RequiredValidator(errorText: "* Required"),
                    callback: (value) => this.city = value!,
                  ),// City
                  OnboardingTextfield(
                    title: 'School:',
                    hintText: 'Enter your school',
                    validator: RequiredValidator(errorText: "* Required"),
                    callback: (value) => this.school = value!,
                  ),// School
                ],
              ),
            ),
            RoundedButton(
              title: "Register Account",
              func: submit,
              colorBG: kLightBlue,
              colorFont: kWhite,
            ),
          ],
        ),
      ),
    );
  }

  void submit() async {
    final form = _formkey.currentState!;

    if (form.validate()) {
      form.save();

      final body = jsonEncode(<String, String> {
        'email': email,
        'mobile': mobile,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        "gender": gender,
        "age": age,
        "dob": dob.toString(),
        "address1": address1,
        "address2": address2,
        "address3": address3,
        "postalCode": postalCode,
        "countryCode": countryCode,
        "city": city,
        "school": school,
      });

      try {
        User user = await doRegistration(body);
        Navigator.pushNamed(context, '/home', arguments: user);
      }
      on Exception catch (err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: "Error",
                desc: err.toString(),);
            }
        );
      }
    }
  }
  
  Future<User> doRegistration(body) async {
    final response = await http.post(
      Uri.parse('https://eq-lab-dev.me/api/mp/user/register?type=email'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: body,
    );

    if (response.statusCode == 202) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 500) {
      throw Exception('User already exists in our system');
    }
    else {
      throw Exception('Error while creating user!');
    }
  }


}
