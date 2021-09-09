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