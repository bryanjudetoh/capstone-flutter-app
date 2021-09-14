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
                    image: AssetImage(
                        "assets/images/equity-lab-potion-logo.png")
                ),
                RoundedButton("Sign Up", () => Navigator.pushNamed(context, '/signup'), kLightBlue),
                SizedBox(
                  height: 10.0,
                ),
                RoundedButton("Log In", () => Navigator.pushNamed(context, '/login'), kGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
