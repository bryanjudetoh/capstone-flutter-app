import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/models/reward.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
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
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
                                    'assets/images/power-elixir.png'),
                                height: 25,
                                width: 25,
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

  Widget displayBrowseRewards() {
    return ListView.builder(
        itemCount: rewards.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
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
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  print('bad url: $placeholderPicUrl');
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
                                items: rewards[index].mediaContentUrls!
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
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                        '${rewards[index].elixirCost}',
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
                                '${rewards[index].organisation!.name}',
                                style: bodyTextStyle,
                                textAlign: TextAlign.left,
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                              if (rewards[index].type == 'inAppReward')
                                Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 70,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Discount:',
                                          style: captionTextStyle,
                                        ),
                                        SizedBox(
                                          height: 1,
                                        ),
                                        Text(
                                          rewards[index].discount != null
                                              ? '\$${rewards[index].discount!.toStringAsFixed(2)}'
                                              : '\$0.00'
                                          ,
                                          style: bodyTextStyleBold,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RoundedButton(
                                  func: () {
                                    Map<String, dynamic> data = {};
                                    data['reward'] = rewards[index];
                                    data['func'] = updateMyElixirs;
                                    Navigator.pushNamed(context, '/reward-details', arguments: data);
                                  },
                                  colorFont: Colors.white,
                                  colorBG: kLightBlue,
                                  title: 'More details'
                              ),
                            ],
                          )
                        ]
                    ),
                  ),
                )
            )
          );
        }
    );
  }

  void updateMyElixirs(int newElixrBalance) {
    setState(() {
      this.myElixirs = newElixrBalance;
    });
  }
}
