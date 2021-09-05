import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:form_field_validator/form_field_validator.dart';

final emailValidator = MultiValidator([
  RequiredValidator(errorText: "* Required"),
  EmailValidator(errorText: "Enter a valid email address"),
]);

// class EmailSignupForm extends StatelessWidget {
//   const EmailSignupForm({ Key? key }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//           child: TextFormField(
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.email),
//               hintText: 'Enter your email address',
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class LoginButton extends StatelessWidget {
//   const LoginButton({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       child: Text('Register',
//           style: TextStyle(fontFamily: 'SF Pro Display'),
//       ),
//       style: TextButton.styleFrom(
//         padding: EdgeInsets.fromLTRB(100.0, 10.0, 100.0, 10.0),
//         primary: kWhite,
//         backgroundColor: kLightBlue,
//         onSurface: Colors.grey,
//       ),
//       onPressed: () { },
//     );
//   }
// }
