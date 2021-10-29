import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

import '../constants.dart';

class SocialMediaScreenBody extends StatefulWidget {
  const SocialMediaScreenBody({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _SocialMediaScreenBodyState createState() => _SocialMediaScreenBodyState();
}

class _SocialMediaScreenBodyState extends State<SocialMediaScreenBody>
    with TickerProviderStateMixin {
  bool currentTabIsPost = true;
  late TabController tabController;

  int skip = 0;
  bool isEndOfList = false;
  final String placeholderProfilePicUrl = placeholderDisplayPicUrl;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
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
                    SizedBox(
                      height: 10,
                    ),
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
                                primary: this.currentTabIsPost
                                    ? kLightBlue
                                    : kBluishWhite,
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
                                  color: this.currentTabIsPost
                                      ? kWhite
                                      : kLightBlue,
                                ),
                              )),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                ),
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                primary: this.currentTabIsPost
                                    ? kBluishWhite
                                    : kLightBlue,
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
                                  color: this.currentTabIsPost
                                      ? kLightBlue
                                      : kWhite,
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
                  Tab(
                      child: Text(
                    '${this.currentTabIsPost ? 'Feed' : 'My Friends'}',
                    style: bodyTextStyle,
                  )),
                  Tab(
                      child: Text(
                    '${this.currentTabIsPost ? 'My Posts' : 'Requests'}',
                    style: bodyTextStyle,
                  )),
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
                  ? Center(
                      child: Text(
                        'This is Feed',
                        style: bodyTextStyle,
                      ),
                    )
                  : Center(
                      child: FutureBuilder<List<User>>(
                        future: loadFriends(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<User>> snapshot) {
                          if (snapshot.hasData) {
                            List<User> data = snapshot.data!;
                            if (data.length > 0) {
                              return displayMyFriends(data);
                            } else {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sentiment_dissatisfied_sharp,
                                      size: 70,
                                    ),
                                    Text(
                                      'You do not have any friends!',
                                      style: titleThreeTextStyle,
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else if (snapshot.hasError) {
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
                          } else {
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
                    ),
            ),
            Container(
              child: this.currentTabIsPost
                  ? Center(
                      child: Text(
                        'This is My Posts',
                        style: bodyTextStyle,
                      ),
                    )
                  : Center(
                      child: Column(children: [
                        Container(
                          height: 200,
                          child: FutureBuilder<List<dynamic>>(
                            future: loadRequests(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<dynamic>> snapshot) {
                              if (snapshot.hasData) {
                                List<dynamic> data = snapshot.data!;
                                if (data.length > 0) {
                                  return displayRequests(data);
                                } else {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sentiment_dissatisfied_sharp,
                                          size: 70,
                                        ),
                                        Text(
                                          'You do not have any friend requests!',
                                          style: titleThreeTextStyle,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(children: [
                          SizedBox(
                            width: 10,
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Suggested',
                                style: bodyTextStyleBold,
                                textAlign: TextAlign.left,
                              )),
                        ]),
                        SizedBox(
                          height: 2,
                        ),
                        Container(
                          height: 230,
                          child: FutureBuilder<List<dynamic>>(
                            future: loadSuggested(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<dynamic>> snapshot) {
                              if (snapshot.hasData) {
                                List<dynamic> data = snapshot.data!;
                                if (data.length > 0) {
                                  return displaySuggested(data);
                                } else {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sentiment_dissatisfied_sharp,
                                          size: 70,
                                        ),
                                        Text(
                                          'You do not have any suggested friends!',
                                          style: titleThreeTextStyle,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
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
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
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
                        ),
                      ]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> loadSuggested() async {
    final http = InterceptedHttp.build(
      interceptors: [
        AuthHeaderInterceptor(),
      ],
      retryPolicy: RefreshTokenRetryPolicy(),
    );

    var response = await http.get(
        Uri.parse('https://eq-lab-dev.me/api/social-media/mp/friend/discover')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<User> userList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        userList.add(User.fromJson(i));
      }
      return userList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during your user search');
    }
  }

  ListView displaySuggested(List<dynamic> userList) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: userList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                  userList[index].profilePicUrl!.isNotEmpty
                      ? userList[index].profilePicUrl!
                      : this.placeholderProfilePicUrl),
              maxRadius: 25,
            ),
            title: Text(
              '${userList[index].firstName} ${userList[index].lastName}',
              style: bodyTextStyle,
            ),
          ),
        );
      },
    );
  }

  Future<List<dynamic>> loadRequests() async {
    final http = InterceptedHttp.build(
      interceptors: [
        AuthHeaderInterceptor(),
      ],
      retryPolicy: RefreshTokenRetryPolicy(),
    );

    var response = await http.get(Uri.parse(
        'https://eq-lab-dev.me/api/social-media/mp/friend/requestList'));

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      return resultList;
    } else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred when loading your requests');
    }
  }

  ListView displayRequests(List<dynamic> requestsList) {
    late ScrollController requestsScrollController;
    requestsScrollController = ScrollController();

    List<User> userList = [];

    for (dynamic item in requestsList) {
      Map<String, dynamic> i = Map<String, dynamic>.from(item);
      userList.add(User.fromJson(i['mpUser']));
    }

    return ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                controller: requestsScrollController,
                itemCount: userList.length,
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
                                      userList[index].profilePicUrl!.isNotEmpty
                                          ? userList[index].profilePicUrl!
                                          : this.placeholderProfilePicUrl),
                                  maxRadius: 25,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${userList[index].firstName} ${userList[index].lastName}',
                                  style: bodyTextStyle,
                                ),
                              ]),
                              Row(children: [
                                RawMaterialButton(
                                  onPressed: () {},
                                  fillColor: kBluishWhite,
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: kBlack,
                                  ),
                                  padding: EdgeInsets.all(10.0),
                                  shape: CircleBorder(),
                                ),
                                RawMaterialButton(
                                  onPressed: () {},
                                  fillColor: kLightBlue,
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(10.0),
                                  shape: CircleBorder(),
                                ),
                              ])
                            ]),
                      ));
                },
              ),
            ],
          );
        });
  }

  void respondToRequest(bool accept, String friendRequestId) {}

  Future<List<User>> loadFriends() async {
    final http = InterceptedHttp.build(
      interceptors: [
        AuthHeaderInterceptor(),
      ],
      retryPolicy: RefreshTokenRetryPolicy(),
    );

    var response = await http.get(Uri.parse(
        'https://eq-lab-dev.me/api/social-media/mp/friend/list?name=&skip=${this.skip}'));

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<User> userList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        print(i['isFriend']);
        if (i['isFriend'] == true) {
          userList.add(User.fromJson(i));
        }
      }
      setState(() {
        this.skip += resultList.length;
        if (resultList.length < backendSkipLimit) {
          isEndOfList = true;
        }
      });
      return userList;
    } else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred when loading your friends');
    }
  }

  ListView displayMyFriends(List<User> myFriendsList) {
    late ScrollController myFriendsScrollController;

    myFriendsScrollController = ScrollController();

    return ListView.builder(
      shrinkWrap: true,
      controller: myFriendsScrollController,
      itemCount: myFriendsList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                  myFriendsList[index].profilePicUrl!.isNotEmpty
                      ? myFriendsList[index].profilePicUrl!
                      : this.placeholderProfilePicUrl),
              maxRadius: 25,
            ),
            title: Text(
              '${myFriendsList[index].firstName} ${myFriendsList[index].lastName}',
              style: bodyTextStyle,
            ),
            onTap: () {
              print('tapped userId: ${myFriendsList[index].userId}');
              Map<String, dynamic> data = {};
              data['userId'] = myFriendsList[index].userId;
              data['isFriend'] = myFriendsList[index].isFriend;
              Navigator.pushNamed(context, '/user-profile', arguments: data);
            },
          ),
        );
      },
    );
  }
}
