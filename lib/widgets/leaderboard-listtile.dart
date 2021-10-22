import 'package:flutter/material.dart';
import 'package:youthapp/models/leaderboard-entity.dart';

import '../constants.dart';

class LeaderboardListTile extends StatelessWidget {
  const LeaderboardListTile({Key? key, required this.user, required this.position}) : super(key: key);

  final LeaderboardEntity user;
  final int position;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
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
              '${toOrdinal(this.position)} place',
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
