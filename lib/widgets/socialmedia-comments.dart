import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:loadmore/loadmore.dart';
import 'package:youthapp/models/comment.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

import '../constants.dart';

class InitSocialMediaComments extends StatelessWidget {
  InitSocialMediaComments({Key? key, required this.postId, required this.getReplyCommentsState}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final String postId;
  final Function getReplyCommentsState;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Comment>>(
        future: retrievePostComments(postId),
        builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
          if (snapshot.hasData) {
            List<Comment> initialCommentsList = snapshot.data!;
            return SocialMediaComments(initialCommentsList: initialCommentsList, postId: this.postId, getReplyCommentsState: getReplyCommentsState, http: this.http,);
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


class SocialMediaComments extends StatefulWidget {
  SocialMediaComments({Key? key, required this.initialCommentsList, required this.postId, required this.getReplyCommentsState, required this.http}) : super(key: key);
  
  final List<Comment> initialCommentsList;
  final String postId;
  final InterceptedHttp http;
  final Function getReplyCommentsState;
  

  @override
  _SocialMediaCommentsState createState() => _SocialMediaCommentsState();
}

class _SocialMediaCommentsState extends State<SocialMediaComments> {
  late int skip;
  late bool isEndOfList;
  late List<Comment> commentsList;

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
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/feed/comments/${widget.postId}?skip=${this.skip}'),
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
