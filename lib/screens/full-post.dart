import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/models/post.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/widgets/socialmedia-post.dart';

import '../constants.dart';

class InitFullPostScreen extends StatelessWidget {
  InitFullPostScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    final String postId = ModalRoute.of(context)!.settings.arguments as String;
    return Container(
      color: Colors.white,
      child: FutureBuilder<Post>(
        future: retrievePost(postId),
        builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
          if (snapshot.hasData) {
            Post post = snapshot.data!;
            return FullPostScreen(post: post, http: this.http,);
          }
          else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: titleTwoTextStyleBold,
                    ),
                  ),
                ],
              ),
            );
          }
          else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Loading...',
                      style: titleTwoTextStyleBold,
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<Post> retrievePost(String postId) async {
    print('post id: $postId');
    var response = await this.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/post/$postId'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      Post post = Post.fromJson(responseBody);
      print(post.toJson());
      return post;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while retrieving post data');
    }
  }
}

class FullPostScreen extends StatefulWidget {
  FullPostScreen({Key? key, required this.post, required this.http}) : super(key: key);

  final Post post;
  final InterceptedHttp http;

  @override
  _FullPostScreenState createState() => _FullPostScreenState();
}

class _FullPostScreenState extends State<FullPostScreen> {

  late bool hasLiked;
  late bool hasDisliked;
  late int numLikes;
  late int numDislikes;

  @override
  void initState() {
    super.initState();
    this.hasLiked = widget.post.hasLiked!;
    this.hasDisliked = widget.post.hasDisliked!;
    this.numLikes = widget.post.numLikes!;
    this.numDislikes = widget.post.numDislikes!;
  }

  @override
  Widget build(BuildContext context) {
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
                  ElevatedButton(
                    onPressed: () {
                      Map<String, dynamic> data = {};
                      data['hasLiked'] = this.hasLiked;
                      data['hasDisliked'] = this.hasDisliked;
                      data['numLikes'] = this.numLikes;
                      data['numDislikes'] = this.numDislikes;
                      Navigator.of(context).pop(data);
                      },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_ios, color: kBlack, size: 25,)
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                      primary: kGrey,
                    ),
                  ),
                  Text(
                    'Post',
                    style: titleOneTextStyleBold,
                  ),
                  Flexible(
                    child: SizedBox(width: 65),
                  )
                ],
              ),
              SizedBox(height: 20,),
              SocialMediaPost(post: widget.post, http: widget.http, isFullPost: true, getLikeState: getLikeState,),
            ],
          ),
        ),
      ),
    );
  }

  void getLikeState(bool liked, bool disliked, int numLikes, int numDislikes) {
    setState(() {
      this.hasLiked = liked;
      this.hasDisliked = disliked;
      this.numLikes = numLikes;
      this.numDislikes = numDislikes;
    });
  }
}


