import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton(this.title, this.func, this.color);
  final String title;
  final Function func;
  final Color color;


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(title,
        style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.bold, fontSize: 16.0),
      ),
      style: ElevatedButton.styleFrom(
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.fromLTRB(100.0, 10.0, 100.0, 10.0),
        primary: color,
      ),
      onPressed: () {func();},
    );
  }
}
