import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/painting.dart';
import 'package:youthapp/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youthapp/models/activity.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

class ActivitiesCarousel extends StatefulWidget {
  ActivitiesCarousel({
    Key? key,
    required this.title,
    required this.type,
    required this.seeAllFunc,
  }) {
    placeholderPicUrl = getPlaceholderPicUrl(type);
  }

  final String title;
  final String type;
  final VoidCallback seeAllFunc;
  late final String placeholderPicUrl;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _ActivitiesCarouselState createState() => _ActivitiesCarouselState();
}

class _ActivitiesCarouselState extends State<ActivitiesCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              widget.title,
              style: titleThreeTextStyleBold,
            ),
            TextButton(
              onPressed: widget.seeAllFunc,
              child: Row(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.seeMore,
                    style: smallBodyTextStyleBold,
                  ),
                  Icon(Icons.navigate_next_rounded),
                ],
              ),
            ),
          ],
        ),
        FutureBuilder<List<Activity>>(
          future: getFeaturedActivityList(widget.type),
          builder:
              (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
            if (snapshot.hasData) {
              List<Activity> activityList = snapshot.data!;
              if (activityList.length > 0) {
                return Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: false,
                        enableInfiniteScroll: false,
                        // enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(
                                () {
                              _currentIndex = index;
                            },
                          );
                        },
                      ),
                      items: activityList
                          .map(
                            (item) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/activity-details', arguments: item.activityId);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: Container (
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30.0),
                                      ),
                                      boxShadow: [
                                      BoxShadow(
                                        color: Colors.amberAccent,
                                        spreadRadius: -10,
                                        blurRadius: 22,
                                      ),
                                    ]),
                                    child: Card(
                                      margin: EdgeInsets.only(
                                        top: 10.0,
                                        bottom: 10.0,
                                      ),
                                      elevation: 6.0,
                                      shadowColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.amberAccent, width: 2.0),
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30.0),
                                        ),
                                        child: Stack(
                                          children: <Widget>[
                                            Image.network(
                                              item.mediaContentUrls!.isEmpty
                                                  ? widget.placeholderPicUrl
                                                  : item.mediaContentUrls![0],
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
                                                    'Currently ${item.participantCount} have joined',
                                                    style: TextStyle(
                                                      //need to change to constant TextStyles
                                                      fontFamily: 'Nunito',
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16.0,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        '${item.activityRating}',
                                                        style: TextStyle(
                                                          //need to change to constant TextStyles
                                                          fontFamily: 'Nunito',
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16.0,
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
                                              )
                                            ),
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
                                                  color: Colors.amberAccent,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 4),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: <Widget>[
                                                          Icon(Icons.star_outlined, color: Colors.white,),
                                                          Text('Featured',
                                                            style: captionTextStyle,
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
                                      width: MediaQuery.of(context).size.width*0.55,
                                      child: Text(
                                        '${item.name}',
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
                                              '${activityTypeToPotionColorPathMap[item.type]}'),
                                          height: 25,
                                          width: 25,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top:3),
                                          child: Text('${item.potions}',
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: Color(0xFF5EC8D8),
                                            ),
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
                      )
                          .toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: activityList.map((urlOfItem) {
                        int index = activityList.indexOf(urlOfItem);
                        return Container(
                          width: 10.0,
                          height: 10.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? Color.fromRGBO(0, 0, 0, 0.8)
                                : Color.fromRGBO(0, 0, 0, 0.3),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }
              return Container();
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: titleThreeTextStyleBold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }

  Future<List<Activity>> getFeaturedActivityList(String type) async {
    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/activity/featured/list?actType=$type')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Map<String, dynamic>> mapList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        mapList.add(i);
      }
      List<Activity> activityResultList = mapList.map((act) => Activity.fromJson(act)).toList();

      return activityResultList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during intialising activity data');
    }
  }
}
