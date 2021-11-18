import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:youthapp/models/friend-request.dart';
import 'package:youthapp/models/post.dart';
import 'package:youthapp/models/user.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/socialmedia-post.dart';

import '../constants.dart';

class InitSocialMediaScreenBody extends StatelessWidget {
  InitSocialMediaScreenBody({Key? key, required this.setNumUnreadNotifications}) : super(key: key);

  final Function setNumUnreadNotifications;
  final SecureStorage secureStorage = SecureStorage();
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: getUserDetails(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;
          return SocialMediaScreenBody(
            user: user,
            setNumUnreadNotifications: setNumUnreadNotifications,
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

  Future<User> getUserDetails() async {
    var response = await this.http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/user'),
    );

    if (response.statusCode == 200) {
      this.secureStorage.writeSecureData('user', response.body);
      var responseBody = jsonDecode(response.body);
      //print(responseBody);
      User user = User.fromJson(responseBody);

      return user;
    }
    else {
      var result = jsonDecode(response.body);
      print('get user details error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      throw Exception('A problem occured while retrieving your user details');
    }
  }
}


class SocialMediaScreenBody extends StatefulWidget {
  SocialMediaScreenBody({Key? key, required this.user, required this.setNumUnreadNotifications}) : super(key: key);

  final User user;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final Function setNumUnreadNotifications;

  @override
  _SocialMediaScreenBodyState createState() => _SocialMediaScreenBodyState();
}

class _SocialMediaScreenBodyState extends State<SocialMediaScreenBody> with TickerProviderStateMixin {

  bool currentTabIsPost = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance!.addPostFrameCallback((_) =>
        widget.setNumUnreadNotifications(widget.user.numUnreadNotifications));
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: false,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Social Media',
                            style: titleOneTextStyleBold,
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/search-friends');
                            },
                            icon: Icon(Icons.search),
                            iconSize: 30,
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  primary: this.currentTabIsPost ? kLightBlue : kBluishWhite,
                                ),
                                onPressed: () {
                                  setState(() {
                                    this.currentTabIsPost = true;
                                  });
                                },
                                child: Text(
                                  'Posts',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 17.0,
                                    height: 1.25,
                                    color: this.currentTabIsPost ? kWhite : kLightBlue,
                                  ),
                                )),
                          ),
                          SizedBox(width: 20,),
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  primary: this.currentTabIsPost ? kBluishWhite : kLightBlue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    this.currentTabIsPost = false;
                                  });
                                },
                                child: Text(
                                  'Friends',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 17.0,
                                    height: 1.25,
                                    color: this.currentTabIsPost ? kLightBlue : kWhite,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                expandedHeight: 160.0,
                bottom: TabBar(
                  unselectedLabelColor: Colors.blueGrey,
                  indicatorColor: kLightBlue,
                  labelColor: kLightBlue,
                  tabs: [
                    Tab(child: Text('${this.currentTabIsPost ? 'Feed' : 'My Friends'}', style: bodyTextStyle,)),
                    Tab(child: Text('${this.currentTabIsPost ? 'My Posts' : 'Requests'}', style: bodyTextStyle,)),
                  ],
                  controller: this.tabController,
                ),
              )
            ];
          },
          body: TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                child: this.currentTabIsPost
                    ? FutureBuilder<List<Post>>(
                        future: getInitialFeed(),
                        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
                          if (snapshot.hasData) {
                            List<Post> initialFeed = snapshot.data!;
                            return initialFeed.isNotEmpty
                                ? MyFeedBody(initialFeed: initialFeed, http: widget.http,)
                                : Center( child: Text('There is nothing on your feed for now', style: bodyTextStyle,),);
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
                        }
                      )
                    : FutureBuilder<List<User>>(
                          future: getInitialMyFriends(),
                          builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                            if (snapshot.hasData) {
                              List<User> initialMyFriends = snapshot.data!;
                              return initialMyFriends.isNotEmpty
                                  ? MyFriendsBody(initialFriends: initialMyFriends, http: widget.http,)
                                  : Center( child: Text('You have no friends', style: bodyTextStyle,),);
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
                          }
                      ),
              ),
              Container(
                child: this.currentTabIsPost
                    ? FutureBuilder<List<Post>>(
                        future: getInitialMyPosts(),
                        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
                          if (snapshot.hasData) {
                            List<Post> initialMyPosts = snapshot.data!;
                            return initialMyPosts.isNotEmpty
                                ? MyFeedBody(initialFeed: initialMyPosts, http: widget.http,)
                                : Center( child: Text('You haven\'t posted anything yet', style: bodyTextStyle,),);
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
                        }
                    )
                    : FutureBuilder<Map<String, dynamic>>(
                        future: loadRequestsTabData(),
                        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                          if (snapshot.hasData) {
                            Map<String, dynamic> data = snapshot.data!;
                            return RequestsBody(friendRequestsList: data['requests'], suggestedFriendsList: data['suggested'], http: widget.http,);
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
                        }
                    )
                ,
              ),
            ],
          ),
      ),
    );
  }
  
  Future<List<Post>> getInitialFeed() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/feed?skip=0'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Post> initialFeedList = [];
      // for (dynamic p in resultList) {
      //   print(p);
      // }
      initialFeedList.addAll(resultList.map((e) => Post.fromJson(Map<String,dynamic>.from(e))).toList());
      return initialFeedList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while loading initial feed posts');
    }
  }

  Future<List<Post>> getInitialMyPosts() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/profile?skip=0'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Post> initialMyPostsList = [];
      initialMyPostsList.addAll(resultList.map((p) => Post.fromJson(Map<String,dynamic>.from(p))).toList());
      return initialMyPostsList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while loading initial my posts');
    }
  }

  Future<List<User>> getInitialMyFriends() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/friend/list?name=&skip=0'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<User> initialMyFriends = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String,dynamic>.from(item);
        if (i['isFriend']) {
          initialMyFriends.add(User.fromJson(i));
        }
      }
      return initialMyFriends;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while loading initial my friends');
    }
  }

  Future<Map<String, dynamic>> loadRequestsTabData() async {
    Map<String, dynamic> data = {};
    data['requests'] = await getFriendRequests();
    data['suggested'] = await getSuggestedFriends();

    return data;
  }

  Future<List<FriendRequest>> getFriendRequests() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/friend/requestList'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<FriendRequest> friendRequestsList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        friendRequestsList.add(FriendRequest.fromJson(i));
      }
      return friendRequestsList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during loading initial friend requests');
    }
  }

  Future<List<User>> getSuggestedFriends() async {
    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/social-media/mp/friend/discover')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<User> suggestedFriendsList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        suggestedFriendsList.add(User.fromJson(i));
      }
      return suggestedFriendsList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during loading initial suggested friends');
    }
  }
}

