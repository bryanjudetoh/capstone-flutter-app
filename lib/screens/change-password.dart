import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/widgets/onboarding-textfield.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:youthapp/widgets/text-button.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  String oldPassword = '';
  String newPassword = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.changePassword,
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
                    SizedBox(height: MediaQuery.of(context).size.height*0.15,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Form(
                            key: _formkey,
                            child: Column(
                                children: <Widget>[
                                  OnboardingTextfield(
                                    title: 'Current Password:',
                                    hintText: 'Enter your current password',
                                    obscureText: true,
                                    validator: passwordValidator,
                                    callback: (value) => this.oldPassword = value!,
                                  ),
                                  OnboardingTextfield(
                                    title: 'New Password:',
                                    hintText: 'Enter your new password',
                                    obscureText: true,
                                    validator: passwordValidator,
                                    callback: (value) => this.newPassword = value!,
                                    textCon: _pass,
                                  ),
                                  OnboardingTextfield(
                                    title: 'Confirm Password:',
                                    hintText: 'Re-enter your new password',
                                    obscureText: true,
                                    validator: MultiValidator([
                                      passwordValidator,
                                      MatchingValidator(matchText: _pass, errorText: 'Does not match the above password'),
                                    ]),
                                    callback: (value) {},
                                    textCon: _confirmPass,
                                  ),
                                ]
                            )
                        ),
                        SizedBox(height: 10,),
                        RoundedButton(
                          title: "Update Details",
                          func: submit,
                          colorBG: kLightBlue,
                          colorFont: kWhite,
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.15,)
                  ]
              )
          ),
        )
    );
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Successfully changed password",
                style: bodyTextStyle,
              ),
              duration: const Duration(seconds: 1),
            )
        );
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

    final response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/mp/user/password'),
      body: body,
    );

    if (response.statusCode == 200) {
      print('successfully changed password');
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }

  String formatExceptionMessage(String str) {
    int idx = str.indexOf(":");
    return str.substring(idx+1).trim();
  }
}