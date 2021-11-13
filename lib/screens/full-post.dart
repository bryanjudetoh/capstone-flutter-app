import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:loadmore/loadmore.dart';
import 'package:youthapp/models/comment.dart';
import 'package:youthapp/models/post.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/utilities/securestorage.dart';
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
            return FullPostScreen(post: data['post'], user: data['user'], initialCommentsList: data['comments'], http: this.http,);
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

    data['comments'] = await retrievePostComments(postId);

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

  Future<List<Comment>> retrievePostComments(String postId) async {
    var response = await this.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/feed/comments/$postId?skip=0'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Comment> commentList = [];

      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        //print(i);
        commentList.add(Comment.fromJson(i));
      }

      return commentList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while retrieving post comments');
    }
  }
}

class FullPostScreen extends StatefulWidget {
  FullPostScreen({Key? key, required this.post, required this.user, required this.http, required this.initialCommentsList}) : super(key: key);

  final Post post;
  final User user;
  final InterceptedHttp http;
  final List<Comment> initialCommentsList;

  @override
  _FullPostScreenState createState() => _FullPostScreenState();
}

class _FullPostScreenState extends State<FullPostScreen> {

  late int skip;
  late bool isEndOfList;
  late bool hasLiked;
  late bool hasDisliked;
  late int numLikes;
  late int numDislikes;
  late int numComments;
  late String replyingToId;
  late bool isReplyingToPost;
  late List<Comment> commentsList;
  final _formkey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.skip = widget.initialCommentsList.length;
    this.isEndOfList = widget.initialCommentsList.length < backendSkipLimit ? true : false;
    this.hasLiked = widget.post.hasLiked!;
    this.hasDisliked = widget.post.hasDisliked!;
    this.numLikes = widget.post.numLikes!;
    this.numComments = widget.post.numComments!;
    this.numDislikes = widget.post.numDislikes!;
    this.replyingToId = widget.post.postId;
    this.isReplyingToPost = true;
    this.commentsList = widget.initialCommentsList;
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
                          List<Comment> refreshedList = await reloadComments();
                          await Future.delayed(Duration(seconds: 1));
                          setState(() {
                            this.numComments += 1;
                            this.commentsList = List.from(this.commentsList)..addAll(refreshedList);
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
                SocialMediaPost(post: widget.post, http: widget.http, isFullPost: true, getLikeState: getLikeState,),
                SizedBox(height: 10),
                displayComments(),
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

  Widget displayComments() {
    if (widget.post.numComments == 0) {
      return Container(
        child: Text('No comments yet', style: bodyTextStyle,),
      );
    }
    return LoadMore(
      isFinish: this.isEndOfList,
      onLoadMore: _loadMore,
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: this.commentsList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              getProfilePicUrl(this.commentsList, index).isNotEmpty ? getProfilePicUrl(this.commentsList, index) : placeholderDisplayPicUrl,
                            ),
                            radius: 20,
                          ),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${getName(this.commentsList, index)}',
                                style: smallBodyTextStyleBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5,),
                              Container(
                                width: MediaQuery.of(context).size.width*0.70,
                                child: Text(
                                  '${this.commentsList[index].content}',
                                  style: smallBodyTextStyle,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SizedBox(height: 5,),
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      '${dateTimeFormat.format(this.commentsList[index].createdAt!.toLocal())}',
                                      style: xSmallSubtitleTextStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Text(
                                  //   '${this.comments[index].numLikes} likes',
                                  //   style: xSmallBodyTextStyle,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                    constraints: BoxConstraints(),
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          textStyle: xSmallSubtitleTextStyleBold,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            this.isReplyingToPost = false;
                                            this.replyingToId = this.commentsList[index].commentId;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Replying to ${getName(this.commentsList, index)}',
                                                  style: bodyTextStyle,
                                                ),
                                                action: SnackBarAction(
                                                  label: 'Cancel',
                                                  onPressed: () {
                                                    setState(() {
                                                      this.isReplyingToPost = true;
                                                      this.replyingToId = widget.post.postId;
                                                    });
                                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                  },
                                                ),
                                                duration: const Duration(days: 365),
                                              )
                                          );
                                        },
                                        child: Text('Reply', style: xSmallSubtitleTextStyleBold,)),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: commentsModalBottomSheet(context, this.commentsList[index].commentId),
                        icon: Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                  if (this.commentsList[index].numComments! > 0)
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: this.commentsList[index].comments.length,
                      itemBuilder: (BuildContext context, int nestedIndex) {
                        return Container(
                          padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      getProfilePicUrl(this.commentsList[index].comments, nestedIndex).isNotEmpty
                                          ? getProfilePicUrl(this.commentsList[index].comments, nestedIndex)
                                          : placeholderDisplayPicUrl,
                                    ),
                                    radius: 20,
                                  ),
                                  SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${getName(this.commentsList[index].comments, nestedIndex)}',
                                        style: smallBodyTextStyleBold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5,),
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.60,
                                        child: Text(
                                          '${this.commentsList[index].comments[nestedIndex].content}',
                                          style: smallBodyTextStyle,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Text(
                                              '${dateTimeFormat.format(this.commentsList[index].comments[nestedIndex].createdAt!.toLocal())}',
                                              style: xSmallSubtitleTextStyle,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: commentsModalBottomSheet(context, this.commentsList[index].commentId),
                                icon: Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          }
      ),
    );
  }

  Future<bool> _loadMore() async {
    return await loadMoreComments();
  }

  Future<bool> loadMoreComments() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/feed/comments/${widget.post.postId}?skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      if (resultList.length > 0) {
        List<Comment> commentList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String, dynamic>.from(item);
          //print(i);
          commentList.add(Comment.fromJson(i));
        }
        setState(() {
          this.commentsList.addAll(commentList);
          this.skip += resultList.length;
        });
      }
      else {
        print('no more to add');
        setState(() {
          this.isEndOfList = true;
        });
      }
      return true;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      return false;
    }
  }

  String getProfilePicUrl(List<Comment> list, int index) {
    return list[index].mpUser != null
        ? list[index].mpUser!.profilePicUrl!
        : list[index].organisation!.orgDisplayPicUrl!;
  }

  String getName(List<Comment> list, int index) {
    return list[index].mpUser != null
        ? '${list[index].mpUser!.firstName} ${list[index].mpUser!.lastName}'
        : list[index].organisation!.name;
  }

  Future<String> doSendComment(String content) async {
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

  Future<List<Comment>> reloadComments() async {
    setState(() {
      this.commentsList.clear();
      this.skip = 0;
      this.isEndOfList = false;
    });
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/feed/comments/${widget.post.postId}?skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Comment> newCommentsList = [];

      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        //print(i);
        newCommentsList.add(Comment.fromJson(i));
      }

      setState(() {
        this.skip = resultList.length;
        this.isEndOfList = resultList.length < backendSkipLimit ? true : false;
      });
      return newCommentsList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while retrieving post comments');
    }
  }

  VoidCallback commentsModalBottomSheet(BuildContext context, String commentId) {
    return () {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.report_problem_outlined, color: Colors.redAccent,),
                  title: Text('Report', style: bodyTextStyleBold,),
                  onTap: () {}, //do report comment here
                ),
              ],
            );
          }
      );
    };
  }
}


