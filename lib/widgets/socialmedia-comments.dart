import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:loadmore/loadmore.dart';
import 'package:youthapp/models/comment.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/widgets/report-modal.dart';

import '../constants.dart';

class InitSocialMediaComments extends StatelessWidget {
  InitSocialMediaComments({Key? key, required this.postId, required this.getReplyCommentsState, required this.requestFocus, required this.cancelFocus}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final String postId;
  final Function getReplyCommentsState;
  final Function requestFocus;
  final Function cancelFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Comment>>(
        future: retrievePostComments(postId),
        builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
          if (snapshot.hasData) {
            List<Comment> initialCommentsList = snapshot.data!;
            return SocialMediaComments(initialCommentsList: initialCommentsList, postId: this.postId, getReplyCommentsState: getReplyCommentsState, http: this.http, requestFocus: this.requestFocus, cancelFocus: this.cancelFocus,);
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
            return Container();
          }
        },
      ),
    );
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


class SocialMediaComments extends StatefulWidget {
  SocialMediaComments({Key? key, required this.initialCommentsList, required this.postId, required this.getReplyCommentsState, required this.http, required this.requestFocus, required this.cancelFocus}) : super(key: key);
  
  final List<Comment> initialCommentsList;
  final String postId;
  final InterceptedHttp http;
  final Function getReplyCommentsState;
  final Function requestFocus;
  final Function cancelFocus;
  

  @override
  _SocialMediaCommentsState createState() => _SocialMediaCommentsState();
}

class _SocialMediaCommentsState extends State<SocialMediaComments> {
  late int skip;
  late bool isEndOfList;
  late List<Comment> commentsList;
  List<String> reportTypes = [];

  @override
  void initState() {
    super.initState();
    this.skip = widget.initialCommentsList.length;
    this.isEndOfList = widget.initialCommentsList.length < backendSkipLimit ? true : false;
    this.commentsList = widget.initialCommentsList;
  }
  
  @override
  Widget build(BuildContext context) {
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
                                  CommentLikesDislikes(comment: this.commentsList[index], http: widget.http,),
                                  Container(
                                    constraints: BoxConstraints(),
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          textStyle: xSmallSubtitleTextStyleBold,
                                        ),
                                        onPressed: () {
                                          widget.requestFocus();
                                          widget.getReplyCommentsState(this.commentsList[index].commentId, false);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Replying to ${getName(this.commentsList, index)}',
                                                  style: bodyTextStyle,
                                                ),
                                                action: SnackBarAction(
                                                  label: 'Cancel',
                                                  onPressed: () {
                                                    widget.cancelFocus();
                                                    widget.getReplyCommentsState( widget.postId, true);
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
                        onPressed: () async {
                          if (this.reportTypes.isEmpty) {
                            List<String> reportTypes = await getReportTypes();
                            setState(() {
                              this.reportTypes = reportTypes;
                            });
                          }
                          commentsModalBottomSheet(context, this.commentsList[index].commentId);
                        },
                        icon: Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                  if (this.commentsList[index].numComments! > 0)
                    displayReplies(this.commentsList[index].comments),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget displayReplies(List<Comment> list) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
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
                      getProfilePicUrl(list, nestedIndex).isNotEmpty
                          ? getProfilePicUrl(list, nestedIndex)
                          : placeholderDisplayPicUrl,
                    ),
                    radius: 20,
                  ),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${getName(list, nestedIndex)}',
                        style: smallBodyTextStyleBold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5,),
                      Container(
                        width: MediaQuery.of(context).size.width*0.60,
                        child: Text(
                          '${list[nestedIndex].content}',
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
                              '${dateTimeFormat.format(list[nestedIndex].createdAt!.toLocal())}',
                              style: xSmallSubtitleTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          CommentLikesDislikes(comment: list[nestedIndex], http: widget.http,),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () async {
                  if (this.reportTypes.isEmpty) {
                    List<String> reportTypes = await getReportTypes();
                    setState(() {
                      this.reportTypes = reportTypes;
                    });
                  }
                  commentsModalBottomSheet(context, list[nestedIndex].commentId);
                },
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _loadMore() async {
    return await loadMoreComments();
  }

  Future<bool> loadMoreComments() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/feed/comments/${widget.postId}?skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      if (resultList.length > 0) {
        List<Comment> commentList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String, dynamic>.from(item);
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

  Future<List<String>> getReportTypes() async{
    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/social-media/report/type/list')
    );
    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<String> reportTypesList = [];
      for (dynamic item in resultList) {
        reportTypesList.add(item.toString());
      }
      return reportTypesList;
    }
    else {
      var result = jsonDecode(response.body);
      print(response.statusCode);
      print(result);
      throw Exception('A problem occurred while responding to this friend request');
    }
  }

  void commentsModalBottomSheet(BuildContext context, String commentId) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ReportModal(reportedContentId: commentId, reportTypes: this.reportTypes, http: widget.http, isPost: false,);
        }
    );
  }
}

