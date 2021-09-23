import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/onboarding-datepicker.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:youthapp/widgets/onboarding-textfield.dart';
import 'package:youthapp/widgets/onboarding-dropdown.dart';
import 'package:youthapp/widgets/text-button.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditAccountDetailsScreen extends StatefulWidget {
  const EditAccountDetailsScreen({Key? key}) : super(key: key);

  @override
  _EditAccountDetailsScreenState createState() => _EditAccountDetailsScreenState();
}

class _EditAccountDetailsScreenState extends State<EditAccountDetailsScreen> {

  final _formkey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
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

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;


  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context)!.settings.arguments as User;
    if (user.gender != null) {
      setState(() {
        this.gender = user.gender!;
      });
    }

    if (user.dob != null) {
      setState(() {
        this.dob = user.dob!;
      });
    }

    if (user.countryCode != null) {
      setState(() {
        this.countryCode = user.countryCode!;
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.only(left: 35.0, right: 35.0, top: 50.0),
            child: Column(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Edit Profile",
                        style: titleOneTextStyleBold,
                      ),
                      PlainTextButton(
                        title: 'Back',
                        func: () {
                          Navigator.of(context).pop(false);
                        },
                        textStyle: backButtonBoldItalics,
                        textColor: kBlack,
                      ),
                    ]
                ),
                SizedBox(
                  height: 10.0,
                ),
                Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: _selectedImage == null ? SizedBox(width: 1,) : Image.file(_selectedImage!, height: 80, width: 80,),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Upload a profile picture:', style: bodyTextStyleBold,),
                              SizedBox( width: 15.0,),
                              ElevatedButton(
                                onPressed: () async {
                                  var temp = await chooseProfilePicture(user);
                                  setState(() {
                                    this._selectedImage = temp;
                                  });
                                },
                                child: Icon(Icons.upload_file),
                                style: ElevatedButton.styleFrom(
                                  primary: kLightBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      OnboardingTextfield(
                        title: 'First Name:',
                        initialValue: user.firstName,
                        hintText: 'John',
                        callback: (value) => this.firstName = value!,
                      ), // FirstName
                      OnboardingTextfield(
                          title: 'Last Name:',
                          initialValue: user.lastName,
                          hintText: 'Wong',
                          callback: (value) => this.lastName = value!
                      ), // LastName
                      OnboardingDropdown(
                        title: 'Gender',
                        input: this.gender,
                        list: genderList,
                        callback: (value) => this.gender = value!,
                      ), // Gender
                      OnboardingTextfield(
                        title: 'Age:',
                        initialValue: user.age.toString(),
                        hintText: 'Enter your age',
                        callback: (value) => this.age = value!,
                      ), // Age
                      OnboardingDatepicker(
                        title: 'Date of Birth:',
                        currentDOB: user.dob,
                        callback: (value) => this.dob = value!,
                      ), // DOB
                      OnboardingTextfield(
                        title: 'Address Line 1:',
                        initialValue: user.address1,
                        hintText: 'Enter your address',
                        callback: (value) => this.address1 = value!,
                      ), // Address1
                      OnboardingTextfield(
                        title: 'Address Line 2:',
                        initialValue: user.address2,
                        hintText: 'Enter your address',
                        callback: (value) => this.address2 = value!,
                      ), // Address2
                      OnboardingTextfield(
                        title: 'Address Line 3:',
                        initialValue: user.address3,
                        hintText: 'Enter your address',
                        callback: (value) => this.address3 = value!,
                      ), // Address3
                      OnboardingTextfield(
                        title: 'Postal Code:',
                        initialValue: user.postalCode,
                        hintText: 'Enter your postal code',
                        callback: (value) => this.postalCode = value!,
                      ), // Postal Code
                      OnboardingDropdown(
                        title: 'Country Code:',
                        input: this.countryCode,
                        list: countryCodesList,
                        callback: (value) => this.countryCode = value!,
                      ), // Country Code
                      OnboardingTextfield(
                        title: 'City:',
                        initialValue: user.city,
                        hintText: 'Enter your city',
                        callback: (value) => this.city = value!,
                      ), // City
                      OnboardingTextfield(
                        title: 'School:',
                        initialValue: user.school,
                        hintText: 'Enter your school',
                        callback: (value) => this.school = value!,
                      ),

                      /// School
                    ],
                  ),
                ),
                SizedBox( height: 20,),
                RoundedButton(
                  title: "Save",
                  func: () {
                    submit(user);
                  },
                  colorBG: kLightBlue,
                  colorFont: kWhite,
                ),
                SizedBox( height: 20,),
              ],
            )
        ),
      ),
    );
  }

  Future<File?> chooseProfilePicture(User user) async {

    XFile? _xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (_xfile == null) {
      return null;
    }
    return File(_xfile.path);
  }

  Future<String?> uploadPicture(File? imageFile, User user) async {
    if (imageFile != null) {
      var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      var length = await imageFile.length();
      var request = http.MultipartRequest("POST", Uri.parse("https://eq-lab-dev.me/upload/image/profile-pic"));
      var multipartFile = new http.MultipartFile('image', stream, length,
          filename: basename(imageFile.path));
      request.fields.addAll({
        'platform': 'mp',
        'userId': user.userId
      });
      request.files.add(multipartFile);

      try {
        final http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          Map map = jsonDecode(responseData);
          return map['key'];
        } else {
          var responseData = await response.stream.bytesToString();
          print(responseData);
          throw Exception('Error faced');
        }
      }
      on Exception catch (err) {
        showDialog(
            context: this.context,
            builder: (BuildContext context) {
              return AlertPopup(title: "Error", desc: formatExceptionMessage(err.toString()),);
            });
      }
    }
  }

  void submit(User user) async {
    final form = _formkey.currentState!;
    final SecureStorage secureStorage = SecureStorage();

    if (form.validate()) {
      form.save();

      String? temp = await uploadPicture(_selectedImage!, user);
      String profilePicUrl = "";
      if(temp != null) {
        profilePicUrl = temp;
      }

      final body = jsonEncode(<String, String> {
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
        "profilePicUrl" : profilePicUrl,
      });

      try {
        User user = await doEditAccountDetails(body, secureStorage);
        secureStorage.writeSecureData('user', jsonEncode(user.toJson()));
        showDialog(context: this.context, builder: (BuildContext context) {
          return AlertPopup(
            title: "Success",
            desc: "Your account details have been successfully updated",
            func: () {Navigator.of(context).pushNamedAndRemoveUntil('/init-home', (route) => false);},
          );
        });
      }
      on Exception catch (err) {
        showDialog(
            context: this.context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: "Error",
                desc: formatExceptionMessage(err.toString()),
              );
            }
        );
      }
    }
  }

  Future<User> doEditAccountDetails(body, SecureStorage secureStorage) async {
    final String accessToken = await secureStorage.readSecureData('accessToken');

    final response = await http.put(
      Uri.parse('https://eq-lab-dev.me/api/mp/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    else if (response.statusCode == 400) {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
    else {
      print(response.body);
      throw Exception('Unforseen error occured');
    }
  }

  String formatExceptionMessage(String str) {
    int idx = str.indexOf(":");
    return str.substring(idx+1).trim();
  }
}