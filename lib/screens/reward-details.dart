import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/models/reward.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/rounded-button.dart';

class InitRewardDetailsScreen extends StatelessWidget {
  InitRewardDetailsScreen({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<User>(
        future: getUserData(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.hasData) {
            User user = snapshot.data!;
            return RewardDetailsScreen(reward: data['reward'], user: user, secureStorage: this.secureStorage, updateMyElixirs: data['func'],);
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

  Future<User> getUserData() async {
    String userData = await this.secureStorage.readSecureData('user');
    return User.fromJson(jsonDecode(userData));
  }
}


class RewardDetailsScreen extends StatefulWidget {
  RewardDetailsScreen({Key? key, required this.reward, required this.user, required this.secureStorage, this.updateMyElixirs}) : super(key: key);

  final Reward reward;
  final User user;
  final SecureStorage secureStorage;
  final Function? updateMyElixirs;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _RewardDetailsScreenState createState() => _RewardDetailsScreenState();
}

class _RewardDetailsScreenState extends State<RewardDetailsScreen> {

  late int myElixirs;

  @override
  void initState() {
    super.initState();
    this.myElixirs = widget.user.elixirBalance!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
                    'Reward Details',
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
              Container(
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
                                    child: widget.reward.mediaContentUrls!.isEmpty
                                        ? Image.network(
                                      placeholderRewardsPicUrl,
                                      width: 500,
                                      height: 200,
                                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                        print('bad url: $placeholderRewardsPicUrl');
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
                                      items: widget.reward.mediaContentUrls!
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
                                          '${widget.reward.name}',
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
                                              '${widget.reward.elixirCost}',
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
                                      '${widget.reward.organisation!.name}',
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
                                          '${widget.reward.rewardStartTime.toString().split(' ')[0]}',
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
                                          '${widget.reward.rewardEndTime.toString().split(' ')[0]}',
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
                                  decoration: BoxDecoration(
                                    color: kBluishWhite,
                                    border: Border.all(
                                      width: 3,
                                      color: kBluishWhite,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  width: 500,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
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
                                                  '${widget.reward.maxClaimPerUser}',
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
                                                  '${rewardTypeMap[widget.reward.type]}',
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
                                                    '${widget.reward.totalClaimed} / ${widget.reward.quantity}',
                                                    style: bodyTextStyleBold,
                                                  ),
                                                ]),
                                              ]),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Column(children: [
                                                Container(
                                                  child: widget.reward.expiryDate != null
                                                      ? Text('Use by date:', style: captionTextStyle,)
                                                      : Text('Use within:', style: captionTextStyle,),
                                                ),
                                                SizedBox(
                                                  height: 1,
                                                ),
                                                Container(
                                                  child: widget.reward.expiryDate != null
                                                      ? Text('${widget.reward.expiryDate.toString().split(' ')[0]}', style: bodyTextStyleBold)
                                                      : Text('${widget.reward.expiryDuration!} hours', style: bodyTextStyleBold)
                                                  ,
                                                ),
                                              ]),
                                            ],
                                          ),
                                          SizedBox(height: 1,),
                                        ],
                                      ),
                                      if (widget.reward.type == 'inAppReward')
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
                                              widget.reward.discount != null
                                                  ? '\$${widget.reward.discount!.toStringAsFixed(2)}'
                                                  : '\$0.00'
                                              ,
                                              style: bodyTextStyleBold,
                                            ),
                                          ],
                                        )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: kLightBlue,
                                        padding: EdgeInsets.fromLTRB(10, 3, 13, 3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        )
                                    ),
                                    onPressed: () {
                                      Map<String, dynamic> data = {};
                                      data['sharedReward'] = widget.reward;
                                      Navigator.pushNamed(context, '/create-post-shared', arguments: data);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.share,),
                                        SizedBox(width: 5,),
                                        Text(
                                          'Share',
                                          style: TextStyle(
                                            fontFamily: 'SF Pro Display',
                                            fontSize: 20.0,
                                            height: 1.25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${widget.reward.description}',
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
                                          doRedemption(widget.reward.rewardId, widget.updateMyElixirs);
                                        },
                                        colorFont: Colors.white,
                                        colorBG: kLightBlue,
                                        title: 'Redeem',
                                        disableText: widget.reward.elixirCost! > this.myElixirs ? 'Insufficient Elixirs' : null,
                                    ),
                                  ],
                                )
                              ]
                          ),
                        ),
                      )
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> doRedemption(String rewardId, Function? updateMyElixirs) async {
    var response = await widget.http.post(
      Uri.parse('https://eq-lab-dev.me/api/reward-svc/mp/reward/' + rewardId),
    );

    if (response.statusCode == 200) {
      print('redemption OK');
      var result = jsonDecode(response.body);
      print(result['status']);

      User updatedUser = await getUserDetails();
      widget.secureStorage.writeSecureData('user', jsonEncode(updatedUser.toJson()));
      setState(() {
        this.myElixirs = updatedUser.elixirBalance!;
      });
      if (updateMyElixirs != null) {
        updateMyElixirs(updatedUser.elixirBalance!);
      }

      //external reward
      if(result['status'] == 'issued') {
        showDialog(
            context: this.context,
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

