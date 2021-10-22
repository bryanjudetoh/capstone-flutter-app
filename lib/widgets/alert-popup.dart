import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';

class AlertPopup extends StatelessWidget {
  AlertPopup({Key? key,required this.title, required this.desc, this.func, this.buttonName}) : super(key: key);

  final String title;
  final String desc;
  final VoidCallback? func;
  final String? buttonName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: titleTwoTextStyleBold,),
      content: Text(desc, style: bodyTextStyle,),
      actions: [
        TextButton(
          child: Text(this.buttonName == null ? "Ok" : this.buttonName!, style: bodyTextStyle,),
          onPressed: () {
            if (this.func == null) {
              Navigator.of(context).pop();
            }
            else {
              this.func!();
            }
          },
        )
      ],
    );
  }
}
