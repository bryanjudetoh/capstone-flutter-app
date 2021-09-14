import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:form_field_validator/form_field_validator.dart';

class OnboardingTextfield extends StatelessWidget {
  const OnboardingTextfield({Key? key, required this.title, required this.hintText, this.initialValue, this.obscureText, this.validator, required this.callback}) : super(key: key);

  final String title;
  final String hintText;
  final String? initialValue;
  final bool? obscureText;
  final FieldValidator? validator;
  final void Function(String?)? callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              this.title,
              style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16.0),
            ),
            SizedBox( height: 5.0,),
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(94, 200, 216, 0.1),
                borderRadius: new BorderRadius.circular(16.0),
              ),
              child: TextFormField(
                initialValue: this.initialValue,
                obscureText: this.obscureText ?? false,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: this.hintText,
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: validatorCheck(this.validator),
                onSaved: this.callback,
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

