import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youthapp/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:http/http.dart' as http;

class ActivitiesCarousel extends StatefulWidget {
  const ActivitiesCarousel({
    Key? key,
    required this.title,
    required this.type,
    required this.seeAllFunc,
  }) : super(key: key);

  final String title;
  final String type;
  final VoidCallback seeAllFunc;
  final String placeholderPicUrl =
      'https://media.gettyimages.com/photos/in-this-image-released-on-may-13-marvel-shang-chi-super-hero-simu-liu-picture-id1317787772?s=612x612';

  @override
  _ActivitiesCarouselState createState() => _ActivitiesCarouselState();
}

class _ActivitiesCarouselState extends State<ActivitiesCarousel> {
  int _currentIndex = 0;
  SecureStorage secureStorage = new SecureStorage();

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
              return Column(
                children: [
                  if (activityList.length > 0)
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
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  print('tapped');
                                },
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
                                          //need to change to Image.network, where item = url string
                                          item.mediaContentUrls!.isEmpty
                                              ? widget.placeholderPicUrl
                                              : item.mediaContentUrls![0],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                            '${item.name}',
                                            style: TextStyle(
                                              //need to change to constant TextStyles
                                              fontFamily: 'SF Display Pro',
                                              fontSize: 16.0,
                                              backgroundColor: Colors.black45,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 20,
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Loading...',
                        style: titleThreeTextStyleBold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              );
            }
          },
        )
      ],
    );
  }

  Future<List<Activity>> getFeaturedActivityList(String type) async {
    final String accessToken =
        await secureStorage.readSecureData('accessToken');

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://eq-lab-dev.me/api/activity-svc/mp/activity/featured/list?actType=' +
                type));
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(jsonDecode(result));

      List<dynamic> resultList = jsonDecode(result);
      List<Map<String, dynamic>> mapList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        mapList.add(i);
      }
      List<Activity> activityResultList =
          mapList.map((act) => Activity.fromJson(act)).toList();

      return activityResultList;
    } else {
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occurred during intialising activity data');
    }
  }
}
