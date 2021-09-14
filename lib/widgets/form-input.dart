import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class FormInput extends StatelessWidget {
  FormInput(this.placeholder, this.validator, this.func, this.obscureText);
  final String placeholder;
  final MultiValidator validator;
  final Function(String?) func;
  final bool obscureText;


  @override
  Widget build(BuildContext context) {
    return Padding (
      padding: EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(94, 200, 216, 0.1),
          borderRadius: new BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding:
            EdgeInsets.only(left: 15, right: 15, top: 5),
          child: TextFormField (
            decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
            ),
            validator: validator,
            onSaved: func,
            obscureText: obscureText,
          ),
        ),
      ),
    );
  }

}