class CommentLikesDislikes extends StatefulWidget {
  const CommentLikesDislikes({Key? key, required this.comment, required this.http}) : super(key: key);

  final Comment comment;
  final InterceptedHttp http;

  @override
  _CommentLikesDislikesState createState() => _CommentLikesDislikesState();
}

class _CommentLikesDislikesState extends State<CommentLikesDislikes> {
  late bool hasLiked;
  late bool hasDisliked;
  late int numLikes;
  late int numDislikes;

  @override
  void initState() {
    super.initState();
    this.hasLiked = widget.comment.hasLiked!;
    this.hasDisliked = widget.comment.hasDisliked!;
    this.numLikes = widget.comment.numLikes!;
    this.numDislikes = widget.comment.numDislikes!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10,),
        Column(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () async {
                await handleLikeComment();
              }, //do like or unlike
              icon: Icon(
                Icons.thumb_up_alt_outlined,
                color: this.hasDisliked ? null : this.hasLiked ? Colors.blue : null,
                size: 20,
              ),
            ),
            Text('${this.numLikes}', style: xSmallSubtitleTextStyle,),
          ],
        ),
        SizedBox(width: 15,),
        Column(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () async {
                await handleDislikeComment();
              }, //do dislike or undislike
              icon: Icon(
                Icons.thumb_down_alt_outlined,
                color: this.hasLiked ? null : this.hasDisliked ? Colors.red : null,
                size: 20,
              ),
            ),
            Text('${this.numDislikes}', style: xSmallSubtitleTextStyle,),
          ],
        ),
        SizedBox(width: 10,),
      ],
    );
  }

  Future<void> handleLikeComment() async {
    String message = '';
    try {
      message = await doLikeComment();
      setState(() {
        this.hasLiked = !this.hasLiked;
        if (this.hasLiked) {
          this.hasDisliked = false;
        }
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

  Future<String> doLikeComment() async {
    var response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/comment/${widget.comment.commentId}/like'),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (!this.hasLiked) {
        setState(() {
          this.numLikes += 1;
          if (this.hasDisliked) {
            this.numDislikes -= 1;
          }
        });
      }
      else {
        setState(() {
          this.numLikes -= 1;
        });
      }
      return result['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('Error occured while liking this comment');
    }
  }

  Future<void> handleDislikeComment() async {
    String message = '';
    try {
      message = await doDislikeComment();
      setState(() {
        this.hasDisliked = !this.hasDisliked;
        if (this.hasDisliked) {
          this.hasLiked = false;
        }
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

  Future<String> doDislikeComment() async {
    var response = await widget.http.put(
        Uri.parse('https://eq-lab-dev.me/api/social-media/mp/comment/${widget.comment.commentId}/dislike')
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (!this.hasDisliked) {
        setState(() {
          this.numDislikes += 1;
          if (this.hasLiked) {
            this.numLikes -= 1;
          }
        });
      }
      else {
        setState(() {
          this.numDislikes -= 1;
        });
      }
      return result['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('Error occured while disliking this comment');
    }
  }
}

