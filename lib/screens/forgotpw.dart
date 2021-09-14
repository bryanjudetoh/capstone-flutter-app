import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:http/http.dart' as http;

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
      body: Container(
        padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Forgot Password",
                  style: TextStyle(fontFamily: 'SF Pro Display',
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold),
                ),TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {Navigator.pop(context);},
                  child: const Text('Back',
                    style: TextStyle( fontFamily: "SF Pro Display", fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.black),
                  ),
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
                        style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 14.0, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox( height: 5.0,),
                    TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter your email',
                      ),
                      validator: emailValidator,
                      onSaved: (value) => email = value!,
                    ),
                    SizedBox( height: 10.0,),
                    RoundedButton(
                        title: "Reset Password",
                        func: submit,
                        color: kLightBlue
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
          print('still carried on');
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
            desc: err.toString(),);
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
      print('----Entered exception-----');
      throw Exception('Email does not exist in our database.');
    }
  }
}
