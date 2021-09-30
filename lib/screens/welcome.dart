import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/widgets/rounded-button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/images/equity-lab-potion-logo.png"),
                ),
                RoundedButton(
                  title: "Sign Up",
                  func: () => Navigator.pushNamed(context, '/signup'),
                  colorBG: kLightBlue,
                  colorFont: kWhite,
                ),
                SizedBox(
                  height: 10.0,
                ),
                RoundedButton(
                  title: "  Log In  ",
                  func: () => Navigator.pushNamed(context, '/login'),
                  colorBG: kGrey,
                  colorFont: kLightBlue,
                ),
                SizedBox(height: 100,),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
