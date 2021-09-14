import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';

class AlertPopup extends StatelessWidget {
  const AlertPopup({Key? key,required this.title, required this.desc}) : super(key: key);

  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16.0, fontWeight: FontWeight.bold),),
      content: Text(desc, style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16.0),),
      actions: [
        TextButton(
          child: Text("Ok", style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16.0),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
