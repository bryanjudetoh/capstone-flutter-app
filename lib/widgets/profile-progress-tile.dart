import 'package:flutter/material.dart';
import 'package:youthapp/models/participant.dart';
import 'package:youthapp/models/user.dart';

import '../constants.dart';

class ProfileProgressTile extends StatelessWidget {
  const ProfileProgressTile({Key? key, required this.user, required this.completedList, required this.type}) : super(key: key);

  final User user;
  final List<Participant> completedList;
  final String type;

  @override
  Widget build(BuildContext context) {
    List<Participant> completedByTypeList = [];
    completedByTypeList.addAll(completedList.where((p) => p.activity.type == type));
    if (completedByTypeList.isNotEmpty) {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  activityTypeMap[type]!,
                  style: titleTwoTextStyleBold,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '${user.potionBalance![type]}',
                      style: titleTwoTextStyle,
                    ),
                    SizedBox(width: 3,),
                    Image(
                      image: AssetImage('${activityTypeToPotionColorPathMap[type]}'),
                      height: 40,
                      width: 40,
                    ),
                  ],
                )
              ],
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: completedByTypeList.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${completedByTypeList[index].activity.name}',
                                style: bodyTextStyle,
                              ),
                            ],
                          ),
                          width: MediaQuery.of(context).size.width*0.38,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Awarded: ${completedByTypeList[index].awardedPotions}',
                            ),
                            SizedBox(width: 3,),
                            Image(
                              image: AssetImage('${activityTypeToPotionColorPathMap[type]}'),
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(width: 3,),
                            Icon(Icons.navigate_next),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/registered-activity-details', arguments: completedByTypeList[index].participantId);
                  },
                );
              },
            ),
          ],
        ),
      );
    }
    else {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  activityTypeMap[type]!,
                  style: titleTwoTextStyleBold,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '${user.potionBalance![type]}',
                      style: titleTwoTextStyle,
                    ),
                    SizedBox(width: 3,),
                    Image(
                      image: AssetImage('${activityTypeToPotionColorPathMap[type]}'),
                      height: 40,
                      width: 40,
                    ),
                  ],
                )
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Text(
                'You have not participated in any ${activityTypeMap[type]} yet!',
                style: subtitleTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }
}
