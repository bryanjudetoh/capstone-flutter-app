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
import 'package:youthapp/utilities/securestorage.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

import '../constants.dart';

class CreatePostScreen extends StatefulWidget {
  CreatePostScreen({Key? key}) : super(key: key);

  final intHttp = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final SecureStorage secureStorage = SecureStorage();

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
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
                          message = await doCreatePost(this.contentController.text, user);
                          Navigator.of(context).pushNamedAndRemoveUntil('/init-home', (route) => false);
                        }
                        on Exception catch (err) {
                          message = formatExceptionMessage(err.toString());
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.add, color: Colors.white,),
                              SizedBox(width: 5,),
                              Icon(Icons.camera_alt, color: Colors.white,),
                            ],
                          ),
                          onPressed: () async {
                            if (this.uploadedMediaContent.length < 9) {
                              File? temp = await choosePictureFromGallery(user);
                              if (temp != null) {
                                setState(() {
                                  this.uploadedMediaContent.add(temp);
                                });
                              }
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Cannot add more than 9 photos',
                                      style: bodyTextStyle,
                                    ),
                                    duration: const Duration(seconds: 1),
                                  )
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ),
              displayUploadImages(),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> doCreatePost(String content, User user) async {
    if (_formkey.currentState!.validate()) {
      var response = await widget.intHttp.post(
          Uri.parse('https://eq-lab-dev.me/api/social-media/mp/post'),
          body: jsonEncode(<String, String> {
            "content": content,
          })
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        String postId = responseBody['postId'];
        if (this.uploadedMediaContent.isNotEmpty) {
          try {
            String message = await uploadPicture(user, postId);
            print(message);
          }
          on Exception catch (err) {
            print(formatExceptionMessage(err.toString()));
          }
        }
        return 'Successfully created post';
      }
      else {
        var result = jsonDecode(response.body);
        print(result);
        throw Exception('A problem occured while creating your post');
      }
    }
    else {
      throw Exception('Validation Error');
    }
  }
  
  Widget displayUploadImages() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      primary: false,
      padding: EdgeInsets.all(5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
      ),
      itemCount: this.uploadedMediaContent.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.all(5.0),
          child: Stack(
            children: [
              Image.file(
                this.uploadedMediaContent[index],
                height: MediaQuery.of(context).size.width*0.3,
                width: MediaQuery.of(context).size.width*0.3,
                fit: BoxFit.cover,
              ),
              Container(
                alignment: Alignment.topRight,
                child: IconButton(
                  padding: EdgeInsets.all(3),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.uploadedMediaContent.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Future<File?> choosePictureFromGallery(User user) async {
    XFile? _xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (_xfile == null) {
      return null;
    }
    return File(_xfile.path);
  }

  Future<String> uploadPicture(User user, String postId) async {
    final String accessToken = await widget.secureStorage.readSecureData('accessToken');
    var request = http.MultipartRequest("POST", Uri.parse("https://eq-lab-dev.me/upload/image/post-pic"));
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    });
    for (File image in this.uploadedMediaContent) {
      request.files.add(await prepareMultipartFile(image));
    }
    request.fields.addAll({
      'platform': 'mp',
      'postId': postId,
    });
    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      Map<String, dynamic> map = jsonDecode(responseData);
      print(map);
      return 'Successfully uploaded post pictures';
    } else {
      var responseData = await response.stream.bytesToString();
      print(responseData);
      throw Exception('Error faced while uploading post pictures');
    }
  }

  Future<http.MultipartFile> prepareMultipartFile(File imageFile) async {
    var stream = new http.ByteStream(imageFile.openRead());
    stream.cast();
    var length = await imageFile.length();
    var multipartFile = new http.MultipartFile('images', stream, length,
        filename: basename(imageFile.path));
    return multipartFile;
  }
}
