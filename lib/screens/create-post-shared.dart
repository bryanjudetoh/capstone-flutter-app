import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/models/reward.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/utilities/securestorage.dart';

import '../constants.dart';

class InitCreatePostShared extends StatelessWidget {
  InitCreatePostShared({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> sharedItemMap = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return FutureBuilder(
      future: this.secureStorage.readSecureData('user'),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          User user = User.fromJson(Map<String, dynamic>.from(jsonDecode(snapshot.data!)));
          return CreatePostSharedScreen(user: user, sharedActivity: sharedItemMap['sharedActivity'], sharedReward: sharedItemMap['sharedReward'],);
        }
        else {
          return Container();
        }
      },
    );
  }
}


class CreatePostSharedScreen extends StatefulWidget {
  CreatePostSharedScreen({Key? key, required this.user, this.sharedActivity, this.sharedReward}) : super(key: key);

  final User user;
  final Activity? sharedActivity;
  final Reward? sharedReward;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _CreatePostSharedScreenState createState() => _CreatePostSharedScreenState();
}

class _CreatePostSharedScreenState extends State<CreatePostSharedScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                          message = await doCreatePost(
                            content: this.contentController.text,
                            user: widget.user,
                            sharedActivityId: widget.sharedActivity != null ? widget.sharedActivity!.activityId : null,
                            sharedRewardId: widget.sharedReward != null ? widget.sharedReward!.rewardId : null,
                          );
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
                      widget.user.profilePicUrl!.isNotEmpty ? widget.user.profilePicUrl! : placeholderDisplayPicUrl,
                    ),
                    radius: 30,
                  ),
                  SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${widget.user.firstName} ${widget.user.lastName}', style: titleThreeTextStyleBold,),
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
                    ],
                  )
              ),
              displaySharedItem(),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> doCreatePost({required String content, required User user, String? sharedActivityId, String? sharedRewardId}) async {
    if (_formkey.currentState!.validate()) {
      var response = await widget.http.post(
          Uri.parse('https://eq-lab-dev.me/api/social-media/mp/post'),
          body: sharedActivityId != null
              ? jsonEncode(<String, String> {
                  "content": content,
                  "sharedActivity": sharedActivityId,
                })
              : jsonEncode(<String, String> {
                  "content": content,
                  "sharedReward": sharedRewardId!,
                })
        ,
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        return 'Successfully created your shared post';
      }
      else {
        var result = jsonDecode(response.body);
        print(result);
        throw Exception('A problem occured while creating your shared post');
      }
    }
    else {
      throw Exception('Validation Error');
    }
  }

  Widget displaySharedItem() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: <Widget>[
            if (widget.sharedActivity != null)
              Container(
                child: widget.sharedActivity!.mediaContentUrls!.isEmpty
                    ? Image.network(
                        getPlaceholderPicUrl(widget.sharedActivity!.type!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 220,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          print('bad url: ${getPlaceholderPicUrl(widget.sharedActivity!.type!)}');
                          return const Center(
                            child: Text('Couldn\'t load image.', style: bodyTextStyle,),
                          );
                        }
                      )
                    : CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: false,
                          enableInfiniteScroll: true,
                          viewportFraction: 1.0,
                          aspectRatio: 4/3,
                        ),
                        items: widget.sharedActivity!.mediaContentUrls!
                            .map(
                                (url) => Image.network(
                              url,
                              fit: BoxFit.fitHeight,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                print('bad url: $url');
                                return const Center(
                                  child: Text('Couldn\'t load image.', style: bodyTextStyle,),
                                );
                              }
                            )
                        ).toList(),
                      ),
              ),
            if (widget.sharedReward != null)
              Container(
                child: widget.sharedReward!.mediaContentUrls!.isEmpty
                    ? Image.network(
                        placeholderRewardsPicUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 220,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          print('bad url: ${getPlaceholderPicUrl(widget.sharedActivity!.type!)}');
                          return const Center(
                            child: Text('Couldn\'t load image.', style: bodyTextStyle,),
                          );
                        }
                      )
                    : CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: false,
                          enableInfiniteScroll: true,
                          viewportFraction: 1.0,
                          aspectRatio: 4/3,
                        ),
                        items: widget.sharedReward!.mediaContentUrls!
                            .map(
                                (url) => Image.network(
                              url,
                              fit: BoxFit.fitHeight,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                print('bad url: $url');
                                return const Center(
                                  child: Text('Couldn\'t load image.', style: bodyTextStyle,),
                                );
                              }
                            )
                        ).toList(),
                      ),
              ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: kBluishWhite,
                border: Border.all(
                  width: 3,
                  color: kBluishWhite,
                ),//borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.sharedActivity != null
                        ? 'Activity: ${widget.sharedActivity!.name}'
                        : 'Reward: ${widget.sharedReward!.name}',
                    style: bodyTextStyleBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5,),
                  Text(
                    'Description: ${widget.sharedActivity != null
                        ? widget.sharedActivity!.description
                        : widget.sharedReward!.description
                    }',
                    style: smallBodyTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}