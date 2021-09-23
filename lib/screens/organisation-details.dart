import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/text-button.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class OrganisationDetailsScreen extends StatelessWidget {
  const OrganisationDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 35.0, right: 35.0, top: 50.0),
          child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Organisation Details",
                      style: titleOneTextStyleBold,
                    ),
                    PlainTextButton(
                      title: 'Back',
                      func: () {
                        Navigator.of(context).pop(false);
                      },
                      textStyle: backButtonBoldItalics,
                      textColor: kBlack,
                    ),
                  ]
              ),
              SizedBox(
                height: 10.0,
              ),
              Column(
                children: <Widget>[
                  Text(
                    'Organisation name',
                    style: titleTwoTextStyleBold,
                  ),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text(
                    'email@email.com',
                    style: captionTextStyle,
                  ),
                  Text(
                    'example.com',
                    style: captionTextStyle,
                  ),
                  Text(
                    'Country code',
                    style: captionTextStyle,
                  ),
                  Text(
                    'Horseriding',
                    style: captionTextStyle,
                  ),
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}


