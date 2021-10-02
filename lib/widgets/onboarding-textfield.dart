import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:form_field_validator/form_field_validator.dart';

class OnboardingTextfield extends StatefulWidget {
  OnboardingTextfield({Key? key, required this.title, required this.hintText, this.initialValue, this.obscureText, this.validator, required this.callback, this.textCon}) : super(key: key);

  final String title;
  final String hintText;
  final String? initialValue;
  final bool? obscureText;
  final FieldValidator? validator;
  final void Function(String?)? callback;
  final TextEditingController? textCon;

  @override
  _OnboardingTextfieldState createState() => _OnboardingTextfieldState();
}

class _OnboardingTextfieldState extends State<OnboardingTextfield> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: bodyTextStyleBold,
            ),
            SizedBox( height: 5.0,),
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(94, 200, 216, 0.1),
                borderRadius: new BorderRadius.circular(16.0),
              ),
              child: TextFormField(
                onChanged: (value) {
                  if (widget.textCon != null) {
                    widget.textCon!.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: value.length),
                      ),
                    );
                  }
                },
                controller: widget.textCon,
                initialValue: widget.initialValue,
                obscureText: widget.obscureText ?? false,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: validatorCheck(widget.validator),
                onSaved: widget.callback,
              ),
            )
          ],
        )
    );
  }
  String? Function(String?)? validatorCheck(validator) {
    if (validator == null) {
      return null;
    }
    else {
      return validator as FieldValidator;
    }
  }
}

