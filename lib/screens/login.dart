import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/utilities/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Log In",
                  style: TextStyle(fontFamily: 'SF Pro Display',
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold),
                ),TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {Navigator.pushNamed(context, '/');},
                  child: const Text('Back',
                    style: TextStyle( fontFamily: "SF Pro Display", fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Form(
                  key: _formkey,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                              hintText: 'Enter your email',
                            ),
                            validator: emailValidator,
                            onSaved: (value) => email = value!,
                          ),
                          SizedBox( height: 10.0,),
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                              hintText: 'Enter your password',
                            ),
                            validator: passwordValidator,
                            onSaved: (value) => password = value!,
                          ),
                          SizedBox( height: 10.0,),
                          RoundedButton("Log In", submit, kLightBlue),
                        ],
                      ),
                  ),
                ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Forgot your password?",
                  style: TextStyle(
                    fontFamily: "SF Pro Display",
                    fontSize: 16.0,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {Navigator.pushNamed(context, '/forgotpw');},
                  child: const Text('Reset here',
                    style: TextStyle( fontFamily: "SF Pro Display", fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void submit() {
    final form = _formkey.currentState!;

    if (form.validate()) {
      form.save();

      print('Form valid: $email, $password');
      //setState(() => isSignedIn = true);
    }
  }
}
