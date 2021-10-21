import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/leaderboard-entity.dart';

class TopThreeIcon extends StatelessWidget {
  const TopThreeIcon({Key? key, required this.user, required this.position}) : super(key: key);
  
  final LeaderboardEntity user;
  final int position;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.25,
      child: Column(
        children: <Widget>[
          Text(
            '${toOrdinal(this.position)}',
            style: TextStyle(
              fontFamily: 'SF Display Pro',
              fontWeight: FontWeight.bold,
              fontSize: this.position == 1 ? 18 : 16,
              decoration: TextDecoration.underline,
            ),
          ),
          SizedBox(height: 5,),
          Stack(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: kLightBlue,
                backgroundImage: NetworkImage(
                  this.user.profilePicUrl != null && this.user.profilePicUrl!.isNotEmpty ? this.user.profilePicUrl! : placeholderDisplayPicUrl,
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
                    color: this.position == 1 ? Color(0xFFFFD000) : this.position == 2 ? Color(0xFFC0C0C0) : Color(0xFFCD7F32),
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
              fontSize: this.position == 1 ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10,),
          Text(
            '${user.value}',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              color: kLightBlue,
            ),
          )
        ],
      ),
    );
  }
}
