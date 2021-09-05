import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:form_field_validator/form_field_validator.dart';

final emailValidator = MultiValidator([
  RequiredValidator(errorText: "* Required"),
  EmailValidator(errorText: "Enter a valid email address"),
]);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'password is required'),
  MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'passwords must have at least one special character')
]);

// class EmailLoginForm extends StatefulWidget {
//   const EmailLoginForm({Key? key}) : super(key: key);
//
//   @override
//   _EmailLoginFormState createState() => _EmailLoginFormState();
// }
//
// class _EmailLoginFormState extends State<EmailLoginForm> {
//   final formkey = GlobalKey<FormState>();
//   String email = '';
//   String password = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//         key: formkey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Email',
//                   hintText: 'Enter your email',
//                 ),
//                 validator: emailValidator,
//                 onSaved: (value) => email = value!,
//               ),
//             ),
//           ],
//         ),
//     );
//   }
// }
//
// class PasswordLoginForm extends StatefulWidget {
//   const PasswordLoginForm({Key? key}) : super(key: key);
//
//   @override
//   _PasswordLoginFormState createState() => _PasswordLoginFormState();
// }
//
// class _PasswordLoginFormState extends State<PasswordLoginForm> {
//   final formkey = GlobalKey<FormState>();
//   String email = '';
//   String password = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//           child: TextFormField(
//             obscureText: true,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               labelText: 'Password',
//               hintText: 'Enter your password',
//             ),
//             validator: passwordValidator,
//             onSaved: (value) => password = value!,
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
//       child: Text('Log In',
//         style: TextStyle(fontFamily: 'SF Pro Display'),
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