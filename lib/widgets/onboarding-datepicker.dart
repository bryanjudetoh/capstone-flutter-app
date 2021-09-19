import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';

class OnboardingDatepicker extends StatefulWidget {
  const OnboardingDatepicker({Key? key, required this.title, required this.callback}) : super(key: key);

  final String title;
  final void Function(DateTime?)? callback;

  @override
  _OnboardingDatepickerState createState() => _OnboardingDatepickerState();
}

class _OnboardingDatepickerState extends State<OnboardingDatepicker> {

  DateTime currentSelectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.title,
              style: bodyTextStyleBold,
            ),
            SizedBox( width: 15.0,),
            Flexible(
                fit: FlexFit.tight,
                child: Text(
                  currentSelectedDate.toString().split(' ')[0],
                  style: bodyTextStyle,
                )
            ),
            SizedBox( width: 15.0,),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                'Select date',
                style: bodyTextStyleBold,
              ),
              style: ElevatedButton.styleFrom(
                primary: kLightBlue,
              ),
            ),
          ],
        )
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      widget.callback!(picked);
      setState(() {
        this.currentSelectedDate = picked;
      });
    }
  }
}
