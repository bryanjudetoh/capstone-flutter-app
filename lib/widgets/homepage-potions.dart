import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';

class HomepagePotion extends StatelessWidget {
  const HomepagePotion({Key? key, required this.multiplier, required this.potionBalance, required this.mapKey}) : super(key: key);

  final Map<String, int> multiplier;
  final Map<String, dynamic> potionBalance;
  final String mapKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed('/browse-activities', arguments: '${this.mapKey}');
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('${this.potionBalance[this.mapKey]}', style: homeElixirSmallBodyTextStyle,),
                Image(
                  image: AssetImage(activityTypeToPotionColorPathMap[this.mapKey]!),
                  height: 30,
                  width: 30,
                ),
              ],
            ),
            Text('${activityTypeMap[this.mapKey]}', style: homeElixirXsmallBodyTextStyle,),
            if (this.multiplier[this.mapKey] != 1)
              Column(
                children: <Widget>[
                  SizedBox(height: 5,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: Text(
                      '2x',
                      style: TextStyle(
                        fontFamily: 'SF Display Pro',
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: kLightBlue,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
