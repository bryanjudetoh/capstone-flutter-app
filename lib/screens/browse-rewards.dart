import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loadmore/loadmore.dart';
import 'package:youthapp/models/participant.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import '../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

class InitBrowseRewardsScreen extends StatelessWidget {
  InitBrowseRewardsScreen({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    return BrowseRewardsScreen();
  }
}

class BrowseRewardsScreen extends StatefulWidget {
  BrowseRewardsScreen({Key? key});

  @override
  _BrowseRewardsScreenState createState() => _BrowseRewardsScreenState();
}

class _BrowseRewardsScreenState extends State<BrowseRewardsScreen> {
  final String placeholderPicUrl =
      'http://pngimg.com/uploads/gift/gift_PNG5950.png';

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
                      Expanded(
                        child: displayBrowseRewards(),
                      )
                    ]))));
  }

  Widget displayBrowseRewards() {
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
                    child: (Column(children: <Widget>[
                      Image.network(
                        placeholderPicUrl,
                        width: 500,
                        height: 200,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reward name',
                              style: titleOneTextStyleBold,
                              textAlign: TextAlign.left,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image(
                                  image: AssetImage('assets/images/elixir.png'),
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
                          )),
                    ])),
                  ),
                ))));
  }
}
