import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/onboardingParams.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/onboarding-datepicker.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/widgets/onboarding-textfield.dart';
import 'package:youthapp/widgets/onboarding-dropdown.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:youthapp/widgets/text-button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

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
  String fbUserId = '';
  String fbAccessToken = '';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OnboardingParams;

    if (args.email.length > 0) {
      this.email = args.email;
    }

    if (args.fbUserId != null) {
      this.fbUserId = args.fbUserId!;
      this.fbAccessToken = args.fbAccessToken!;
      this.firstName = args.firstName!;
      this.lastName = args.lastName!;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.register,
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
                  ]),
              SizedBox(
                height: 10.0,
              ),
              Form(
                key: _formkey,
                child: Column(
                  children: <Widget>[
                    OnboardingTextfield(
                      title: 'First Name:',
                      hintText: 'John',
                      initialValue: this.firstName,
                      validator: RequiredValidator(errorText: "* Required"),
                      callback: (value) => this.firstName = value!,
                    ), // FirstName
                    OnboardingTextfield(
                        title: 'Last Name:',
                        hintText: 'Wong',
                        initialValue: this.lastName,
                        validator: RequiredValidator(errorText: "* Required"),
                        callback: (value) => this.lastName = value!), // LastName
                    OnboardingTextfield(
                        title: 'Mobile Number:',
                        hintText: 'Enter your mobile number',
                        validator: mobileNumValidator,
                        callback: (value) => this.mobile = value!), // Mobile
                    OnboardingTextfield(
                      title: 'Email:',
                      hintText: 'Enter your email',
                      initialValue: this.email,
                      validator: emailValidator,
                      callback: (value) => this.email = value!,
                    ), // Email
                    if (!args.isFbLogin)
                      Column(
                        children: [
                          OnboardingTextfield(
                            title: 'Password:',
                            hintText: 'Enter your password',
                            obscureText: true,
                            validator: passwordValidator,
                            callback: (value) => this.password = value!,
                            textCon: _pass,
                          ),// Password
                          OnboardingTextfield(
                            title: 'Confirm Password:',
                            hintText: 'Re-enter your password',
                            obscureText: true,
                            validator: MultiValidator([
                              passwordValidator,
                              MatchingValidator(matchText: _pass, errorText: 'Does not match the above password'),
                            ]),
                            callback: (value) {},
                            textCon: _confirmPass,
                          ), // Confirm Password
                        ],
                      ),// Passwords
                    OnboardingDropdown(
                      title: 'Gender',
                      input: this.gender,
                      list: genderList,
                      callback: (value) => this.gender = value!,
                    ), // Gender
                    OnboardingTextfield(
                      title: 'Age:',
                      hintText: 'Enter your age',
                      validator: ageValidator,
                      callback: (value) => this.age = value!,
                    ), // Age
                    OnboardingDatepicker(
                      title: 'Date of Birth:',
                      callback: (value) => this.dob = value!,
                    ), // DOB
                    OnboardingTextfield(
                      title: 'Address Line 1:',
                      hintText: 'Enter your address',
                      validator: RequiredValidator(errorText: "* Required"),
                      callback: (value) => this.address1 = value!,
                    ), // Address1
                    OnboardingTextfield(
                      title: 'Address Line 2:',
                      hintText: 'Enter your address',
                      callback: (value) => this.address2 = value!,
                    ), // Address2
                    OnboardingTextfield(
                      title: 'Address Line 3:',
                      hintText: 'Enter your address',
                      callback: (value) => this.address3 = value!,
                    ), // Address3
                    OnboardingTextfield(
                      title: 'Postal Code:',
                      hintText: 'Enter your postal code',
                      validator: postalCodeValidator,
                      callback: (value) => this.postalCode = value!,
                    ), // Postal Code
                    OnboardingDropdown(
                      title: 'Country Code:',
                      input: this.countryCode,
                      list: countryCodesList,
                      callback: (value) => this.countryCode = value!,
                    ), // Country Code
                    OnboardingTextfield(
                      title: 'City:',
                      hintText: 'Enter your city',
                      validator: RequiredValidator(errorText: "* Required"),
                      callback: (value) => this.city = value!,
                    ), // City
                    OnboardingTextfield(
                      title: 'School:',
                      hintText: 'Enter your school',
                      validator: RequiredValidator(errorText: "* Required"),
                      callback: (value) => this.school = value!,
                    ), // School
                  ],
                ),
              ),
              SizedBox(height: 15,),
              RoundedButton(
                title: "Register",
                func: args.isFbLogin ? submitFb : submit,
                colorBG: kLightBlue,
                colorFont: kWhite,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit() async {
    var form = _formkey.currentState!;
    if (form.validate()) {
      form.save();

      final body = jsonEncode(<String, String>{
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
        User user = await doRegistration(body, false);
        Navigator.pushNamedAndRemoveUntil(
            context, '/verification', ModalRoute.withName('/welcome'),
            arguments: user);
      } on Exception catch (err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: "Error",
                desc: formatExceptionMessage(err.toString()),
              );
            });
      }
    }
  }

  Future<User> doRegistration(body, isFb) async {
    var response = http.Response(body, 400);

    if (!isFb) {
      response = await http.post(
        Uri.parse('https://eq-lab-dev.me/api/mp/user/register?type=email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );
    } else {
      response = await http.post(
        Uri.parse('https://eq-lab-dev.me/api/mp/user/register?type=fb'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );
    }

    if (response.statusCode == 202) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 500) {
      throw Exception('User already exists in our system');
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }

  String formatExceptionMessage(String str) {
    int idx = str.indexOf(":");
    return str.substring(idx + 1).trim();
  }

  void submitFb() async {
    final form = _formkey.currentState!;

    if (form.validate()) {
      form.save();

      final body = jsonEncode(<String, String>{
        'email': email,
        'mobile': mobile,
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
        "fbUserId": this.fbUserId,
        "fbAccessToken": this.fbAccessToken
      });

      try {
        await doRegistration(body, true);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign Up Success!'),
              content: SingleChildScrollView(
                child: Text('You have signed up with your Facebook account.'),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Proceed to Log in'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            );
          },
        );
      } on Exception catch (err) {
        print("$err");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: "Unable to Sign Up!",
                desc: formatExceptionMessage(err.toString()),
              );
            });
      }
    }
  }
}
