import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';

class WelcomeButton extends StatelessWidget {
  WelcomeButton({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(text,
        style: TextStyle(fontFamily: 'SF Pro Display'),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.fromLTRB(100.0, 10.0, 100.0, 10.0),
        primary: kWhite,
        backgroundColor: kLightBlue,
        onSurface: Colors.grey,
      ),
      onPressed: () { },
    );
  }
}