import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/models/reward.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import '../constants.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

class InitBrowseRewardsScreen extends StatelessWidget {
  InitBrowseRewardsScreen({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackground,
      child: FutureBuilder<Map<String, dynamic>>(
        future: initRewardsScreenData(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!;
            return BrowseRewardsScreen(
              user: data['user'],
              initRewardsList: data['rewardsList'],
              secureStorage: secureStorage,
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
      ),
    );
  }

  Future<Map<String, dynamic>> initRewardsScreenData() async {
    Map<String, dynamic> data = {};

    String userData = await this.secureStorage.readSecureData('user');
    data['user'] = User.fromJson(jsonDecode(userData));

    var response = await http.get(
        Uri.parse('https://eq-lab-dev.me/api/reward-svc/mp/reward/list?orgName=')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Reward> rewardsList = [];
      for (dynamic item in resultList) {
        Reward r = Reward.fromJson(Map<String, dynamic>.from(item));
        rewardsList.add(r);
      }

      data['rewardsList'] = rewardsList;

      return data;
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during your search');
    }
  }
}

class BrowseRewardsScreen extends StatefulWidget {
  BrowseRewardsScreen({Key? key, required this.initRewardsList, required this.user, required this.secureStorage});

  final User user;
  final SecureStorage secureStorage;

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );
  final List<Reward> initRewardsList;

  @override
  _BrowseRewardsScreenState createState() =>
      _BrowseRewardsScreenState();
}

class _BrowseRewardsScreenState extends State<BrowseRewardsScreen> {
  late List<Reward> rewards;
  late int myElixirs;

  @override
  void initState() {
    super.initState();
    this.rewards = widget.initRewardsList;
    this.myElixirs = widget.user.elixirBalance!;
  }

  final String placeholderPicUrl = placeholderRewardsPicUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                color: kBackground,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                              padding: EdgeInsets.only(
                                  left: 10, top: 15, bottom: 15),
                              primary: kGrey,
                            ),
                          ),
                          Text(
                            'Rewards',
                            style: titleOneTextStyleBold,
                          ),
                          Flexible(
                            child: SizedBox(width: 65),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('My elixirs: ${this.myElixirs.toString()}', style: titleThreeTextStyleBold,),
                              Image(
                                image: AssetImage(
                                    'assets/images/elixir.png'),
                                height: 35,
                                width: 35,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {Navigator.pushNamed(context, '/my-rewards');},
                            child: Row(
                              children: <Widget>[
                                Text('My Rewards', style: titleThreeTextStyle,),
                                Icon(Icons.navigate_next),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: kLightBlue,
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: displayBrowseRewards(),
                      )
                    ]
                )
            )
        )
    );
  }

  Future<void> doRedemption(String rewardId, int? elixirCost) async {
    var response = await widget.http.post(
      Uri.parse('https://eq-lab-dev.me/api/reward-svc/mp/reward/' + rewardId),
    );

    if (response.statusCode == 200) {
      print('redemption OK');
      var result = jsonDecode(response.body);
      print(result['status']);

      User user = await getUserDetails();
      widget.secureStorage.writeSecureData('user', jsonEncode(user.toJson()));
      setState(() {
        this.myElixirs = user.elixirBalance!;
      });

      //external reward
      if(result['status'] == 'issued') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: 'External Reward Redemption Success!',
                desc: 'Your redemption is successful! Since your reward is external, it should have been emailed to you.',
                func: () {
                  Navigator.pop(context);
                },
              );
            }
        );
      }
      else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: 'In App Reward Redemption Success!',
                desc: 'Your redemption is successful!',
                func: () {
                  Navigator.pop(context);
                },
              );
            }
        );
      }
    }
    else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      var err = result['error']['message'];
      print(result);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertPopup(
                title: result['error']['name'],
                desc: err,
                func: () {
                  Navigator.pop(context);
                }
            );
          }
      );
    }
    else {
      var result = jsonDecode(response.body);
      print('doRedemption error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      throw Exception('A problem occured while redeeming this reward');
    }
  }

  Widget displayBrowseRewards() {
    return ListView.builder(
        itemCount: rewards.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              height: 680,
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
                                    child: rewards[index].mediaContentUrls!.isEmpty
                                        ? Image.network(
                                      placeholderPicUrl,
                                      width: 500,
                                      height: 200,
                                    )
                                        : CarouselSlider(
                                      options: CarouselOptions(
                                        autoPlay: false,
                                        enableInfiniteScroll: true,
                                        viewportFraction: 1.0,
                                      ),
                                      items: rewards[index].mediaContentUrls!
                                          .map(
                                              (url) => Image.network(
                                            url,
                                            fit: BoxFit.fitHeight,
                                          )
                                      ).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.55,
                                        child: Text(
                                          '${rewards[index].name}',
                                          style: titleTwoTextStyleBold,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                              '${rewards[index].elixirCost}',
                                              style: TextStyle(
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
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
                                      '${rewards[index].organisation!.name}',
                                      style: bodyTextStyle,
                                      textAlign: TextAlign.left,
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
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
                                          '${rewards[index].rewardStartTime.toString().split(' ')[0]}',
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
                                          '${rewards[index].rewardEndTime.toString().split(' ')[0]}',
                                          style: bodyTextStyleBold,
                                        )
                                      ]),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(height: 1,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(children: [
                                            Text(
                                              'Max claims per user',
                                              style: captionTextStyle,
                                            ),
                                            SizedBox(
                                              height: 1,
                                            ),
                                            Text(
                                              '${rewards[index].maxClaimPerUser}',
                                              style: bodyTextStyleBold,
                                            )
                                          ]),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Column(children: [
                                            Text(
                                              'Reward type:',
                                              style: captionTextStyle,
                                            ),
                                            SizedBox(
                                              height: 1,
                                            ),
                                            Text(
                                              '${rewardTypeMap[rewards[index].type]}',
                                              style: bodyTextStyleBold,
                                            )
                                          ]),
                                        ],
                                      ),
                                      SizedBox(height: 1,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Column(children: [
                                            Text(
                                              'No. claimed',
                                              style: captionTextStyle,
                                            ),
                                            SizedBox(
                                              height: 1,
                                            ),
                                            Row(children: [
                                              Text(
                                                '${rewards[index].totalClaimed} / ${rewards[index].quantity}',
                                                style: bodyTextStyleBold,
                                              ),
                                            ]),
                                          ]),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Column(children: [
                                            Container(
                                              child: rewards[index].expiryDate != null
                                                  ? Text('Use by date:', style: captionTextStyle,)
                                                  : Text('Use within:', style: captionTextStyle,),
                                            ),
                                            SizedBox(
                                              height: 1,
                                            ),
                                            Container(
                                              child: rewards[index].expiryDate != null
                                                  ? Text('${rewards[index].expiryDate.toString().split(' ')[0]}', style: bodyTextStyleBold)
                                                  : Text('${rewards[index].expiryDuration!} hours', style: bodyTextStyleBold)
                                              ,
                                            ),
                                          ]),
                                        ],
                                      ),
                                      SizedBox(height: 1,),
                                    ],
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${rewards[index].description}',
                                      style: bodyTextStyle,
                                      textAlign: TextAlign.left,
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    RoundedButton(
                                        func: () {
                                          doRedemption(rewards[index].rewardId, rewards[index].elixirCost);
                                        },
                                        colorFont: Colors.white,
                                        colorBG: kLightBlue,
                                        title: 'Redeem'
                                    ),
                                  ],
                                )
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

  Future<User> getUserDetails() async {
    var response = await widget.http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/user'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    else {
      var result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while retrieving user details');
    }
  }
}
