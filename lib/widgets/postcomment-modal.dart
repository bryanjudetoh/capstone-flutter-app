import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:youthapp/models/post.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';

class InitPostCommentModal extends StatelessWidget {
  InitPostCommentModal({Key? key,
    required this.reportedContentId,
    required this.http, required this.isPost,
    required this.isMyPostComment,
    this.setCommentsWidget,
    this.setPostContent,
  }) : super(key: key);

  final String reportedContentId;
  final InterceptedHttp http;
  final bool isPost;
  final bool isMyPostComment;
  final SecureStorage secureStorage = SecureStorage();
  final Function? setCommentsWidget;
  final Function? setPostContent;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: initData(),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data!;
          return PostCommentModal(
            reportedContentId: reportedContentId,
            reportTypes: data['reportTypes'],
            http: this.http,
            isPost: this.isPost,
            isMyPostComment: this.isMyPostComment,
            post: data['post'],
            setCommentsWidget: this.setCommentsWidget,
            setPostContent: this.setPostContent,
          );
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
                  size: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: titleThreeTextStyleBold,
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
    );
  }

  Future<Map<String, dynamic>> initData() async {
    Map<String, dynamic> data = {};
    data['reportTypes'] = await getReportTypes();
    if (this.isPost) {
      data['post'] = await retrievePost(this.reportedContentId);
    }

    return data;
  }

  Future<List<String>> getReportTypes() async{
    var response = await this.http.get(
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

class PostCommentModal extends StatefulWidget {
  const PostCommentModal({Key? key,
    required this.reportedContentId,
    required this.reportTypes,
    required this.http,
    required this.isPost,
    required this.isMyPostComment,
    this.post,
    this.setCommentsWidget,
    this.setPostContent,
  }) : super(key: key);

  final String reportedContentId;
  final List<String> reportTypes;
  final InterceptedHttp http;
  final bool isPost;
  final bool isMyPostComment;
  final Post? post;
  final Function? setCommentsWidget;
  final Function? setPostContent;

  @override
  _PostCommentModalState createState() => _PostCommentModalState();
}

class _PostCommentModalState extends State<PostCommentModal> {
  final _reportFormKey = GlobalKey<FormState>();
  final _editingFormKey = GlobalKey<FormState>();
  late String selectedReportType;
  late TextEditingController reportReasonController;
  late TextEditingController editingController;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    this.selectedReportType = '';
    this.reportReasonController = TextEditingController();
    this.editingController = TextEditingController();
    this.pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    this.reportReasonController.dispose();
    this.pageController.dispose();
    this.editingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: PageView(
        children: widget.isMyPostComment
            ? [
              editDeletePage(),
              editingPage(),
              deletingPage(),
            ]
            : [
              reportMainPage(),
              submitReportPage(),
            ],
        controller: this.pageController,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  void changePage(int page) {
    pageController.jumpToPage(page);
  }

  Widget reportMainPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ExpansionTile(
            leading: Icon(Icons.report_problem_outlined, color: Colors.redAccent,),
            title: Text('Report ${widget.isPost ? 'Post' : 'Comment'}', style: bodyTextStyleBold,),
            trailing: Icon(Icons.arrow_drop_down),
            children: [
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.reportTypes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('${widget.reportTypes[index]}', style: bodyTextStyle,),
                      onTap: () {
                        setState(() {
                          this.selectedReportType = widget.reportTypes[index];
                        });
                        changePage(1);
                      },
                    );
                  }
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget submitReportPage() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        changePage(0);
                      },
                      icon: Icon(Icons.arrow_back_outlined)),
                  Text('Reason: ${this.selectedReportType}', style: bodyTextStyle,),
                ],
              ),
              TextButton(
                child: Text('Submit', style: smallBodyTextStyleBold,),
                onPressed: () async {
                  if (this._reportFormKey.currentState!.validate()) {
                    String message = '';
                    try {
                      message = await doReport(this.reportReasonController.text, this.selectedReportType);
                      Navigator.pop(context);
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
                          duration: const Duration(seconds: 3),
                        )
                    );
                  }
                },
              ),
            ],
          ),
          Form(
            key: _reportFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  maxLines: 4,
                  controller: this.reportReasonController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Why are you reporting this ${widget.isPost ? 'post' : 'comment'}?',
                    contentPadding: EdgeInsets.all(12),
                  ),
                  validator: RequiredValidator(errorText: "* Required"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> doReport(String reason, String type) async {
    var response = await widget.http.post(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/${widget.isPost ? 'post' : 'comment'}/${widget.reportedContentId}/report'),
      body: jsonEncode(<String, String> {
        'reason': reason,
        'type': type,
      }),
    );

    if (response.statusCode == 201) {
      var result = jsonDecode(response.body);
      print(result);
      return 'Successfully reported this ${widget.isPost ? 'post' : 'comment'}';
    }
    else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      print(result);
      return result['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print(response.statusCode);
      print(result);
      throw Exception('A problem occurred while reporting this ${widget.isPost ? 'post' : 'comment'}');
    }
  }

  Widget editDeletePage() {
    return Column(
      children: <Widget>[
        if (widget.post != null)
          if (widget.post!.sharedActivity == null && widget.post!.sharedReward == null)
            ListTile(
              leading: Icon(Icons.share,),
              title: Text('Share Post', style: bodyTextStyleBold,),
              onTap: () {
                doShare();
              },
            ),
        ListTile(
          leading: Icon(Icons.edit,),
          title: Text('Edit ${widget.isPost ? 'Post' : 'Comment'}', style: bodyTextStyleBold,),
          onTap: () {
            changePage(1);
          },
        ),
        ListTile(
          leading: Icon(Icons.delete, color: Colors.redAccent,),
          title: Text('Delete ${widget.isPost ? 'Post' : 'Comment'}', style: bodyTextStyleBold,),
          onTap: () {
            changePage(2);
          },
        ),
      ],
    );
  }

  Widget editingPage() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        changePage(0);
                      },
                      icon: Icon(Icons.arrow_back_outlined)),
                  Text('Editing ${widget.isPost ? 'post' : 'comment'}', style: bodyTextStyle,),
                ],
              ),
              TextButton(
                child: Text('Submit', style: smallBodyTextStyleBold,),
                onPressed: () async {
                  if (this._editingFormKey.currentState!.validate()) {
                    String message = '';
                    try {
                      message = await submitEditing(this.editingController.text);
                      Navigator.pop(context);
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
                          duration: const Duration(seconds: 3),
                        )
                    );
                  }
                },
              ),
            ],
          ),
          Form(
            key: _editingFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  maxLines: 4,
                  controller: this.editingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write your edits for this ${widget.isPost ? 'post' : 'comment'} here',
                    contentPadding: EdgeInsets.all(12),
                  ),
                  validator: RequiredValidator(errorText: "* Required"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget deletingPage() {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    changePage(0);
                  },
                  icon: Icon(Icons.arrow_back_outlined)),
              SizedBox(width: 10,),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.05,),
          Column(
            children: <Widget>[
              Text(
                'Are you sure you want to delete this ${widget.isPost ? 'post' : 'comment'}?',
                style: titleThreeTextStyleBold,
              ),
              SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      changePage(0);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 20.0,
                        height: 1.25,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(width: 80),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: EdgeInsets.fromLTRB(10, 3, 13, 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                    onPressed: () async {
                      String message = '';
                      try {
                        message = await doDeleting();
                        Navigator.pop(context);
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
                            duration: const Duration(seconds: 3),
                          )
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_forever,),
                        SizedBox(width: 5,),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 20.0,
                            height: 1.25,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void doShare() {
    Share.share(widget.post!.content);
  }

  Future<String> submitEditing(String newContent) async {
    if (widget.setCommentsWidget != null) {
      widget.setCommentsWidget!(true, Container());
    }
    var response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/${widget.isPost ? 'post' : 'comment'}/${widget.reportedContentId}'),
      body: jsonEncode(<String, String> {
        'content': newContent,
      }),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (widget.setCommentsWidget != null) {
        widget.setCommentsWidget!(false, null,);
      }
      if (widget.setPostContent != null) {
        widget.setPostContent!(newContent);
      }

      return responseBody['message'];
    }
    else if (response.statusCode == 403) {
      var result = jsonDecode(response.body);
      print(result);
      return result['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print(response.statusCode);
      print(result);
      throw Exception('A problem occurred while submiting this edit');
    }
  }

  Future<String> doDeleting() async {
    var response = await widget.http.delete(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/${widget.isPost ? 'post' : 'comment'}/${widget.reportedContentId}'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return responseBody['message'];
    }
    else if (response.statusCode == 403) {
      var result = jsonDecode(response.body);
      print(result);
      return result['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print(response.statusCode);
      print(result);
      throw Exception('A problem occurred while submiting this edit');
    }
  }
}
