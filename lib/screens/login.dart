import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/form-input.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  String email = '';
  String password = '';

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
                  "Log In",
                  style: TextStyle(fontFamily: 'SF Pro Display',
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold),
                ),TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {Navigator.pushNamed(context, '/');},
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
                          FormInput(
                            placeholder: 'Email',
                            validator: emailValidator,
                            func: (value) => email = value!,
                            obscureText: false,
                          ),
                          SizedBox( height: 10.0),
                          FormInput(
                            placeholder: 'Password',
                            validator: passwordValidator,
                            func: (value) => password = value!,
                            obscureText: true
                          ),
                          SizedBox( height: 10.0),
                          RoundedButton(
                              title: "Log In",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Forgot your password?",
                  style: TextStyle(
                    fontFamily: "SF Pro Display",
                    fontSize: 16.0,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {Navigator.pushNamed(context, '/forgotpw');},
                  child: const Text('Reset here',
                    style: TextStyle( fontFamily: "SF Pro Display", fontSize: 16.0),
                  ),
                ),
              ],
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

      final body = jsonEncode(<String, String>{
        'email': email,
        'password': password,
      });
      try {
        User user = await doLogin(body);
        Navigator.pushNamed(context, '/home', arguments: user);
      }
      on Exception catch (err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(title: "Error", desc: err.toString(),);
            });
      }

    }
  }

  Future<User> doLogin(body) async {
    final response = await http.post(
        Uri.parse('https://eq-lab-dev.me/api/mp/auth/login?type=email'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
        body: body,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {

      throw Exception('User not found or password incorrect!');
    }
  }
}
