import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/models/post.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../constants.dart';

class SocialMediaPost extends StatefulWidget {
  const SocialMediaPost({Key? key, required this.post, required this.http, required this.isFullPost}) : super(key: key);

  final Post post;
  final InterceptedHttp http;
  final bool isFullPost;

  @override
  _SocialMediaPostState createState() => _SocialMediaPostState();
}

class _SocialMediaPostState extends State<SocialMediaPost> {

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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 5,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      getProfilePicUrl().isNotEmpty ? getProfilePicUrl() : placeholderDisplayPicUrl,
                    ),
                    radius: 30,
                  ),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${getName()}',
                        style: bodyTextStyleBold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5,),
                      Text(
                        '${dateTimeFormat.format(widget.post.createdAt!.toLocal())}',
                        style: subtitleTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: postsModalBottomSheet(context, widget.post.postId),
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Container(
            child: Text('${widget.post.content}', style: bodyTextStyle,),
          ),
          SizedBox(height: 10,),
          Container(
            child: widget.post.sharedActivity == null && widget.post.sharedReward == null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: widget.post.mediaContentUrls.isEmpty
                        ? Image.network(
                      placeholderPostPicUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 220,
                    )
                        : CarouselSlider(
                            options: CarouselOptions(
                              autoPlay: false,
                              enableInfiniteScroll: true,
                              viewportFraction: 1.0,
                            ),
                            items: widget.post.mediaContentUrls
                                .map(
                                    (url) => Image.network(
                                  url,
                                  fit: BoxFit.fitHeight,
                                )
                            ).toList(),
                          ),
                )
                : Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45, width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.post.sharedActivity != null) {
                            Navigator.pushNamed(context, '/activity-details', arguments: widget.post.sharedActivity!.activityId);
                          }
                          else {
                            print('no reward details screen yet');
                          }
                        },
                        child: Column(
                          children: <Widget>[
                            if (widget.post.sharedActivity != null)
                              Container(
                                child: widget.post.sharedActivity!.mediaContentUrls!.isEmpty
                                    ? Image.network(
                                        getPlaceholderPicUrl(widget.post.sharedActivity!.type!),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 220,
                                      )
                                    : CarouselSlider(
                                        options: CarouselOptions(
                                          autoPlay: false,
                                          enableInfiniteScroll: true,
                                          viewportFraction: 1.0,
                                        ),
                                        items: widget.post.sharedActivity!.mediaContentUrls!
                                            .map(
                                                (url) => Image.network(
                                              url,
                                              fit: BoxFit.fitHeight,
                                            )
                                        ).toList(),
                                      ),
                              ),
                            if (widget.post.sharedReward != null)
                              Container(
                                child: widget.post.sharedReward!.mediaContentUrls!.isEmpty
                                    ? Image.network(
                                  placeholderPostPicUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 220,
                                )
                                    : CarouselSlider(
                                  options: CarouselOptions(
                                    autoPlay: false,
                                    enableInfiniteScroll: true,
                                    viewportFraction: 1.0,
                                  ),
                                  items: widget.post.sharedReward!.mediaContentUrls!
                                      .map(
                                          (url) => Image.network(
                                        url,
                                        fit: BoxFit.fitHeight,
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
                                    widget.post.sharedActivity != null
                                        ? 'Activity: ${widget.post.sharedActivity!.name}'
                                        : 'Reward: ${widget.post.sharedReward!.name}',
                                    style: bodyTextStyleBold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5,),
                                  Text(
                                    'Description: ${widget.post.sharedActivity != null
                                        ? widget.post.sharedActivity!.description
                                        : widget.post.sharedReward!.description
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
                    ),
                  ),
          ), //assuming pictures only
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () async {
                        await handleLikePost();
                      }, //do like or unlike
                      icon: Icon(
                        Icons.thumb_up_alt_outlined,
                        color: this.hasDisliked ? null : this.hasLiked ? Colors.blue : null,),
                    ),
                    SizedBox(width: 5,),
                    Text('${this.numLikes}', style: bodyTextStyle,),
                  ],
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () async {
                        await handleDislikePost();
                      }, //do dislike or undislike
                      icon: Icon(
                        Icons.thumb_down_alt_outlined,
                        color: this.hasLiked ? null : this.hasDisliked ? Colors.red : null,
                      ),
                    ),
                    SizedBox(width: 5,),
                    Text('${this.numDislikes}', style: bodyTextStyle,),
                  ],
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () async {
                        if (!widget.isFullPost) {
                          var data = await Navigator.pushNamed(context, '/full-post', arguments: widget.post);
                        }
                      }, //view full posts with all comments
                      icon: Icon(Icons.chat_bubble_outline_rounded, color: Colors.amber,),
                    ),
                    SizedBox(width: 5,),
                    Text('${widget.post.numComments}', style: bodyTextStyle,),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getProfilePicUrl() {
    return widget.post.mpUser != null
        ? widget.post.mpUser!.profilePicUrl!
        : widget.post.organisation!.orgDisplayPicUrl!;
  }

  String getName() {
    return widget.post.mpUser != null
        ? '${widget.post.mpUser!.firstName} ${widget.post.mpUser!.lastName}'
        : widget.post.organisation!.name;
  }

  Future<void> handleLikePost() async {
    String message = '';
    try {
      message = await doLikePost();
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

  Future<String> doLikePost() async {
    var response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/post/${widget.post.postId}/like'),
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
      throw Exception('Error occured while liking a post');
    }
  }

  Future<void> handleDislikePost() async {
    String message = '';
    try {
      message = await doDislikePost();
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

  Future<String> doDislikePost() async {
    var response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/post/${widget.post.postId}/dislike')
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
      throw Exception('Error occured while disliking a post');
    }
  }

  VoidCallback postsModalBottomSheet(BuildContext context, String postId) {
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
                  onTap: () {}, //do report post here
                ),
              ],
            );
          }
      );
    };
  }
}
