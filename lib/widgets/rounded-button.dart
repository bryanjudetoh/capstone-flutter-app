import 'package:flutter/material.dart';

import '../constants.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({required this.title, required this.func, required this.colorBG, required this.colorFont, this.disableText});
  final String title;
  final VoidCallback func;
  final Color colorBG;
  final Color colorFont;
  final String? disableText;

  @override
  Widget build(BuildContext context) {
    if (disableText != null) {
      return ElevatedButton(
        child: Text(
          this.disableText!,
          style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.bold, fontSize: 16.0, color: kDarkGrey),
        ),
        style: ElevatedButton.styleFrom(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.fromLTRB(120.0, 15.0, 120.0, 15.0),
          primary: kBluishWhite,
        ),
        onPressed: () {},
      );
    }
    else {
      return ElevatedButton(
        child: Text(
          this.title,
          style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.bold, fontSize: 16.0, color: this.colorFont),
        ),
        style: ElevatedButton.styleFrom(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.fromLTRB(120.0, 15.0, 120.0, 15.0),
          primary: this.colorBG,
        ),
        onPressed: () {func();},
      );
    }
  }
}