class MyFeedBody extends StatefulWidget {
  const MyFeedBody({Key? key, required this.initialFeed, required this.http}) : super(key: key);
  
  final List<Post> initialFeed;
  final InterceptedHttp http;

  @override
  _MyFeedBodyState createState() => _MyFeedBodyState();
}

class _MyFeedBodyState extends State<MyFeedBody> {
  
  List<Post> feedList = [];
  late int skip;
  late bool isEndOfList;
  
  @override
  void initState() {
    super.initState();
    this.feedList.addAll(widget.initialFeed);
    this.skip = widget.initialFeed.length;
    this.isEndOfList = widget.initialFeed.length < backendSkipLimit ? true : false;
  }
  
  @override
  Widget build(BuildContext context) {
    return LoadMore(
      isFinish: isEndOfList,
      onLoadMore: loadMoreFeedPost,
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.builder(
        itemCount: this.feedList.length,
        itemBuilder: (BuildContext context, int index) {
          return SocialMediaPost(post: this.feedList[index], http: widget.http, isFullPost: false,);
        },
      ),
    );
  }
  
  Future<bool> loadMoreFeedPost() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/feed?skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      if (resultList.length > 0) {
        List<Post> feedList = [];
        feedList.addAll(resultList.map((e) => Post.fromJson(Map<String,dynamic>.from(e))).toList());
        setState(() {
          this.feedList.addAll(feedList);
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
}

class MyPostsBody extends StatefulWidget {
  const MyPostsBody({Key? key, required this.initialFeed, required this.http}) : super(key: key);

  final List<Post> initialFeed;
  final InterceptedHttp http;

  @override
  _MyPostsBodyState createState() => _MyPostsBodyState();
}

class _MyPostsBodyState extends State<MyPostsBody> {

  List<Post> myPostsList = [];
  late int skip;
  late bool isEndOfList;

  @override
  void initState() {
    super.initState();
    this.myPostsList.addAll(widget.initialFeed);
    this.skip = widget.initialFeed.length;
    this.isEndOfList = widget.initialFeed.length < backendSkipLimit ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return LoadMore(
      isFinish: isEndOfList,
      onLoadMore: loadMoreMyPosts,
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.builder(
        itemCount: this.myPostsList.length,
        itemBuilder: (BuildContext context, int index) {
          return SocialMediaPost(post: this.myPostsList[index], http: widget.http, isFullPost: false,);
        },
      ),
    );
  }

  Future<bool> loadMoreMyPosts() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me//api/social-media/mp/profile?skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      if (resultList.length > 0) {
        List<Post> myPostsList = [];
        myPostsList.addAll(resultList.map((e) => Post.fromJson(Map<String,dynamic>.from(e))).toList());
        setState(() {
          this.myPostsList.addAll(myPostsList);
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
}

class MyFriendsBody extends StatefulWidget {
  const MyFriendsBody({Key? key, required this.initialFriends, required this.http}) : super(key: key);

  final List<User> initialFriends;
  final InterceptedHttp http;

  @override
  _MyFriendsBodyState createState() => _MyFriendsBodyState();
}

class _MyFriendsBodyState extends State<MyFriendsBody> {

  List<User> myFriendsList = [];
  late int skip;
  late bool isEndOfList;

  @override
  void initState() {
    super.initState();
    this.myFriendsList.addAll(widget.initialFriends);
    this.skip = widget.initialFriends.length;
    this.isEndOfList = widget.initialFriends.length < backendSkipLimit ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return LoadMore(
      isFinish: isEndOfList,
      onLoadMore: loadMoreMyFriends,
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: this.myFriendsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                    myFriendsList[index].profilePicUrl!.isNotEmpty
                        ? myFriendsList[index].profilePicUrl!
                        : placeholderDisplayPicUrl
                ),
                maxRadius: 25,
              ),
              title: Text(
                '${myFriendsList[index].firstName} ${myFriendsList[index].lastName}',
                style: bodyTextStyle,
              ),
              onTap: () {
                Navigator.pushNamed(context, '/user-profile', arguments: myFriendsList[index].userId);
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool> loadMoreMyFriends() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/friend/list?name=&skip=${this.skip}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);

      if (resultList.length > 0) {
        List<User> myFriendsList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String,dynamic>.from(item);
          if (i['isFriend']) {
            myFriendsList.add(User.fromJson(i));
          }
        }
        setState(() {
          this.myFriendsList.addAll(myFriendsList);
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
}

class RequestsBody extends StatefulWidget {
  const RequestsBody({Key? key,
    required this.friendRequestsList,
    required this.suggestedFriendsList,
    required this.http
  }) : super(key: key);

  final List<FriendRequest> friendRequestsList;
  final List<User> suggestedFriendsList;
  final InterceptedHttp http;

  @override
  _RequestsBodyState createState() => _RequestsBodyState();
}

class _RequestsBodyState extends State<RequestsBody> {

  late List<FriendRequest> friendRequestsList;
  late List<User> suggestedFriendsList;

  @override
  void initState() {
    super.initState();
    this.friendRequestsList = widget.friendRequestsList;
    this.suggestedFriendsList = widget.suggestedFriendsList;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Requests',
              style: bodyTextStyleBold,
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox( height: 20, ),
          displayRequests(),
          SizedBox( height: 20, ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Suggested',
              style: bodyTextStyleBold,
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox( height: 20, ),
          displaySuggested(),
        ]
      ),
    );
  }

  Widget displayRequests() {
    if (this.friendRequestsList.isEmpty) {
      return Center(
        child: Text(
          'No pending friend requests',
          style: bodyTextStyle,
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: this.friendRequestsList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                            this.friendRequestsList[index].mpUser.profilePicUrl!.isNotEmpty
                                ? this.friendRequestsList[index].mpUser.profilePicUrl!
                                : placeholderDisplayPicUrl
                        ),
                        maxRadius: 25,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${this.friendRequestsList[index].mpUser.firstName} ${this.friendRequestsList[index].mpUser.lastName}',
                        style: bodyTextStyle,
                      ),
                    ]),
                    Row(
                      children: [
                        RawMaterialButton(
                          onPressed: () async {
                            String message = '';
                            try {
                              message = await respondToRequest(false, this.friendRequestsList[index].friendRequestId);
                            }
                            on Exception catch(err) {
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
                          },
                          fillColor: kBluishWhite,
                          child: Icon(
                            Icons.close_rounded,
                            color: kBlack,
                          ),
                          padding: EdgeInsets.all(10.0),
                          shape: CircleBorder(),
                        ),
                        RawMaterialButton(
                          onPressed: () async {
                            String message = '';
                            try {
                              message = await respondToRequest(true, this.friendRequestsList[index].friendRequestId);
                            }
                            on Exception catch(err) {
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
                          },
                          fillColor: kLightBlue,
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(10.0),
                          shape: CircleBorder(),
                        ),
                      ],
                    ),
                  ]
              ),
            )
        );
      },
    );
  }

