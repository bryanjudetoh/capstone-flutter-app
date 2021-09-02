import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';

class PhoneNumberForm extends StatelessWidget {
  const PhoneNumberForm({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
              hintText: 'Enter your phone number',
            ),
          ),
        ),
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text('Login',
          style: TextStyle(fontFamily: 'SF Pro Display'),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.fromLTRB(100.0, 10.0, 100.0, 10.0),
        primary: kWhite,
        backgroundColor: kLightBlue,
        onSurface: Colors.grey,
      ),
      onPressed: () { },
    );
  }
}
