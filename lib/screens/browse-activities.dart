import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class InitBrowseActivitiesScreen extends StatelessWidget {
  InitBrowseActivitiesScreen({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();
  final skip = 0;

  @override
  Widget build(BuildContext context) {
    final activityType = ModalRoute.of(context)!.settings.arguments as String;
    return FutureBuilder<List<Activity>>(
      future: initActivityData(activityType),
      builder: (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
        if (snapshot.hasData) {
          List<Activity> activities = snapshot.data!;
          return BrowseActivitiesScreen(initActivitiesList: activities, activityType: activityType,);
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

  Future<List<Activity>> initActivityData(String activityType) async {

    final String accessToken = await secureStorage.readSecureData('accessToken');

    var request = http.Request('GET',
        Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/list?actType=$activityType&skip=${skip.toString()}'));
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();

      List<dynamic> resultList = jsonDecode(result);
      List<Activity> activityList = [];
      for (dynamic item in resultList) {
        activityList.add(Activity.fromJson(Map<String, dynamic>.from(item)));
      }

      return activityList;
    }
    else {
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occurred during your search');
    }
  }
}


class BrowseActivitiesScreen extends StatefulWidget {
  BrowseActivitiesScreen({Key? key, required this.initActivitiesList, required this.activityType}) : super(key: key);

  final List<Activity> initActivitiesList;
  final String activityType;
  final SecureStorage secureStorage = SecureStorage();
  final String placeholderPicUrl = 'https://media.gettyimages.com/photos/in-this-image-released-on-may-13-marvel-shang-chi-super-hero-simu-liu-picture-id1317787772?s=612x612';

  @override
  _BrowseActivitiesScreenState createState() => _BrowseActivitiesScreenState();
}

class _BrowseActivitiesScreenState extends State<BrowseActivitiesScreen> {

  late List<Activity> activities;
  int skip = 0;
  late bool isEndOfList;
  ScrollController activitiesScrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    isEndOfList = false;
    this.activities = widget.initActivitiesList;
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
              Expanded(
                child: activities.length == 0 ? displayNoActivities() : displayBrowseActivities(),
              ),
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
    final String accessToken = await widget.secureStorage.readSecureData('accessToken');

    var request = http.Request('GET',
        Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/list?actType=${widget.activityType}&skip=${skip.toString()}')
    );
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      List<dynamic> resultList = jsonDecode(result);

      if (resultList.length > 0) {
        List<Activity> activityList = [];
        for (dynamic item in resultList) {
          activityList.add(Activity.fromJson(Map<String, dynamic>.from(item)));
        }

        setState(() {
          this.activities.addAll(activityList);
          skip = this.activities.length;
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
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occured while loading more activities for search results');
    }
  }

  ListView displayBrowseActivities() {
    return ListView.builder(
        controller: activitiesScrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
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
                      child: Card(
                        margin: EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        elevation: 6.0,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
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
                                alignment: Alignment.bottomLeft,
                                padding: EdgeInsets.only(
                                    left: 16, bottom: 16),
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
                                child: Text(
                                  'Currently ${activities[index].participantCount} have joined',
                                  style: TextStyle(
                                    //need to change to constant TextStyles
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '${activities[index].name}',
                          style: carouselActivityTitleTextStyle,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
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
    );
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
