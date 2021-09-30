import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ViewActivitiesScreen extends StatelessWidget {
  const ViewActivitiesScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final title = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
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
                    title,
                    style: titleOneTextStyleBold,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.15,)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
