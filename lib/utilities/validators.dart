import 'package:flutter/cupertino.dart';
import 'package:form_field_validator/form_field_validator.dart';

final emailValidator = MultiValidator([
  RequiredValidator(errorText: "* Required"),
  EmailValidator(errorText: "Enter a valid email address"),
]);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  LengthRangeValidator(errorText: 'Password must be between 8 to 30 characters long', max: 30, min: 8),
  PatternValidator(r'(^[^ \n]*$)', errorText: 'Password cannot have any spaces or newline characters')
]);

final ageValidator = MultiValidator([
  RequiredValidator(errorText: 'Age is required'),
  PatternValidator(r'(^[0-9]*$)', errorText: 'Please enter only numerical values')
]);

final postalCodeValidator = MultiValidator([
  RequiredValidator(errorText: 'Postal Code is required'),
  //PatternValidator(r'(^[0-9]*$)', errorText: 'Please enter only numerical values') postal codes may include alphabet in some countries
]);

final mobileNumValidator = MultiValidator([
  RequiredValidator(errorText: 'Mobile Number is required'),
  //PatternValidator(r'(^[0-9]*$)', errorText: 'Please enter only numerical values') mobile number may include '-'
]);

class MatchingValidator extends FieldValidator<String?> {
  final TextEditingController matchText;
  final String errorText;

  MatchingValidator({required this.matchText, required this.errorText}) : super(errorText);

  @override
  bool isValid(String? value) {
    return value == matchText.text ? true : false;
  }
}