  Widget displaySuggested() {
    if (this.suggestedFriendsList.isEmpty) {
      return Center(
        child: Text(
          'Participate in more activities to view your suggested friends list!',
          style: bodyTextStyle,
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: this.suggestedFriendsList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                  this.suggestedFriendsList[index].profilePicUrl!.isNotEmpty
                      ? this.suggestedFriendsList[index].profilePicUrl!
                      : placeholderDisplayPicUrl),
              maxRadius: 25,
            ),
            title: Text(
              '${this.suggestedFriendsList[index].firstName} ${this.suggestedFriendsList[index].lastName}',
              style: bodyTextStyle,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/user-profile', arguments: this.suggestedFriendsList[index].userId);
            },
          ),
        );
      },
    );
  }

  Future<String> respondToRequest(bool accept, String friendRequestId) async {
    var response = await widget.http.put(Uri.parse(
        'https://eq-lab-dev.me/api/social-media/mp/friend/respond-friend-request/$friendRequestId?accept=${accept.toString()}'));

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      print(result);
      setState(() {
        this.friendRequestsList.removeWhere((fr) => fr.friendRequestId == friendRequestId);
      });
      return accept ? 'Successfully accepted friend request' : 'Successfully rejected friend request';
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
      throw Exception('A problem occurred while responding to this friend request');
    }
  }
}
