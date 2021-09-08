import 'package:form_field_validator/form_field_validator.dart';

final emailValidator = MultiValidator([
  RequiredValidator(errorText: "* Required"),
  EmailValidator(errorText: "Enter a valid email address"),
]);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'password is required'),
  LengthRangeValidator(errorText: 'password must be between 8 to 30 characters long', max: 30, min: 8),
]);