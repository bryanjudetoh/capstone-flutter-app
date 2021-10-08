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

const subtitleTextStyle = TextStyle(
  fontFamily: 'SF Pro Display',
  fontSize: 17.0,
  height: 1.25,
  color: kDarkGrey,
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
    color: Colors.black);

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

const countryCodesList = ['MN', 'SG', 'MY'];
const genderList = ['male', 'female', 'others'];
const activityTypeMap = <String, String>{
  'scholarship': 'Scholarship',
  'internship': 'Internship',
  'mentorship': 'Mentorship',
  'onlineCourse': 'Online Courses',
  'offlineCourse': 'Offline Courses',
  'volunteering': 'Volunteering',
  'sports': 'Sports',
};

const int backendSkipLimit = 10;

const String cdnLeadingUrl = "https://cdn.eq-lab-dev.me/";
const String placeholderDisplayPicUrl = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
const String placeholderActivityPicUrl = 'https://media.gettyimages.com/photos/in-this-image-released-on-may-13-marvel-shang-chi-super-hero-simu-liu-picture-id1317787772?s=612x612';
const String placeholderVolunteerPicUrl = 'https://cdn.pixabay.com/photo/2017/02/10/12/12/volunteer-2055042_1280.png';

String getCapitalizeString({required String str}) {
  if (str.length <= 1) { return str.toUpperCase(); }
  return '${str[0].toUpperCase()}${str.substring(1)}';
}

String formatExceptionMessage(String str) {
  int idx = str.indexOf(":");
  return str.substring(idx + 1).trim();
}