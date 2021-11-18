import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/models/post.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/socialmedia-comments.dart';
import 'package:youthapp/widgets/socialmedia-post.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../constants.dart';

class InitFullPostScreen extends StatelessWidget {
  InitFullPostScreen({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();
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
      child: FutureBuilder<Map<String, dynamic>>(
        future: retrieveFullPostData(postId),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!;
            return FullPostScreen(post: data['post'], user: data['user'], http: this.http,);
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

  Future<Map<String, dynamic>> retrieveFullPostData(String postId) async {
    Map<String, dynamic> data = {};

    String userData = await this.secureStorage.readSecureData('user');
    data['user'] = User.fromJson(jsonDecode(userData));

    data['post'] = await retrievePost(postId);

    return data;
  }

  Future<Post> retrievePost(String postId) async {
    var response = await this.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/post/$postId'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      Post post = Post.fromJson(responseBody);
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
  FullPostScreen({Key? key, required this.post, required this.user, required this.http}) : super(key: key);

  final Post post;
  final User user;
  final InterceptedHttp http;

  @override
  _FullPostScreenState createState() => _FullPostScreenState();
}

class _FullPostScreenState extends State<FullPostScreen> {

  late bool hasLiked;
  late bool hasDisliked;
  late int numLikes;
  late int numDislikes;
  late int numComments;
  late String replyingToId;
  late bool isReplyingToPost;
  late Widget commentsWidget;
  late FocusNode commentFocusNode;
  final _formkey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.hasLiked = widget.post.hasLiked!;
    this.hasDisliked = widget.post.hasDisliked!;
    this.numLikes = widget.post.numLikes!;
    this.numComments = widget.post.numComments!;
    this.numDislikes = widget.post.numDislikes!;
    this.replyingToId = widget.post.postId;
    this.isReplyingToPost = true;
    this.commentFocusNode = FocusNode();
    this.commentsWidget = InitSocialMediaComments(
      postId: widget.post.postId,
      getReplyCommentsState: getReplyCommentsState,
      requestFocus: this.requestFocus,
      cancelFocus: this.cancelFocus,
      setCommentsWidget: setCommentsWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: BottomAppBar(
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
            child: Form(
              key: _formkey,
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.user.profilePicUrl!.isNotEmpty ? widget.user.profilePicUrl! : placeholderDisplayPicUrl,
                    ),
                    radius: 25,
                  ),
                  Expanded(
                    child: TextFormField(
                      focusNode: this.commentFocusNode,
                      maxLines: 4,
                      minLines: 1,
                      controller: commentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Write a comment...',
                        contentPadding: EdgeInsets.all(12),
                      ),
                      validator: RequiredValidator(errorText: "* Required"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      String message = '';
                      var form = _formkey.currentState!;
                      if (form.validate()) {
                        try {
                          message = await doSendComment(this.commentController.text);
                          setState(() {
                            this.numComments += 1;
                            this.commentsWidget = new InitSocialMediaComments(
                              postId: widget.post.postId,
                              getReplyCommentsState: getReplyCommentsState,
                              requestFocus: this.requestFocus,
                              cancelFocus: this.cancelFocus,
                              setCommentsWidget: setCommentsWidget,
                            );
                          });
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
                              duration: const Duration(seconds: 1),
                            )
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
                        data['numComments'] = this.numComments;
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
                SocialMediaPost(post: widget.post, http: widget.http, isFullPost: true, getLikeState: getLikeState, displayNumComments: displayNumComments,),
                SizedBox(height: 10),
                this.commentsWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getLikeState(bool liked, bool disliked, int numLikes, int numDislikes, int numComments) {
    setState(() {
      this.hasLiked = liked;
      this.hasDisliked = disliked;
      this.numLikes = numLikes;
      this.numDislikes = numDislikes;
      this.numComments = numComments;
    });
  }

  void getReplyCommentsState(String replyingToId, bool isReplyingToPost) {
    setState(() {
      this.replyingToId = replyingToId;
      this.isReplyingToPost = isReplyingToPost;
    });
  }

  int displayNumComments() {
    return this.numComments;
  }

  void requestFocus() {
    this.commentFocusNode.requestFocus();
  }

  void cancelFocus() {
    this.commentFocusNode.unfocus();
    this.commentController.clear();
  }

  Future<String> doSendComment(String content) async {
    setState(() {
      this.commentsWidget = Container();
    });
    print(content);
    var response = await widget.http.post(
        Uri.parse('https://eq-lab-dev.me/api/social-media/mp/comment'),
        body: jsonEncode(<String, String> {
          '${this.isReplyingToPost ? 'postId' : 'commentId'}': this.replyingToId,
          'content': content,
        })
    );
    this.commentController.clear();
    if (response.statusCode == 201) {
      if (!this.isReplyingToPost) {
        setState(() {
          this.isReplyingToPost = true;
          this.replyingToId = widget.post.postId;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      return 'Successfully posted comment';
    }
    else {
      if (!this.isReplyingToPost) {
        setState(() {
          this.isReplyingToPost = true;
          this.replyingToId = widget.post.postId;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured in posting your comment');
    }
  }

  void setCommentsWidget(bool isReset, Widget? blankCommentsWidget) {
    if (isReset) {
      setState(() {
        this.commentsWidget = blankCommentsWidget!;
      });
    }
    else {
      setState(() {
        this.commentsWidget = new InitSocialMediaComments(
          postId: widget.post.postId,
          getReplyCommentsState: getReplyCommentsState,
          requestFocus: this.requestFocus,
          cancelFocus: this.cancelFocus,
          setCommentsWidget: setCommentsWidget,
        );
      });
    }
  }
}


