import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/models/post.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youthapp/widgets/socialmedia-post.dart';

class InitOrganisationDetailsScreen extends StatelessWidget {
  InitOrganisationDetailsScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    final String orgId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Organisation>(
        future: initOrganisationData(orgId),
        builder: (BuildContext context, AsyncSnapshot<Organisation> snapshot) {
          if (snapshot.hasData) {
            Organisation org = snapshot.data!;
            return OrganisationDetailsScreen(org: org, http: this.http,);
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
    );
  }

  Future<Organisation> initOrganisationData(String orgId) async {
    final response = await http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/org/' + orgId),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      return Organisation.fromJson(responseBody);
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}

class OrganisationDetailsScreen extends StatefulWidget {
  const OrganisationDetailsScreen({Key? key, required this.org, required this.http})
      : super(key: key);

  final Organisation org;
  final placeholderOrgProfilePicUrl = placeholderDisplayPicUrl;
  final InterceptedHttp http;

  @override
  _OrganisationDetailsScreenState createState() =>
      _OrganisationDetailsScreenState();
}

class _OrganisationDetailsScreenState extends State<OrganisationDetailsScreen> {

  late bool isFollowing;

  @override
  void initState() {
    super.initState();
    this.isFollowing = widget.org.isFollowing != null ? widget.org.isFollowing! : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                              AppLocalizations.of(context)!.organisationDetails,
                              style: titleOneTextStyleBold,
                            ),
                            Flexible(
                              child: SizedBox(width: 65),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                        widget.org.orgDisplayPicUrl!.isNotEmpty ?
                                        widget.org.orgDisplayPicUrl! : widget.placeholderOrgProfilePicUrl
                                    ),
                                    maxRadius: 50,
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.6,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${widget.org.name}',
                                          style: titleTwoTextStyleBold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '${widget.org.email}',
                                          style: subtitleTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${widget.org.website}',
                                          style: subtitleTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Country code: ${widget.org.countryCode}',
                                          style: captionTextStyle,
                                        ),
                                        SizedBox(height: 5,),
                                        Text(
                                          'Categories: ${widget.org.orgTags!.isNotEmpty ? widget.org.orgTags.toString().substring(1, widget.org.orgTags.toString().length -1) : 'None'}',
                                          style: captionTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: handleFollowButton,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        if (!this.isFollowing)
                                          Icon(
                                          Icons.group_add,
                                          color: this.isFollowing ? kLightBlue : Colors.white,
                                          size: 30,
                                        ),
                                        SizedBox(width: 10,),
                                        Text(
                                          this.isFollowing ? 'Unfollow' : 'Follow',
                                          style: TextStyle(
                                            fontFamily: 'SF Display Pro',
                                            fontSize: 24,
                                            color: this.isFollowing ? Colors.blue : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(15.0),
                                      ),
                                      primary: this.isFollowing ? kGrey : Colors.blue,
                                      padding: EdgeInsets.fromLTRB(20, 10, 30, 10),
                                    ),
                                  ),
                                ],
                              ),
                            ])
                      ],
                    ),
                  ),
                  expandedHeight: 280,
                )
              ];
            },
            body: InitOrganisationFeed(orgId: widget.org.organisationId,),
          ),
        ),
      ),
    );
  }

  Future<void> handleFollowButton() async {
    String message = '';
    try{
      if (this.isFollowing) {
        message = await doUnfollowOrg();
        setState(() {
          this.isFollowing = false;
        });
      }
      else {
        message = await doFollowOrg();
        setState(() {
          this.isFollowing = true;
        });
      }
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
          duration: const Duration(seconds: 2),
        )
    );
  }

  Future<String> doFollowOrg() async {
    var response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/follow-organisation/${widget.org.organisationId}'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return responseBody['message'];
    }
    else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      return result['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print('status code: ${response.statusCode}');
      print(result);
      throw Exception('A problem occured while following this organisation (id: ${widget.org.organisationId})');
    }
  }

  Future<String> doUnfollowOrg() async {
    var response = await widget.http.put(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/unfollow-organisation/${widget.org.organisationId}'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return responseBody['message'];
    }
    else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      return result['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print('status code: ${response.statusCode}');
      print(result);
      throw Exception('A problem occured while unfollowing this organisation (id: ${widget.org.organisationId})');
    }
  }
}

class InitOrganisationFeed extends StatelessWidget {
  InitOrganisationFeed({Key? key, required this.orgId}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final String orgId;
  final int skip = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: getOrganisationFeed(),
      builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
        if (snapshot.hasData) {
          List<Post> list = snapshot.data!;
          return OrganisationFeed(initialPostList: list, orgId: this.orgId, http: this.http);
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

  Future<List<Post>> getOrganisationFeed() async {
    var response = await this.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/profile-org/${this.orgId}?skip=${this.skip}'),
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
      print('status code: ${response.statusCode}');
      print(result);
      throw Exception('A problem occured while loading this organisation\'s social media feed');
    }
  }
}

class OrganisationFeed extends StatefulWidget {
  const OrganisationFeed({Key? key, required this.initialPostList, required this.orgId, required this.http}) : super(key: key);

  final InterceptedHttp http;
  final List<Post> initialPostList;
  final String orgId;

  @override
  _OrganisationFeedState createState() => _OrganisationFeedState();
}

class _OrganisationFeedState extends State<OrganisationFeed> {
  List<Post> orgFeed = [];
  late int skip;
  late bool isEndOfList;

  @override
  void initState() {
    super.initState();
    this.orgFeed = widget.initialPostList;
    this.skip = this.orgFeed.length;
    this.isEndOfList = this.orgFeed.length < backendSkipLimit ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.initialPostList.isNotEmpty
          ? displayOrgFeed()
          : displayEmptyOrgFeed(),
    );
  }

  Future<bool> _loadMore() async {
    //await Future.delayed(Duration(seconds: 0, milliseconds: 500));
    return await loadMorePosts();
  }

  Future<bool> loadMorePosts() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/profile-org/${widget.orgId}?skip=${this.skip}'),
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
          this.orgFeed.addAll(postList);
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

  Widget displayEmptyOrgFeed() {
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

  Widget displayOrgFeed() {
    return LoadMore(
      isFinish: isEndOfList,
      onLoadMore: _loadMore,
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.builder(
        itemCount: this.orgFeed.length,
        itemBuilder: (BuildContext context, int index) {
          return SocialMediaPost(post: this.orgFeed[index], http: widget.http, isFullPost: false,);
        },
      ),
    );
  }
}
