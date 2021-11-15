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

class _MyRewardsScreenState extends State<MyRewardsScreen> with TickerProviderStateMixin {

  final String placeholderPicUrl = placeholderRewardsPicUrl;
  late TabController tabController;

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
                      ],
                    ),
                  ),
                  bottom: TabBar(
                    unselectedLabelColor: Colors.blueGrey,
                    indicatorColor: kLightBlue,
                    labelColor: kLightBlue,
                    tabs: [
                      Tab(child: Text('Active', style: bodyTextStyle,)),
                      Tab(child: Text('History', style: bodyTextStyle,)),
                    ],
                    controller: tabController,
                  ),
                ),
              ];
            },
            body: TabBarView(
                controller: tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  FutureBuilder<List<ClaimedReward>>(
                      future: retrieveMyRewards(active: true),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<ClaimedReward>> snapshot) {
                        if (snapshot.hasData) {
                          List<ClaimedReward> myRewardsList = snapshot.data!;
                          return displayMyRewards(myRewardsList: myRewardsList, isActive: true);
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
                  FutureBuilder<List<ClaimedReward>>(
                      future: retrieveMyRewards(active: false),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<ClaimedReward>> snapshot) {
                        if (snapshot.hasData) {
                          List<ClaimedReward> myRewardsList = snapshot.data!;
                          return displayMyRewards(myRewardsList: myRewardsList, isActive: false);
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
                ]
            ),
          ),
        ),
      ),
    );
  }

  Future<List<ClaimedReward>> retrieveMyRewards({required bool active}) async {
    final response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/reward-svc/mp/reward/list/claimed?active=$active'),
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

  Widget displayMyRewards({required List<ClaimedReward> myRewardsList, required bool isActive}) {
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
              'You do not have any ${isActive ? 'active' : 'history of'} rewards... \nGo get some!',
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
              height: 600,
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
                              ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                child: Container(
                                  height: 200,
                                  width: 500,
                                  child: myRewardsList[index].reward.mediaContentUrls!.isEmpty
                                      ? Image.network(
                                    placeholderPicUrl,
                                    width: 500,
                                    height: 200,
                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      print('bad url: ${placeholderPicUrl}');
                                      return const Center(
                                        child: Text('Couldn\'t load image.', style: bodyTextStyle,),
                                      );
                                    }
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
                                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                            print('bad url: $url');
                                            return const Center(
                                              child: Text('Couldn\'t load image.', style: bodyTextStyle,),
                                            );
                                          }
                                        )
                                    ).toList(),
                                  ),
                                ),
                              ),
                              SizedBox( height: 10, ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.55,
                                      child: Text(
                                        '${myRewardsList[index].reward.name}',
                                        style: titleOneTextStyleBold,
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image(
                                          image: AssetImage(
                                              'assets/images/power-elixir.png'),
                                          height: 40,
                                          width: 40,
                                        ),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Text(
                                            '${myRewardsList[index].reward.elixirCost}',
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
                                    '${myRewardsList[index].reward.organisation!.name}',
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
                                        'Claimed on:',
                                        style: captionTextStyle,
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        '${myRewardsList[index].claimDate.toString().split(' ')[0]}',
                                        style: bodyTextStyleBold,
                                      )
                                    ]),
                                    SizedBox(
                                      width: 70,
                                    ),
                                    Column(children: [
                                      Text(
                                        'Expires on:',
                                        style: captionTextStyle,
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        '${myRewardsList[index].expiryDate.toString().split(' ')[0]}',
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
                                        'Status:',
                                        style: captionTextStyle,
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        '${getCapitalizeString(str: myRewardsList[index].status!)}',
                                        style: bodyTextStyleBold,
                                      )
                                    ]),
                                    SizedBox(width: myRewardsList[index].reward.type == 'inAppReward' ? 35 : 70,),
                                    Column(children: [
                                      Text(
                                        'Reward Type:',
                                        style: captionTextStyle,
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        '${rewardTypeMap[myRewardsList[index].reward.type]}',
                                        style: bodyTextStyleBold,
                                      )
                                    ]),
                                    if (myRewardsList[index].reward.type == 'inAppReward')
                                      Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 35,
                                          ),
                                          Column(children: [
                                            Text(
                                              'Discount:',
                                              style: captionTextStyle,
                                            ),
                                            SizedBox(
                                              height: 1,
                                            ),
                                            Text(
                                                myRewardsList[index].reward.discount != null
                                                    ? '\$${myRewardsList[index].reward.discount!.toStringAsFixed(2)}'
                                                    : '\$0.00'
                                              ,
                                              style: bodyTextStyleBold,
                                            ),
                                          ]),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${myRewardsList[index].reward.description}',
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
