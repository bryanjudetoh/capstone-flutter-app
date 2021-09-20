import 'package:flutter/material.dart';

class PlainTextButton extends StatelessWidget {
  const PlainTextButton({Key? key, required this.title, required this.func, required this.textStyle, this.textColor}) : super(key: key);

  final String title;
  final VoidCallback func;
  final TextStyle textStyle;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: textStyle,
      ),
      onPressed: () {func();},
      child: Text(
        title,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
