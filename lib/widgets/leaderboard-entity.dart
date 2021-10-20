import 'package:flutter/material.dart';
import 'package:youthapp/models/leaderboard-entity.dart';

import '../constants.dart';

class LeaderboardListTile extends StatelessWidget {
  const LeaderboardListTile({Key? key, required this.user, required this.position}) : super(key: key);

  final LeaderboardEntity user;
  final int position;
  final String profilePicUrl = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            this.profilePicUrl.isNotEmpty ? this.profilePicUrl : placeholderDisplayPicUrl,
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
              '${toOrdinal(this.position)} place',
              style: subtitleTextStyle,
            )
          ],
        ),
        trailing: Container(
          height: 120,
          width: 70,
          child: Row(
            children: <Widget>[
              Image(
                image: AssetImage(
                    'assets/images/elixir.png'),
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
      ),
    );
  }
}
