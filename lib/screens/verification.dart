import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/widgets/rounded-button.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:youthapp/widgets/text-button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    final User user = ModalRoute.of(context)!.settings.arguments as User;
    String name = user.firstName;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.verification,
                    style: titleOneTextStyleBold,
                  ),
                  PlainTextButton(
                    title: 'Back',
                    func: () {Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);},
                    textStyle: backButtonBoldItalics,
                    textColor: kBlack,
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
          title: Text("Open Mail App", style: titleThreeTextStyleBold,),
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
