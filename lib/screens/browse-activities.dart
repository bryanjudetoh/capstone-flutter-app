import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/models/activity.dart';
import 'package:loadmore/loadmore.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/widgets/featured-carousel.dart';

import '../constants.dart';

class InitBrowseActivitiesScreen extends StatelessWidget {
  InitBrowseActivitiesScreen({Key? key}) : super(key: key);

  final skip = 0;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    final activityType = ModalRoute.of(context)!.settings.arguments as String;
    return Container(
      color: Colors.white,
      child: FutureBuilder<Map<String, dynamic>>(
        future: initActivityData(activityType),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!;
            return BrowseActivitiesScreen(initActivitiesList: data['activityList'], activityType: activityType, featuredCarousel: data['featuredCarousel'],);
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

  Future<Map<String, dynamic>> initActivityData(String activityType) async {
    Map<String, dynamic> data = {};

    var response = await http.get(
        Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/list?actType=$activityType&skip=${skip.toString()}')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Activity> activityList = [];
      for (dynamic item in resultList) {
        Activity a = Activity.fromJson(Map<String, dynamic>.from(item));
        activityList.add(a);
      }

      data['activityList'] = activityList;

      data['featuredCarousel'] = await getFeaturedCarousel(activityType);

      return data;
    }
    else {
      String result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during your search');
    }
  }

  Future<FeaturedCarousel> getFeaturedCarousel(String activityType) async {
    return FeaturedCarousel(type: activityType);
  }

}


class BrowseActivitiesScreen extends StatefulWidget {
  BrowseActivitiesScreen({Key? key, required this.initActivitiesList, required this.activityType, required this.featuredCarousel}) {
    placeholderPicUrl = getPlaceholderPicUrl(activityType);
  }

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final List<Activity> initActivitiesList;
  final String activityType;
  final Widget featuredCarousel;
  late final String placeholderPicUrl;

  @override
  _BrowseActivitiesScreenState createState() => _BrowseActivitiesScreenState();
}

class _BrowseActivitiesScreenState extends State<BrowseActivitiesScreen> {

  late List<Activity> activities;
  late int skip;
  late bool isEndOfList;
  ScrollController activitiesScrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    isEndOfList = false;
    this.activities = widget.initActivitiesList;
    skip = activities.length;
    if (activities.length < backendSkipLimit) {
      isEndOfList = true;
    }
    this.activitiesScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    activitiesScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    activityTypeMap[widget.activityType]!,
                    style: titleOneTextStyleBold,
                  ),
                  Flexible(
                    child: SizedBox(width: 65),
                  )
                ],
              ),
              SizedBox(height: 10,),
              widget.featuredCarousel,
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: activities.length == 0 ? displayNoActivities() : displayBrowseActivities(),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _scrollListener() {
    if (activitiesScrollController.position.pixels == activitiesScrollController.position.maxScrollExtent && !isEndOfList) {
      print('========END OF LIST=========');
      loadMoreActivities();
    }
  }

  void loadMoreActivities() async {

    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/list?actType=${widget.activityType}&skip=${skip.toString()}')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);

      if (resultList.length > 0) {
        List<Activity> activityList = [];
        for (dynamic item in resultList) {
          activityList.add(Activity.fromJson(Map<String, dynamic>.from(item)));
        }

        setState(() {
          this.activities.addAll(activityList.where((a) => this.activities.every((b) => a.activityId != b.activityId)));
          skip += resultList.length;
        });
      }
      else {
        print('no more to add');
        setState(() {
          this.isEndOfList = true;
        });
      }
    }
    else {
      String result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while loading more activities for browse activities');
    }
  }

  Widget displayBrowseActivities() {
    return LoadMore(
        isFinish: isEndOfList,
        onLoadMore: _loadMore,
        textBuilder: DefaultLoadMoreTextBuilder.english,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: activities.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/activity-details', arguments: activities[index].activityId);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                                boxShadow: [
                                  if (activities[index].isBump!) BoxShadow(
                                    color: Colors.blueAccent,
                                    spreadRadius: -10,
                                    blurRadius: 22,
                                  ) else BoxShadow(color: Colors.white),
                                ]),
                            child: Card(
                              margin: EdgeInsets.only(
                                top: 10.0,
                                bottom: 10.0,
                              ),
                              elevation: 6.0,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                side: activities[index].isBump! ?
                                BorderSide(color: Colors.blueAccent, width: 2.0) : BorderSide.none,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    Image.network(
                                      activities[index].mediaContentUrls!.isEmpty
                                          ? widget.placeholderPicUrl
                                          : activities[index].mediaContentUrls![0],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                    Container(
                                      alignment: Alignment.bottomCenter,
                                      padding: EdgeInsets.only(
                                          left: 16, bottom: 16, right: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          begin: FractionalOffset.topCenter,
                                          end: FractionalOffset.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black54
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Currently ${activities[index].participantCount} have joined',
                                            style: TextStyle(
                                              //need to change to constant TextStyles
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                '${activities[index].activityRating}',
                                                style: TextStyle(
                                                  //need to change to constant TextStyles
                                                  fontFamily: 'Nunito',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (activities[index].isBump!)
                                      Container(
                                        alignment: Alignment.topRight,
                                        padding: EdgeInsets.only(right: 15, top: 10),
                                        child: Container(
                                          height: 25,
                                          width: 93,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
                                                spreadRadius: 3,
                                                blurRadius: 7,
                                              )
                                            ],
                                            borderRadius: BorderRadius.circular(12),
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 3),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(Icons.arrow_upward_outlined, color: Colors.blue,),
                                                    Text('Bumped',
                                                      style: TextStyle(
                                                        fontFamily: 'Rubik',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                           ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width*0.7,
                              child: Text(
                                '${activities[index].name}',
                                style: carouselActivityTitleTextStyle,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image(
                                  image: AssetImage(
                                      'assets/images/elixir.png'),
                                  height: 25,
                                  width: 25,
                                ),
                                Text('${activities[index].potions}',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF5EC8D8),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        ),
      );
  }

  Future<bool> _loadMore() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 500));
    loadMoreActivities();
    return true;
  }

  Widget displayNoActivities() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_sharp,
            size: 100,
          ),
          Text(
            'No activities for now... Stay tuned!',
            style: titleTwoTextStyleBold,
          ),
          SizedBox(height: 60,)
        ],
      ),
    );
  }
}
