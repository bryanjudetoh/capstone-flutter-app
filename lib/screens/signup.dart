import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/utilities/onboardingParams.dart';
import 'package:youthapp/widgets/form-input.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:youthapp/widgets/text-button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
                      "Sign Up",
                      style: titleOneTextStyleBold,
                    ),
                    PlainTextButton(
                      title: 'Back',
                      func: () {Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);},
                      textStyle: backButtonBoldItalics,
                      textColor: kBlack,
                    ),
                  ]
              ),
              SizedBox(
                height: 100.0,
              ),
              Column(
                children: <Widget>[
                  Form(
                    key: _formkey,
                    child: FormInput(
                        placeholder: "Email",
                        validator: emailValidator,
                        func: (value) => email = value!,
                    )
                  ),
                  SizedBox( height: 10.0,),
                  RoundedButton(
                    title: 'Register',
                    func: register,
                    colorBG: kLightBlue,
                    colorFont: kWhite,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Or sign up with social media",
                    style: bodyTextStyle,
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          iconSize: 60.0,
                          icon: new Image.asset("assets/icons/facebook.png"),
                          onPressed: facebookRegister,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Already have an account?",
                    style: bodyTextStyle,
                  ),
                  PlainTextButton(
                      title: 'Log In here',
                      func: () {Navigator.pushNamed(context, '/login');},
                      textStyle: bodyTextStyle
                  ),
                ],
              ),
            ]
        ),
      ),
    );
  }

  void register() {
    final form = _formkey.currentState!;

    if (form.validate()) {
      form.save();
      Navigator.pushNamed(context, '/onboarding', arguments: OnboardingParams(
        email: this.email,
        isFbLogin: false
      ));
    }
  }

  void facebookRegister() {
    Navigator.pushNamed(context, '/fb-signup');
  }
}

