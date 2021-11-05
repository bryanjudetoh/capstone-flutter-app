import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:youthapp/models/post.dart';
import 'package:youthapp/models/user.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youthapp/widgets/socialmedia-post.dart';

import '../constants.dart';

class InitUserProfileScreen extends StatelessWidget {
  InitUserProfileScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    final String userId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<User>(
        future: initUserProfileData(userId),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.hasData) {
            User user = snapshot.data!;
            return UserProfileScreen(user: user, isFriend: user.isFriend!, http: this.http,);
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

  Future<User> initUserProfileData(String userId) async {
    var response = await this.http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/user/$userId'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return User.fromJson(responseBody);
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception(result['error']['message']);
    }
  }
}

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({Key? key, required this.user, required this.isFriend, required this.http}) : super(key: key);

  final User user;
  final bool isFriend;
  final placeholderUserProfilePicUrl = placeholderDisplayPicUrl;
  final InterceptedHttp http;

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: false,
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {Navigator.of(context).pop();},
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
                              AppLocalizations.of(context)!.profile,
                              style: titleOneTextStyleBold,
                            ),
                            Flexible(
                              child: SizedBox(width: 65),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10.0),
                              margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 10, // changes position of shadow
                                    ),
                                  ]),
                              child: Column(children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          widget.user.profilePicUrl!.isNotEmpty ?
                                          widget.user.profilePicUrl! : widget.placeholderUserProfilePicUrl
                                      ),
                                      maxRadius: 50,
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "${widget.user.firstName} ${widget.user.lastName}",
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: bodyTextStyleBold,
                                          ),
                                          Text(
                                            '${widget.user.school}',
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: captionTextStyle,
                                          ),
                                          Text(
                                            '${widget.user.city}',
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: captionTextStyle,
                                          ),
                                          Text(
                                            'Born on ${dateFormat.format(widget.user.dob!.toLocal())}',
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: captionTextStyle,
                                          ),
                                          Text(
                                            '${widget.user.email}',
                                            overflow: TextOverflow.ellipsis,
                                            style: captionTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Image(
                                            image: AssetImage(
                                                'assets/images/elixir.png'),
                                            height: 40,
                                            width: 40,
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                'Equity Score',
                                                style: captionTextStyle,
                                              ),
                                              Text(
                                                '${widget.user.potionBalance!.values.reduce((a, b) => a + b)}',
                                                style: bodyTextStyleBold,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(children: <Widget>[
                                        Text(
                                          'Friends',
                                          style: captionTextStyle,
                                        ),
                                        Text(
                                          '${widget.user.numFriends}',
                                          style: bodyTextStyleBold,
                                        ),
                                      ])
                                    ])
                              ]),
                            ),
                            if (widget.isFriend)
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 30, top: 5),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      icon: Icon(Icons.more_vert),
                                      items: [
                                        DropdownMenuItem(
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.person_remove),
                                              SizedBox(width: 8),
                                              Text('Unfriend', style: smallBodyTextStyle),
                                            ],
                                          ),
                                          value: 'Unfriend',
                                        ),
                                      ],
                                      onChanged: (_) async {
                                        await handleUnfriend();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ]
                        ),
                      ],
                    ),
                  ),
                  expandedHeight: 280,
                )
              ];
            },
            body: widget.isFriend
                ? InitProfileFeed(userId: widget.user.userId,)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Add ${widget.user.firstName} ${widget.user.lastName} as a friend to view their posts',
                          style: titleThreeTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20,),
                        ElevatedButton(
                          onPressed: handleAddFriend,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.person_add, color: Colors.white, size: 30,),
                              SizedBox(width: 10,),
                              Text(
                                'Add Friend',
                                style: TextStyle(
                                  fontFamily: 'SF Display Pro',
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15.0),
                            ),
                            onPrimary: kLightBlue,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          ),
                        ),
                        SizedBox(height: 60,),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleUnfriend() async {
    String message = '';
    try {
      message = await doUnfriend();
      Navigator.pop(context);
      Navigator.pushNamed(context, '/user-profile', arguments: widget.user.userId);
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

  Future<String> doUnfriend() async {
    var response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/friend/unfriend/${widget.user.userId}'),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['message'];
    }
    else if (response.statusCode == 400 || response.statusCode == 404) {
      var result = jsonDecode(response.body);
      print(result);
      return result['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print('status code: ${response.statusCode}');
      print(result);
      throw Exception('A problem occured while adding friend (id: ${widget.user.userId})');
    }
  }

  Future<void> handleAddFriend() async {
    String message = '';
    try {
      message = await doAddFriend();
    }
    on Exception catch (err) {
      message = err.toString();
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

  Future<String> doAddFriend() async {
    var response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/friend/send-request/${widget.user.userId}'),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['message'];
    }
    else if (response.statusCode == 400 || response.statusCode == 404) {
      var result = jsonDecode(response.body);
      print(result);
      return result['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while adding friend (id: ${widget.user.userId})');
    }
  }
}

class InitProfileFeed extends StatelessWidget {
  InitProfileFeed({Key? key, required this.userId}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final String userId;
  final int skip = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: getProfileFeed(),
      builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
        if (snapshot.hasData) {
          List<Post> list = snapshot.data!;
          return ProfileFeed(initialPostList: list, userId: this.userId,);
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
    );
  }

  Future<List<Post>> getProfileFeed() async {
    var response = await this.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/profile/${this.userId}?skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Post> postList = [];
      for (dynamic item in resultList) {
        Post p = Post.fromJson(Map<String, dynamic>.from(item));
        postList.add(p);
      }
      return postList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while loading this profile\'s social media feed');
    }
  }
}


class ProfileFeed extends StatefulWidget {
  ProfileFeed({Key? key, required this.initialPostList, required this.userId}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final List<Post> initialPostList;
  final String userId;

  @override
  _ProfileFeedState createState() => _ProfileFeedState();
}

class _ProfileFeedState extends State<ProfileFeed> {
  List<Post> profileFeed = [];
  late int skip;
  late bool isEndOfList;

  @override
  void initState() {
    super.initState();
    this.profileFeed = widget.initialPostList;
    this.skip = this.profileFeed.length;
    this.isEndOfList = this.profileFeed.length < backendSkipLimit ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.initialPostList.isNotEmpty
          ? displayProfileFeed()
          : displayEmptyProfileFeed(),
    );
  }

  Future<bool> _loadMore() async {
    //await Future.delayed(Duration(seconds: 0, milliseconds: 500));
    return await loadMorePosts();
  }

  Future<bool> loadMorePosts() async {
    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/social-media/mp/profile/${widget.userId}?skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      if (resultList.length > 0) {
        List<Post> postList = [];
        for (dynamic item in resultList) {
          Post p = Post.fromJson(Map<String, dynamic>.from(item));
          postList.add(p);
        }
        setState(() {
          this.profileFeed.addAll(postList);
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

  Widget displayEmptyProfileFeed() {
    return Container(
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.sentiment_dissatisfied_sharp,
            size: 100,
          ),
          SizedBox(height: 20,),
          Text('No posts for now... Stay tuned!', style: titleThreeTextStyle,),
          SizedBox(height: 60,),
        ],
      ),
    );
  }

  Widget displayProfileFeed() {
    return LoadMore(
      isFinish: isEndOfList,
      onLoadMore: _loadMore,
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.builder(
        itemCount: this.profileFeed.length,
        itemBuilder: (BuildContext context, int index) {
          return SocialMediaPost(post: this.profileFeed[index], http: widget.http, isFullPost: false,);
        },
      ),
    );
  }
}
