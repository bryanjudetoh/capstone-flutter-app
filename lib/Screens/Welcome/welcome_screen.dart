import 'package:flutter/material.dart';
import 'package:youthapp/Screens/Welcome/components/components.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Register",
                    style: TextStyle(fontFamily: 'SF Pro Display',
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {},
                    child: const Text('Skip',
                      style: TextStyle( fontFamily: "SF Pro Display", fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.black),
                    ),
                  ),
                ]
              ),
              SizedBox(
                height: 100.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Phone Number:",
                    style: TextStyle( fontFamily: 'SF Pro Display',
                      fontSize: 16.0
                    )
                  ),
                  const PhoneNumberForm(),
                  Align(
                    alignment: Alignment.center,
                    child: const LoginButton()
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Or social media access",
                    style: TextStyle(
                      fontFamily: "SF Pro Display",
                      fontSize: 16.0
                    ),
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
                    style: TextStyle(
                      fontFamily: "SF Pro Display",
                      fontSize: 16.0,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {},
                    child: const Text('Log In here',
                      style: TextStyle( fontFamily: "SF Pro Display", fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ]
        ),
      ),
    );
  }
}


