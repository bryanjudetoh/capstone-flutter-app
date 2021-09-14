import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';

class AlertPopup extends StatelessWidget {
  const AlertPopup({Key? key,required this.title, required this.desc}) : super(key: key);

  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: defaultTextStyleBold,),
      content: Text(desc, style: defaultTextStyle,),
      actions: [
        TextButton(
          child: Text("Ok", style: defaultTextStyle,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );;
  }
}
