import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/leaderboard-entity.dart';

class TopThreeIcon extends StatelessWidget {
  const TopThreeIcon({Key? key, required this.myUserId, required this.user, required this.position, required this.userIdCheck, required this.leaderboardType}) : super(key: key);

  final String myUserId;
  final LeaderboardEntity user;
  final int position;
  final String userIdCheck;
  final String leaderboardType;

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
          SizedBox(height: this.position == 1 ? 4 : 7,),
          GestureDetector(
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
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: this.userIdCheck == this.user.userId
                      ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightBlueAccent,
                        blurRadius: 6.0,
                        spreadRadius: 5.0,
                      ),
                    ],
                  )
                      : BoxDecoration(
                      color: Colors.white
                  ),
                  child: CircleAvatar(
                    backgroundColor: kLightBlue,
                    backgroundImage: NetworkImage(
                      this.user.profilePicUrl != null && this.user.profilePicUrl!.isNotEmpty ? this.user.profilePicUrl! : placeholderDisplayPicUrl,
                    ),
                    radius: this.position == 1 ? 60 : 50,
                  ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage(
                    '${activityTypeToPotionColorPathMap[leaderboardType]}'),
                height: 30,
                width: 30,
              ),
              SizedBox(width: 5,),
              Text(
                '${user.value}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  color: kLightBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
