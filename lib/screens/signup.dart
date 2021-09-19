import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/widgets/form-input.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/utilities/validators.dart';

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
                      style: xLargeTitleTextStyle,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: mediumTitleTextStyle,
                      ),
                      onPressed: () {Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);},
                      child: const Text('Back',
                        style: TextStyle( fontFamily: "SF Pro Display", fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.black),
                      ),
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
                    "Or social media access",
                    style: bodyTextStyle,
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          iconSize: 60.0,
                          icon: new Image.asset("assets/icons/apple.png"),
                          onPressed: () { },
                        ),
                        IconButton(
                          iconSize: 60.0,
                          icon: new Image.asset("assets/icons/facebook.png"),
                          onPressed: () { },
                        ),
                        IconButton(
                          iconSize: 60.0,
                          icon: new Image.asset("assets/icons/google.png"),
                          onPressed: () { },
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
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {Navigator.pushNamed(context, '/login');},
                    child: const Text('Log In here',
                      style: bodyTextStyle,
                    ),
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
      Navigator.pushNamed(context, '/onboarding', arguments: email);
    }
  }
}

