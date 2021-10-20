import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/leaderboard-entity.dart';

class TopThreeIcon extends StatelessWidget {
  const TopThreeIcon({Key? key, required this.user, required this.position}) : super(key: key);
  
  final LeaderboardEntity user;
  final int position;
  final String profilePicUrl = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: kLightBlue,
                backgroundImage: NetworkImage(
                  this.profilePicUrl.isNotEmpty ? this.profilePicUrl : placeholderDisplayPicUrl,
                ),
                radius: this.position == 1 ? 60 : 50,
              ),
              Positioned.fill(
                  child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: this.position == 1 ? 40 : 35,
                  height: this.position == 1 ? 40 : 35,
                  decoration: new BoxDecoration(
                    color: this.position == 1 ? Colors.amber : this.position == 2 ? Colors.blueGrey : Colors.orange.shade400,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(5),
                  child: SvgPicture.asset(
                    'assets/icons/medal.svg',
                    color: Colors.white,
                  ),
                ),
              )
              ),
            ],
          ),
          SizedBox(width: 5,),
          Text(
            '${this.user.name}',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: this.position == 1 ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 10,),
          Text(
            '${user.value}',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: kLightBlue,
            ),
          )
        ],
      ),
    );
  }
}
