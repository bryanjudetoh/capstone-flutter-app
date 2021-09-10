import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:form_field_validator/form_field_validator.dart';

class OnboardingScreen extends StatefulWidget {
  final String? email;
  const OnboardingScreen({Key? key, this.email }) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formkey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    print(widget.email);
    var len = widget.email?.length ?? 0;
    if ( len > 0) {
      email = widget.email ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
        child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Onboarding",
                    style: TextStyle(fontFamily: 'SF Pro Display',
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {Navigator.pop(context);},
                    child: const Text('Back',
                      style: TextStyle( fontFamily: "SF Pro Display", fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.black),
                    ),
                  ),
                ]
            ),
            SizedBox( height: 10.0,),
            Form(
              key: _formkey,
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'First Name:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'John',
                            ),
                            validator: RequiredValidator(errorText: "* Required"),
                            onSaved: (value) => firstName = value!,
                          ),
                        ],
                      )
                  ),// First Name
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Last Name:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Wong',
                            ),
                            validator: RequiredValidator(errorText: "* Required"),
                            onSaved: (value) => lastName = value!,
                          ),
                        ],
                      )
                  ),// Last Name
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Email:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            initialValue: this.email,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your email',
                            ),
                            validator: emailValidator,
                            onSaved: (value) => email = value!,
                          ),
                        ],
                      )
                  ),// Email
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Password:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your password',
                            ),
                            validator: passwordValidator,
                            onSaved: (value) => password = value!,
                          ),
                        ],
                      )
                  ),// Password
                ],
              ),
            ),
            RoundedButton("Register Account", submit, kLightBlue)
          ],
        ),
      ),
    );
  }

  void submit() {
    final form = _formkey.currentState!;

    if (form.validate()) {
      form.save();

      print('Form valid: $firstName, $lastName, $email, $password');
      //setState(() => isSignedIn = true);
    }
  }
}
