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
                ElevatedButton(
                  child: Text('Log In',
                    style: TextStyle(fontFamily: 'SF Pro Display', color: kLightBlue, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.fromLTRB(105.0, 10.0, 105.0, 10.0),
                    primary: kWhite,
                  ),
                  onPressed: () {Navigator.pushNamed(context, '/login');},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
