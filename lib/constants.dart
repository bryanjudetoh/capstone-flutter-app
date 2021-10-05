import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

const kWhite = Color(0xFFE5E5E5);
const kBlack = Color(0xFF000000);
const kLightBlue = Color(0xFF5EC8D8);
const kYellow = Color(0xFFFAAD19);
const kGrey = Color(0xFFDBDFF1);
const kDarkGrey = Color(0xFF66676C);
const kTeal = Color(0xFF6FBCB5);
const kRed = Color(0xFFF15929);
const kBluishWhite = Color(0xFFDBDFF1);
const kBackground = Color(0xFFF9F9F9);

const hugeTitleTextStyle = TextStyle(
  fontFamily: 'SF Pro Display',
  fontSize: 60.0,
  height: 1.25,
);

const hugeTitleTextStyleBold = TextStyle(
  fontFamily: 'SF Pro Display',
  fontSize: 60.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);

const largeTitleTextStyle = TextStyle(
  fontFamily: 'SF Pro Display',
  fontSize: 34.0,
  height: 1.25,
);

const largeTitleTextStyleBold = TextStyle(
  fontFamily: 'SF Pro Display',
  fontSize: 34.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);

const titleOneTextStyle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 28.0,
    height: 1.25,
    fontWeight: FontWeight.bold,
);

const titleOneTextStyleBold = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 28.0,
    height: 1.25,
    fontWeight: FontWeight.bold,
);

const titleTwoTextStyle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 22.0,
    height: 1.25,
);

const titleTwoTextStyleBold = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 22.0,
    height: 1.25,
    fontWeight: FontWeight.bold,
);

const titleThreeTextStyle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 20.0,
    height: 1.25,
);

const titleThreeTextStyleBold = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 20.0,
    height: 1.25,
    fontWeight: FontWeight.bold,
);

const subtitleTextStyleBold = TextStyle(
  fontFamily: 'SF Pro Display',
  fontSize: 17.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
  color: kDarkGrey,
);

const bodyTextStyle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 17.0,
    height: 1.25,
);

const bodyTextStyleBold = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 17.0,
    height: 1.25,
    fontWeight: FontWeight.bold,
);

const smallBodyTextStyle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 15.0,
    height: 1.25,
);

const smallBodyTextStyleBold = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 15.0,
    height: 1.25,
    fontWeight: FontWeight.bold,
);

const xSmallBodyTextStyle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 13.0,
    height: 1.25,
);

const xSmallBodyTextStyleBold = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 13.0,
    height: 1.25,
    fontWeight: FontWeight.bold,
);

const backButtonBoldItalics = TextStyle(
    fontFamily: "SF Pro Display",
    fontSize: 22.0,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold,
    color: Colors.black
);

const captionTextStyle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 15.0,
    height: 1.25,
    color: kDarkGrey,
);

const tabTextStyle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 15.0,
    height: 1.25,
    color: Colors.white,
);

const carouselActivityTitleTextStyle = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
    height: 1.25,
    color: Color(0xFF616161),
);

var countryCodesList = ['MN', 'SG', 'MY'];
var genderList = ['male', 'female', 'others'];
var activityTypeMap = <String,String> {
  'Scholarship': 'scholarship',
  'Internship': 'internship',
  'Mentorship': 'mentorship',
  'Online Courses': 'onlineCourse',
  'Offline Courses': 'offlineCourse',
  'Volunteering': 'volunteering',
  'Sports': 'sports',
};

const int backendSkipLimit = 10;