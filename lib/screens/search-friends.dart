import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

import '../constants.dart';

class SearchFriendsScreen extends StatefulWidget {
  SearchFriendsScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final String placeholderProfilePicUrl = placeholderDisplayPicUrl;

  @override
  _SearchFriendsScreenState createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
  List<User> searchUsersResultList = [];
  String currentQuery = '';
  int skip = 0;
  bool isEndOfList = false;
  late ScrollController searchbarScrollController;
  late ScrollController usersScrollController;

  @override
  void initState() {
    super.initState();
    this.searchbarScrollController = ScrollController();
    this.usersScrollController = ScrollController();
    this.searchbarScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    this.searchbarScrollController.dispose();
    this.usersScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: buildFloatingSearchBar(),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search for users...',
      clearQueryOnClose: false,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      height: 65,
      debounceDelay: const Duration(milliseconds: 500),
      transition: CircularFloatingSearchBarTransition(),
      scrollController: this.searchbarScrollController,
      onFocusChanged: (isFocused) {
        if (!isFocused) {
          setState(() {
            this.searchUsersResultList = [];
            this.skip = 0;
            this.isEndOfList = false;
          });
        }
      },
      onQueryChanged: (query) async {
        setState(() {
          this.currentQuery = query;
          this.skip = 0;
          this.isEndOfList = false;
        });
        List<User> result = await performUsersQuery(query);
        setState(() {
          this.searchUsersResultList = result;
        });
      },
      onSubmitted: (query) async {
        setState(() {
          this.currentQuery = query;
          this.skip = 0;
          this.isEndOfList = false;
        });
        List<User> result = await performUsersQuery(query);
        setState(() {
          this.searchUsersResultList = result;
        });
      },
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: displaySearchResultList(),
          ),
        );
      },
    );
  }

  void _scrollListener() {
    if (searchbarScrollController.position.pixels == searchbarScrollController.position.maxScrollExtent && !isEndOfList) {
      loadMoreUsers();
    }
  }

  void loadMoreUsers() async {
    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/social-media/mp/friend/list?name=${this.currentQuery}&skip=${this.skip}')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);

      if (resultList.length > 0) {
        List<User> userList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String, dynamic>.from(item);
          print(i);
          userList.add(User.fromJson(i['mpUser']));
        }
        setState(() {
          this.searchUsersResultList.addAll(userList);
          this.skip += userList.length;
        });
      }
      else {
        setState(() {
          this.isEndOfList = true;
        });
      }
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while loading more users for search results');
    }
  }

  Future<List<User>> performUsersQuery(String query) async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/friend/list?name=$query&skip=${this.skip}')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<User> userList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        userList.add(User.fromJson(i));
      }
      setState(() {
        this.skip += resultList.length;
        if (resultList.length < backendSkipLimit) {
          isEndOfList = true;
        }
      });
      return userList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during your user search');
    }
  }

  ListView displaySearchResultList() {
    return ListView.builder(
      shrinkWrap: true,
      controller: this.usersScrollController,
      itemCount: this.searchUsersResultList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                  searchUsersResultList[index].profilePicUrl!.isNotEmpty ?
                  searchUsersResultList[index].profilePicUrl! : widget.placeholderProfilePicUrl
              ),
              maxRadius: 25,
            ),
            title: Text(
              '${searchUsersResultList[index].firstName} ${searchUsersResultList[index].lastName}',
              style: bodyTextStyle,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/user-profile', arguments: searchUsersResultList[index].userId);
            },
          ),
        );
      },
    );
  }
}
