import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';


class OnboardingDropdown extends StatefulWidget {
  OnboardingDropdown({Key? key, required this.title, required this.input, required this.list, required this.callback}) : super(key: key);

  final String title;
  final String input;
  final List<String> list;
  final void Function(String?)? callback;

  @override
  _OnboardingDropdownState createState() => _OnboardingDropdownState();
}

class _OnboardingDropdownState extends State<OnboardingDropdown> {

  String? _currentSelectedValue;

  String? updateCurrentSelectedValue(String value) {
    setState(() {
      _currentSelectedValue = value;
    });
    return _currentSelectedValue;
  }

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
              child: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromRGBO(94, 200, 216, 0.1),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    isEmpty: widget.input == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currentSelectedValue ?? widget.list[0],
                        isDense: true,
                        onChanged: (String? value) {
                          widget.callback!(value); //updates the value in the previous screen
                          updateCurrentSelectedValue(value!); //updates the current selected value
                        },
                        items: widget.list.map((String value) {
                          return DropdownMenuItem<String> (
                            value: value,
                            child: Text(value, style: bodyTextStyle,),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        )
    );
  }
}

