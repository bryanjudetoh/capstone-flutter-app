import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({required this.title, required this.func, required this.colorBG, required this.colorFont});
  final String title;
  final Function func;
  final Color colorBG;
  final Color colorFont;

  @override
  Widget build(BuildContext context) {
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
