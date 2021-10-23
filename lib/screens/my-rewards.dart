import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/models/claimed-reward.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

import '../constants.dart';

class MyRewardsScreen extends StatefulWidget {
  MyRewardsScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _MyRewardsScreenState createState() => _MyRewardsScreenState();
}

class _MyRewardsScreenState extends State<MyRewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: kBlack,
                          size: 25,
                        )
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                      primary: kGrey,
                    ),
                  ),
                  Text(
                    'My Rewards',
                    style: titleOneTextStyleBold,
                  ),
                  Flexible(
                    child: SizedBox(width: 65),
                  )
                ],
              ),
              FutureBuilder<List<ClaimedReward>>(
                  future: retrieveMyRewards(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ClaimedReward>> snapshot) {
                    if (snapshot.hasData) {
                      List<ClaimedReward> myRewardsList = snapshot.data!;
                      return Expanded(
                        child: displayMyRewards(myRewardsList),
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
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<ClaimedReward>> retrieveMyRewards() async {
    final response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/reward-svc/mp/reward/list/claimed'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<ClaimedReward> claimedRewardsList = [];
      for (dynamic item in resultList) {
        ClaimedReward r =
            ClaimedReward.fromJson(Map<String, dynamic>.from(item));
        claimedRewardsList.add(r);
      }
      return claimedRewardsList;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during retrieving your rewards');
    }
  }

  Widget displayMyRewards(List<ClaimedReward> myRewardsList) {
    if (myRewardsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_sharp,
              size: 100,
            ),
            Text(
              'You do not have any claimed rewards... \nGo get some!',
              style: titleTwoTextStyleBold,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60,)
          ],
        ),
      );
    }
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: myRewardsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              height: 300,
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
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
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 200,
                                width: 500,
                                child: myRewardsList[index].reward.mediaContentUrls!.isEmpty
                                  ? Image.network(
                                  placeholderRewardsPicUrl,
                                  width: 500,
                                  height: 200,
                                )
                                  : CarouselSlider(
                                  options: CarouselOptions(
                                    autoPlay: false,
                                    enableInfiniteScroll: true,
                                    viewportFraction: 1.0,
                                  ),
                                  items: myRewardsList[index].reward.mediaContentUrls!
                                      .map(
                                          (url) => Image.network(
                                        url,
                                        fit: BoxFit.fitHeight,
                                      )
                                  ).toList(),
                                ),
                              ),
                              SizedBox( height: 10, ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Reward name',
                                      style: titleOneTextStyleBold,
                                      textAlign: TextAlign.left,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                        Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Text(
                                            '15',
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                              color: Color(0xFF5EC8D8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Organisation',
                                    style: bodyTextStyle,
                                    textAlign: TextAlign.left,
                                  )),
                              SizedBox( height: 20, ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(children: [
                                      Text(
                                        'Start date',
                                        style: captionTextStyle,
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        '2021.07.03',
                                        style: bodyTextStyleBold,
                                      )
                                    ]),
                                    SizedBox(
                                      width: 70,
                                    ),
                                    Column(children: [
                                      Text(
                                        'End date',
                                        style: captionTextStyle,
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        '2021.07.16',
                                        style: bodyTextStyleBold,
                                      )
                                    ]),
                                  ],
                                ),
                              ),
                              SizedBox( height: 20, ),
                              Container(
                                padding: EdgeInsets.all(20.0),
                                margin: EdgeInsets.only(bottom: 30.0),
                                decoration: BoxDecoration(
                                  color: kBluishWhite,
                                  border: Border.all(
                                    width: 3,
                                    color: kBluishWhite,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                width: 500,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(children: [
                                      Text(
                                        'Quantity',
                                        style: captionTextStyle,
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        '10',
                                        style: bodyTextStyleBold,
                                      )
                                    ]),
                                    SizedBox(
                                      width: 70,
                                    ),
                                    Column(children: [
                                      Text(
                                        'No. claimed',
                                        style: captionTextStyle,
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Row(children: [
                                        Text('1', style: bodyTextStyleBold),
                                        Text(' / ', style: bodyTextStyleBold),
                                        Text('50', style: bodyTextStyleBold),
                                      ]),
                                    ]),
                                  ],
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Description',
                                    style: bodyTextStyle,
                                    textAlign: TextAlign.left,
                                  )
                              ),
                            ]
                          ),
                        ),
                      )
                  )
              )
          );
        }
    );
  }
}
