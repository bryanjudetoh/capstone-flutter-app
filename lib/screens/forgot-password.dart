import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/form-input.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:http/http.dart' as http;
import 'package:youthapp/widgets/text-button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formkey = GlobalKey<FormState>();
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.forgotPassword,
                    style: titleOneTextStyleBold,
                  ),
                  PlainTextButton(
                    title: 'Back',
                    func: () {Navigator.pop(context);},
                    textStyle: backButtonBoldItalics,
                    textColor: kBlack,
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Form(
                key: _formkey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Recovery password will be sent to your email address:',
                          style: smallBodyTextStyle,
                        ),
                      ),
                      SizedBox( height: 5.0,),
                      FormInput(
                          placeholder: 'Enter your email',
                          validator: emailValidator,
                          func: (value) => email = value!,
                      ),
                      SizedBox( height: 10.0,),
                      RoundedButton(
                          title: "Reset Password",
                          func: submit,
                          colorBG: kLightBlue,
                          colorFont: kWhite,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              SizedBox( height: 10.0,),
            ],
          ),
        ),
      ),
    );
  }

  void submit() async {
    final form = _formkey.currentState!;

    if (form.validate()) {
      form.save();

      final body = jsonEncode(<String, String>{
        'email': email,
      });
      try {
        if (await doResetPassword(body)) {
          showDialog(context: context, builder: (BuildContext context) {
            return AlertPopup(
              title: "Success",
              desc: "A link to recover your password has been sent to your email",);
          });
        }
        }

      on Exception catch (err) {
        showDialog(context: context, builder: (BuildContext context) {
          return AlertPopup(
            title: "Error",
            desc: formatExceptionMessage(err.toString()),);
        });
      }
    }
  }

  Future<bool> doResetPassword(body) async {
    final response = await http.post(
      Uri.parse('https://eq-lab-dev.me/api/mp/auth/forget-password'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }

  String formatExceptionMessage(String str) {
    int idx = str.indexOf(":");
    return str.substring(idx+1).trim();
  }
}
