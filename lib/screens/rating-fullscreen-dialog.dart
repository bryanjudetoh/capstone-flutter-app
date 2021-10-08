import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/participant.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

class RatingFullScreenDialog extends StatefulWidget {
  RatingFullScreenDialog({Key? key, required this.participant}) : super(key: key);

  final Participant participant;
  final String placeholderPicUrl = placeholderVolunteerPicUrl;
  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _RatingFullScreenDialogState createState() => _RatingFullScreenDialogState();
}

class _RatingFullScreenDialogState extends State<RatingFullScreenDialog> {

  double rating = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.cancel_outlined, size: 30,),
                  onPressed: () {Navigator.of(context).pop();},
                ),
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.participant.activity.mediaContentUrls!.isEmpty
                            ? widget.placeholderPicUrl
                            : widget.participant.activity.mediaContentUrls![0],
                      ),
                      backgroundColor: Colors.transparent,
                      radius: 100,
                    ),
                    SizedBox(height: 40,),
                    Text(
                      'How was your experience in ${widget.participant.activity.name}?',
                      style: titleTwoTextStyleBold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'Had a pleasant time with this activity? Share with us your thoughts!',
                      style: subtitleTextStyleBold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40,),
                    RatingBar.builder(
                        initialRating: 0.0,
                        minRating: 0.5,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (value) {
                          setState(() {
                            this.rating = value;
                          });
                        }
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: RoundedButton(
                  title: 'Submit Rating',
                  colorBG: kLightBlue,
                  colorFont: kWhite,
                  func: () => handleRating(this.rating),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void handleRating(double rating) {
    try {
      submitRating(rating);
      print('still continuing?');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success!', style: titleTwoTextStyleBold,),
              content: Text('Your rating has been submitted', style: bodyTextStyle,),
            );
          }
      );
      int count = 2;
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.of(context).popUntil((_) => count-- <= 0);
      });
    }
    on Exception catch (err) {
      int count = 3;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertPopup(
            title: 'Error',
            desc: err.toString(),
            func: () {Navigator.of(context).popUntil((_) => count-- <= 0);},
          );
        }
      );
    }
  }

  void submitRating(double rating) async {
    var response = await widget.http.post(
      Uri.parse('https://eq-lab-dev.me/api/activity-svc/mp/participant/rate/${widget.participant.participantId}'),
      body: jsonEncode(<String, dynamic>{
        'ratingValue': rating
      })
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      print(result['message']);
      return;
    }
    else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      print(result['error']['message']);
      throw Exception(result['error']['message']);
    }
    else {
      var result = jsonDecode(response.body);
      print(result['error']['message']);
      throw Exception('An error occured while trying to submit your rating');
    }
  }

}