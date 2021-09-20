import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:open_mail_app/open_mail_app.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    final User user = ModalRoute.of(context)!.settings.arguments as User;
    String name = user.firstName;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Pending Verification",
                  style: xLargeTitleTextStyle,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: mediumTitleTextStyle,
                  ),
                  onPressed: () {Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);},
                  child: const Text('Back',
                    style: TextStyle( fontFamily: "SF Pro Display", fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox( height: 10.0, ),
            Column(
              children: <Widget>[
                Text(
                  'Thank you for registering, $name! Please check your email for a verification link before logging in.',
                  style: bodyTextStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox( height: 20.0, ),
                RoundedButton(
                  title: 'Go to email',
                  func: () {openEmailApp(context);},
                  colorBG: kLightBlue,
                  colorFont: kWhite,
                ),
              ],
            ),
            SizedBox( height: 10.0, ),
            SizedBox( height: 10.0, ),
          ],
        ),
      ),
    );
  }

  void openEmailApp(BuildContext context) async {
    var result = await OpenMailApp.openMailApp(
      nativePickerTitle: 'Select email app to open',
    );

    if (!result.didOpen && !result.canOpen) {
      showNoMailAppsDialog(context);
    } else if (!result.didOpen && result.canOpen) {
      showDialog(
        context: context,
        builder: (_) {
          return MailAppPickerDialog(
            mailApps: result.options,
          );
        },
      );
    }
  }
  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Open Mail App", style: mediumTitleTextStyle,),
          content: Text("No mail apps installed", style: bodyTextStyle,),
          actions: <Widget>[
            TextButton(
              child: Text("OK", style: bodyTextStyle,),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
