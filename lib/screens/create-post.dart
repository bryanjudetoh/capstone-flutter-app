import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

import '../constants.dart';

class CreatePostScreen extends StatefulWidget {
  CreatePostScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {

  final ImagePicker _picker = ImagePicker();
  final _formkey = GlobalKey<FormState>();
  final TextEditingController contentController = TextEditingController();
  final List<File> uploadedMediaContent = [];

  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context)!.settings.arguments as User;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.cancel_outlined),
                    onPressed: () {Navigator.pop(context);},
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: kLightBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          textStyle: TextStyle(
                            fontFamily: 'SF Display Pro',
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.white,
                          )
                      ),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          fontFamily: 'SF Display Pro',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        String message = '';
                        try {
                          message = await doCreatePost(this.contentController.text);
                          Navigator.of(context).pushNamedAndRemoveUntil('/init-home', (route) => false);
                        }
                        on Exception catch (err) {
                          message = formatExceptionMessage(err.toString());
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                message,
                                style: bodyTextStyle,
                              ),
                              duration: const Duration(seconds: 2),
                            )
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      user.profilePicUrl!.isNotEmpty ? user.profilePicUrl! : placeholderDisplayPicUrl,
                    ),
                    radius: 30,
                  ),
                  SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${user.firstName} ${user.lastName}', style: titleThreeTextStyleBold,),
                      SizedBox(height: 5,),
                      Text('${dateTimeFormat.format(DateTime.now())}', style: smallSubtitleTextStyle,),
                    ],
                  )
                ],
              ),
              SizedBox(height: 20,),
              Form(
                key: _formkey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: contentController,
                      maxLines: 10,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Write a post...',
                      ),
                      validator: RequiredValidator(errorText: "* Required"),
                    ),
                    SizedBox(height: 10,),
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: Container(
                    //     padding: EdgeInsets.symmetric(horizontal: 5),
                    //     decoration: BoxDecoration(
                    //       color: kLightBlue,
                    //       borderRadius: BorderRadius.circular(30),
                    //     ),
                    //     child: TextButton(
                    //       style: TextButton.styleFrom(
                    //           textStyle: TextStyle(
                    //             fontFamily: 'SF Display Pro',
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 16.0,
                    //             color: Colors.white,
                    //           )
                    //       ),
                    //       child: Row(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: <Widget>[
                    //           Icon(Icons.add, color: Colors.white,),
                    //           SizedBox(width: 5,),
                    //           Icon(Icons.camera_alt, color: Colors.white,),
                    //         ],
                    //       ),
                    //       onPressed: () async {
                    //         File? temp = await chooseProfilePicture(user);
                    //         if (temp != null) {
                    //           setState(() {
                    //             this.uploadedMediaContent.add(temp);
                    //           });
                    //         }
                    //       },
                    //     ),
                    //   ),
                    // ),
                    // Row(
                    //   children: displayUploadedImages(),
                    // ),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> doCreatePost(String content) async {
    var response = await widget.http.post(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/post'),
      body: jsonEncode(<String, String> {
        "content": content,
      })
    );

    if (response.statusCode == 201) {
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      return 'Successfully created post';
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while creating your post');
    }
  }

  List<Widget> displayUploadedImages() {
    List<Widget> list = [];
    for (File imageUrl in this.uploadedMediaContent) {
      list.add(Image.file(imageUrl, height: 120, width: 120,));
      list.add(SizedBox(width: 10,));
    }
    return list;
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
      var stream = new http.ByteStream(imageFile.openRead());
      stream.cast();
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
}
