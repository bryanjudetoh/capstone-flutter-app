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
import 'package:comment_box/comment/comment.dart';

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
        print(i);
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
  late String replyingToId;
  late bool isReplyingToPost;
  late List<Comment> comments;
  GlobalKey formKey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.skip = widget.initialCommentsList.length;
    this.isEndOfList = widget.initialCommentsList.length < backendSkipLimit ? true : false;
    this.hasLiked = widget.post.hasLiked!;
    this.hasDisliked = widget.post.hasDisliked!;
    this.numLikes = widget.post.numLikes!;
    this.numDislikes = widget.post.numDislikes!;
    this.replyingToId = widget.post.postId;
    this.isReplyingToPost = true;
    this.comments = widget.initialCommentsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: CommentBox(
            userImage: widget.user.profilePicUrl!.isNotEmpty ? widget.user.profilePicUrl! : placeholderDisplayPicUrl,
            labelText: 'Write a comment...',
            withBorder: true,
            errorText: 'Comment cannot be blank',
            formKey: this.formKey,
            commentController: this.commentController,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            sendWidget: Icon(Icons.send_sharp, size: 30),
            sendButtonMethod: () {
              handleSendComment();
            },
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
          itemCount: this.comments.length,
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
                              getProfilePicUrl(this.comments, index).isNotEmpty ? getProfilePicUrl(this.comments, index) : placeholderDisplayPicUrl,
                            ),
                            radius: 20,
                          ),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${getName(this.comments, index)}',
                                style: smallBodyTextStyleBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5,),
                              Container(
                                width: MediaQuery.of(context).size.width*0.70,
                                child: Text(
                                  '${this.comments[index].content}',
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
                                      '${dateTimeFormat.format(this.comments[index].createdAt!.toLocal())}',
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
                                        onPressed: () {print('reply');},
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
                        onPressed: commentsModalBottomSheet(context, this.comments[index].commentId),
                        icon: Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                  if (this.comments[index].numComments! > 0)
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: this.comments[index].comments.length,
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
                                      getProfilePicUrl(this.comments[index].comments, index).isNotEmpty
                                          ? getProfilePicUrl(this.comments[index].comments, index)
                                          : placeholderDisplayPicUrl,
                                    ),
                                    radius: 20,
                                  ),
                                  SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${getName(this.comments[index].comments, index)}',
                                        style: smallBodyTextStyleBold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5,),
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.60,
                                        child: Text(
                                          '${this.comments[index].comments[nestedIndex].content}',
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
                                              '${dateTimeFormat.format(this.comments[index].comments[nestedIndex].createdAt!.toLocal())}',
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
                                onPressed: commentsModalBottomSheet(context, this.comments[index].commentId),
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
          this.comments.addAll(commentList);
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

  Future<void> handleSendComment() async {

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


