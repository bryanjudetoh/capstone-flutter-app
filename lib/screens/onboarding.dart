import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/utilities/validators.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;

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
  String mobile = '';
  String gender = genderList[0];
  String age = '';
  DateTime dob = DateTime.now();
  String address1 = '';
  String address2 = '';
  String address3 = '';
  String postalCode = '';
  String countryCode = countryCodesList[0];
  String city = '';
  String school = '';

  String _genderSelectedValue = genderList[0];
  String _countryCodeSelectedValue = countryCodesList[0];

  @override
  Widget build(BuildContext context) {
    String inputEmail = ModalRoute.of(context)!.settings.arguments as String;

    if ( inputEmail.length > 0) {
      this.email = inputEmail; //remove quotation marks
    }


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
                            'Mobile Number:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your mobile number',
                            ),
                            validator: mobileNumValidator,
                            onSaved: (value) => mobile = value!,
                          ),
                        ],
                      )
                  ),// Mobile Number
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
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Gender:',
                            style: defaultTextStyle,
                          ),
                          SizedBox( width: 15.0,),
                          Flexible(
                            fit: FlexFit.tight,
                            child: FormField<String>(
                              builder: (FormFieldState<String> state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  isEmpty: this.gender == '',
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _genderSelectedValue,
                                      isDense: true,
                                      onChanged: (String? value) {
                                        setState(() {
                                          this.gender = value!;
                                          _genderSelectedValue = value;
                                        });
                                      },
                                      items: genderList.map((String value) {
                                        return DropdownMenuItem<String> (
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                  ),// Gender
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Age:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your age',
                            ),
                            validator: ageValidator,
                            onSaved: (value) => age = value!,
                          ),
                        ],
                      )
                  ),// Age
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Date of Birth:',
                          style: TextStyle(fontFamily: 'SF Pro Display',
                              fontSize: 16.0),
                        ),
                        SizedBox( width: 15.0,),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                              "${dob.toLocal()}".split(' ')[0],
                            style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16.0, fontWeight: FontWeight.bold),
                          )
                        ),
                        SizedBox( width: 15.0,),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: Text(
                            'Select date',
                            style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: kLightBlue,
                          ),
                        ),
                      ],
                    )
                  ),// DOB
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Address 1:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your address',
                            ),
                            validator: RequiredValidator(errorText: "* Required"),
                            onSaved: (value) => address1 = value!,
                          ),
                        ],
                      )
                  ),// Address1
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Address 2:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your address',
                            ),
                            validator: RequiredValidator(errorText: "* Required"),
                            onSaved: (value) => address2 = value!,
                          ),
                        ],
                      )
                  ),// Address2
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Address 3:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your address',
                            ),
                            validator: RequiredValidator(errorText: "* Required"),
                            onSaved: (value) => address3 = value!,
                          ),
                        ],
                      )
                  ),// Address3
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Postal Code:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your postal code',
                            ),
                            validator: postalCodeValidator,
                            onSaved: (value) => postalCode = value!,
                          ),
                        ],
                      )
                  ),// Postal Code
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Country Code:',
                            style: defaultTextStyle,
                          ),
                          SizedBox( width: 15.0,),
                          Flexible(
                            fit: FlexFit.tight,
                            child: FormField<String>(
                              builder: (FormFieldState<String> state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  isEmpty: this.countryCode == '',
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _countryCodeSelectedValue,
                                      isDense: true,
                                      onChanged: (String? value) {
                                        setState(() {
                                          this.countryCode = value!;
                                          _countryCodeSelectedValue = value;
                                        });
                                      },
                                      items: countryCodesList.map((String value) {
                                        return DropdownMenuItem<String> (
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                  ),// Country Code
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'City:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your city',
                            ),
                            validator: RequiredValidator(errorText: "* Required"),
                            onSaved: (value) => city = value!,
                          ),
                        ],
                      )
                  ),// City
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'School:',
                            style: TextStyle(fontFamily: 'SF Pro Display',
                                fontSize: 16.0),
                          ),
                          SizedBox( height: 5.0,),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your school',
                            ),
                            validator: RequiredValidator(errorText: "* Required"),
                            onSaved: (value) => school = value!,
                          ),
                        ],
                      )
                  ),// School
                ],
              ),
            ),
            RoundedButton("Register Account", submit, kLightBlue)
          ],
        ),
      ),
    );
  }

  void submit() async {
    final form = _formkey.currentState!;

    if (form.validate()) {
      form.save();

      final body = jsonEncode(<String, String> {
        'email': email,
        'mobile': mobile,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        "gender": gender,
        "age": age,
        "dob": dob.toString(),
        "address1": address1,
        "address2": address2,
        "address3": address3,
        "postalCode": postalCode,
        "countryCode": countryCode,
        "city": city,
        "school": school,
      });

      try {
        User user = await doRegistration(body);
        Navigator.pushNamed(context, '/home', arguments: user);
      }
      on Exception catch (err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(err.toString()),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }
    }
  }
  
  Future<User> doRegistration(body) async {
    final response = await http.post(
      Uri.parse('https://eq-lab-dev.me/api/mp/user/register?type=email'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: body,
    );

    print(body);

    if (response.statusCode == 202) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 500) {
      print(response.body);
      throw Exception('User already exists in our system');
    }
    else {
      print(response.body);
      throw Exception('Error while creating user!');
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null)
      setState(() {
        this.dob = picked;
      });
  }
}
