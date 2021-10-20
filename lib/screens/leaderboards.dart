import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/models/leaderboard-entity.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:youthapp/widgets/topthree-icon.dart';
import 'package:youthapp/widgets/leaderboard-entity.dart';
import '../constants.dart';

class InitLeaderBoardScreen extends StatelessWidget {
  InitLeaderBoardScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<LeaderboardEntity>>(
            future: initLeaderboardData(),
            builder: (BuildContext context, AsyncSnapshot<List<LeaderboardEntity>> snapshot) {
              if (snapshot.hasData) {
                List<LeaderboardEntity> initList = snapshot.data!;
                return LeaderboardScreen(initialLeaderboardList: initList,);
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
      ),
    );
  }

  Future<List<LeaderboardEntity>> initLeaderboardData() async {
    var response = await this.http.get(
        Uri.parse('https://eq-lab-dev.me/api/reward-svc/ap/leaderboard/cumulative?type=overall')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Map<String, dynamic>> mapList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        mapList.add(i);
      }
      List<LeaderboardEntity> leaderboardEntityList = mapList.map((act) => LeaderboardEntity.fromJson(act)).toList();

      return leaderboardEntityList;
    }
    else {
      String result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during intialising leaderboard data');
    }
  }
}


class LeaderboardScreen extends StatefulWidget {
  LeaderboardScreen({Key? key, required this.initialLeaderboardList}) : super(key: key);

  final List<LeaderboardEntity> initialLeaderboardList;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {

  List<LeaderboardEntity> leaderboardList = [];
  String leaderboardType = leaderboardTypesList[0];
  String leaderboardPeriod = leaderboardPeriodList[0];
  List<String> emptyList = ['-NA-'];
  bool isCumulative = true;

  @override
  void initState() {
    super.initState();
    this.leaderboardList = widget.initialLeaderboardList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                    'Leaderboards',
                    style: titleOneTextStyleBold,
                  ),
                  Flexible(
                    child: SizedBox(width: 65),
                  )
                ],
              ),
              SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Column(
                    children: <Widget>[
                      Text(
                        'Leaderboard Type:',
                        style: bodyTextStyleBold,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 5,),
                      Container(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: this.leaderboardType,
                            items: leaderboardTypesList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: bodyTextStyle,),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                this.leaderboardType = value!;
                              });
                            },
                            isExpanded: true,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 10, right: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(2, 3),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ],
                  )
                  ),
                  SizedBox(width: 10,),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 75,),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Switch(
                            value: this.isCumulative,
                            onChanged: (value) {
                              setState(() {
                                this.isCumulative = value;
                                this.leaderboardPeriod = value ? this.emptyList[0] : leaderboardPeriodList[0];
                              });
                            },
                            activeColor: kLightBlue,
                            activeTrackColor: Colors.lightBlue.shade100,
                          ),
                          Text(
                            this.isCumulative ? 'Cumulative' : 'Periodical',
                            style: smallBodyTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Column(
                    children: <Widget>[
                      Text(
                        'Time Period:',
                        style: bodyTextStyleBold,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 5,),
                      Container(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: this.isCumulative ? this.emptyList[0] : this.leaderboardPeriod,
                            items: this.isCumulative ?
                            this.emptyList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: bodyTextStyle,),
                              );
                            }).toList()
                                : leaderboardPeriodList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: bodyTextStyle,),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                this.leaderboardPeriod = value!;
                              });
                            },
                            isExpanded: true,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 10, right: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(2, 3),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ],
                  ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 85),
                    child: Container(
                      padding: EdgeInsets.only(left: 10, top: 25),
                      child: ElevatedButton(
                        onPressed: () async {
                          List<LeaderboardEntity> list = await queryLeaderboard();
                          setState(() {
                            this.leaderboardList = list;
                          });
                        },
                        child: Text(
                          'Go',
                          style: smallBodyTextStyleBold,
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: kLightBlue,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              SizedBox(height: 10,),
              Column(
                children: displayLeaderboard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> displayLeaderboard() {
    LeaderboardEntity emptyEntity = LeaderboardEntity(
        name: '---',
        type: '',
        school: '',
        value: 0,
    );
    Widget topThree = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TopThreeIcon(
          user: this.leaderboardList.length > 2 ? this.leaderboardList[2] : emptyEntity,
          position: 3,
        ),
        TopThreeIcon(
          user: this.leaderboardList.length > 0 ? this.leaderboardList[0] : emptyEntity,
          position: 1,
        ),
        TopThreeIcon(
          user: this.leaderboardList.length > 1 ? this.leaderboardList[1] : emptyEntity,
          position: 2,
        ),
      ],
    );
    List<Widget> display = [topThree, SizedBox(height: 20,)];
    if (this.leaderboardList.length > 3) {
      for (int i = 3; i < this.leaderboardList.length; i++) {
        display.add(
            LeaderboardListTile(user: leaderboardList[i], position: i+1,)
        );
      }
    }
    else {
      display.add(
        LeaderboardListTile(user: emptyEntity, position: 4,)
      );
    }
    return display;
  }

  Future<List<LeaderboardEntity>> queryLeaderboard() async {
    if (this.isCumulative) {
      String type = leaderboardTypeMapInverse[this.leaderboardType]!;

      var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/reward-svc/ap/leaderboard/cumulative?type=$type'),
      );

      if (response.statusCode == 200) {
        List<dynamic> resultList = jsonDecode(response.body);
        List<Map<String, dynamic>> mapList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String, dynamic>.from(item);
          mapList.add(i);
        }
        List<LeaderboardEntity> leaderboardEntityList = mapList.map((act) => LeaderboardEntity.fromJson(act)).toList();

        return leaderboardEntityList;
      }
      else {
        var result = jsonDecode(response.body);
        print(result);
        throw Exception('A problem occurred during intialising leaderboard data');
      }
    }
    else {
      String type = leaderboardTypeMapInverse[this.leaderboardType]!;
      String period = leaderboardPeriodMap[this.leaderboardPeriod]!;

      var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/reward-svc/mp/leaderboard/earned?type=$type&periodDays=$period'),
      );

      if (response.statusCode == 200) {
        List<dynamic> resultList = jsonDecode(response.body);
        List<Map<String, dynamic>> mapList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String, dynamic>.from(item);
          mapList.add(i);
        }
        List<LeaderboardEntity> leaderboardEntityList = mapList.map((act) => LeaderboardEntity.fromJson(act)).toList();

        return leaderboardEntityList;
      }
      else {
        String result = jsonDecode(response.body);
        print(result);
        throw Exception('A problem occurred during intialising leaderboard data');
      }
    }
  }

}
