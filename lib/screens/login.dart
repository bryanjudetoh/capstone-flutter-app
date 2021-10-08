import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/form-input.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:http/http.dart' as http;
import 'package:youthapp/widgets/text-button.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final fb = FacebookLogin();
  String email = '';
  String password = '';
  String fbUserId = '';
  String fbAccessToken = '';
  final SecureStorage secureStorage = SecureStorage();

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
                    AppLocalizations.of(context)!.login,
                    style: largeTitleTextStyleBold,
                  ),
                  PlainTextButton(
                    title: 'Back',
                    func: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/welcome', (r) => false);
                    },
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
                      FormInput(
                        placeholder: 'Email',
                        validator: emailValidator,
                        func: (value) => this.email = value!,
                      ),
                      SizedBox(height: 10.0),
                      FormInput(
                        placeholder: 'Password',
                        validator: passwordValidator,
                        func: (value) => this.password = value!,
                        obscureText: true,
                      ),
                      SizedBox(height: 10.0),
                      RoundedButton(
                        title: "Log In",
                        func: submit,
                        colorBG: kLightBlue,
                        colorFont: kWhite,
                      ),
                    ],
                  ),
                ),
              ),
              SignInButton(
                Buttons.FacebookNew,
                onPressed: doLoginFb,
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Forgot your password?",
                    style: bodyTextStyle,
                  ),
                  PlainTextButton(
                      title: 'Reset here',
                      func: () {
                        Navigator.pushNamed(context, '/forgotpw');
                      },
                      textStyle: bodyTextStyle),
                ],
              ),
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
        'password': password,
      });
      try {
        User user = await doLogin(body);
        secureStorage.writeSecureData('user', jsonEncode(user.toJson()));
        Navigator.pushNamedAndRemoveUntil(context, '/init-home', (r) => false);
      } on Exception catch (err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                  title: "Login Failed!", desc: formatExceptionMessage(err.toString()));
            });
      }
    }
  }

  Future<User> doLogin(body) async {
    final response = await http.post(
      Uri.parse('https://eq-lab-dev.me/api/mp/auth/login?type=email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      var token = responseBody['token'];

      secureStorage.writeSecureData('accessToken', token['accessToken']);
      secureStorage.writeSecureData('refreshToken', token['refreshToken']);

      return User.fromJson(responseBody);
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }

  void doLoginFb() async {
    var res;
    try {
      // Fb Log in
      res = await fb.logIn(permissions: [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ]);
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

    // Check Fb Login status
    switch (res.status) {
      case FacebookLoginStatus.success:
        // Logged in
        final fbUserId = res.accessToken!.userId;
        final accessToken = res.accessToken!.token;

        setState(() {
          this.fbUserId = fbUserId;
          this.fbAccessToken = accessToken;
        });

        break;
      case FacebookLoginStatus.cancel:
        // User cancel log in
        break;
      case FacebookLoginStatus.error:
        // Log in failed
        print('Error while log in: ${res.error}');
        break;
    }

    final body = jsonEncode(<String, String>{
      'fbUserId': this.fbUserId,
      'fbAccessToken': this.fbAccessToken,
    });

    final response = await http.post(
      Uri.parse('https://eq-lab-dev.me/api/mp/auth/login?type=fb'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      var token = responseBody['token'];

      secureStorage.writeSecureData('accessToken', token['accessToken']);
      secureStorage.writeSecureData('refreshToken', token['refreshToken']);

      try {
        User user = User.fromJson(responseBody);
        secureStorage.writeSecureData('user', jsonEncode(user.toJson()));
        Navigator.pushNamedAndRemoveUntil(context, '/init-home', (r) => false);
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
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertPopup(
              title: "Error",
              desc: jsonDecode(response.body)['error']['message'],
            );
          });
    }
  }
}
