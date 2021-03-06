import 'package:flutter/material.dart';
import 'package:youthapp/models/leaderboard-entity.dart';

import '../constants.dart';

class LeaderboardListTile extends StatelessWidget {
  const LeaderboardListTile({Key? key, required this.myUserId, required this.user, required this.position, required this.userIdCheck, required this.leaderboardType}) : super(key: key);

  final String myUserId;
  final LeaderboardEntity user;
  final int position;
  final String userIdCheck;
  final String leaderboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: this.userIdCheck == this.user.userId
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.lightBlueAccent,
                  blurRadius: 5.0,
                  spreadRadius: 3.0,
                ),
              ],
            )
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            )
      ,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            this.user.profilePicUrl != null && this.user.profilePicUrl!.isNotEmpty ? this.user.profilePicUrl! : placeholderDisplayPicUrl,
          ),
          radius: 30,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${user.name}',
              style: titleThreeTextStyle,
            ),
            Text(
              '${this.user.ranking == null ? toOrdinal(this.position) : toOrdinal(user.ranking!)} place',
              style: subtitleTextStyle,
            )
          ],
        ),
        trailing: Container(
          constraints: const BoxConstraints(
            maxHeight: 140,
            maxWidth: 85,
            minHeight: 120,
            minWidth: 70,
          ),
          child: Row(
            children: <Widget>[
              Image(
                image: AssetImage(
                    '${activityTypeToPotionColorPathMap[leaderboardType]}'),
                height: 35,
                width: 35,
              ),
              SizedBox(width: 5,),
              Text(
                '${user.value}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  color: kLightBlue,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          String message = '';
          if (this.user.userId == 'fakeId') {
            message = 'User doesn\'t exist';
          }
          else if (this.user.userId != this.myUserId) {
            Navigator.pushNamed(context, '/user-profile', arguments: this.user.userId);
          }
          else {
            message = 'That\'s your own profile';
          }
          if (message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    message,
                    style: bodyTextStyle,
                  ),
                  duration: const Duration(seconds: 1),
                )
            );
          }
        },
      ),
    );
  }
}
