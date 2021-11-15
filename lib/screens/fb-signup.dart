import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/utilities/onboarding-params.dart';
import 'package:youthapp/widgets/alert-popup.dart';
import 'package:youthapp/widgets/text-button.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FbSignUpScreen extends StatefulWidget {
  const FbSignUpScreen({Key? key}) : super(key: key);

  @override
  _FbSignUpScreenState createState() => _FbSignUpScreenState();
}

class _FbSignUpScreenState extends State<FbSignUpScreen> {
  final fb = FacebookLogin();
  bool fbLogin = false;
  String fbUserId = "";
  String fbAccessToken = "";
  String firstName = "";
  String lastName = "";
  String email = "";
  String imageUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          width: 600,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.signupFB,
                        style: titleOneTextStyleBold,
                      ),
                      PlainTextButton(
                        title: 'Back',
                        func: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/welcome', (r) => false);
                        },
                        textStyle: backButtonBoldItalics,
                        textColor: kBlack,
                      ),
                    ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      this.fbLogin
                          ? "Logged in as: "
                          : "Retrieve Facebook Profile",
                      style: bodyTextStyle,
                    ),
                    Text(
                      this.fbLogin ? "${this.firstName} ${this.lastName}" : "",
                      style: bodyTextStyle,
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          if (!this.fbLogin)
                            SignInButton(
                              Buttons.FacebookNew,
                              onPressed: loginToFb,
                            ),
                          if (this.fbLogin)
                            IconButton(
                              iconSize: 150.0,
                              icon: Image.network(this.imageUrl),
                              onPressed: () {},
                            ),
                        ],
                      ),
                    ),
                    if (this.fbLogin)
                      SignInButton(
                        Buttons.FacebookNew,
                        text: "Continue With Facebook",
                        onPressed: proceedToOnboarding,
                      )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[],
                ),
              ]),
        ),
      ),
    );
  }

  void loginToFb() async {
    // Log in
    var res;
    try {
      res = await fb.logIn(permissions: [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ]);
    } on Exception catch (err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertPopup(
              title: "Error",
              desc: formatExceptionMessage(err.toString()),
            );
          });
    }

    // Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:
        // Logged in
        final fbUserId = res.accessToken!.userId;
        final accessToken = res.accessToken!.token;

        // Get name
        final profile = await fb.getUserProfile();

        final firstName = profile!.firstName;
        final lastName = profile.lastName;

        // Get Email
        final email = await fb.getUserEmail();

        // Get Profile Pic
        final imageUrl = await fb.getProfileImageUrl(width: 200);

        setState(() {
          this.fbLogin = true;
          this.fbUserId = fbUserId;
          this.fbAccessToken = accessToken;
          this.firstName = firstName!;
          this.lastName = lastName!;
          this.email = email!;
          this.imageUrl = imageUrl!;
        });

        break;
      case FacebookLoginStatus.cancel:
        // User cancel log in
        break;
      case FacebookLoginStatus.error:
        // Log in failed

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertPopup(
                title: "Error",
                desc: res.error.toString(),
              );
            });
        break;
    }
  }

  void proceedToOnboarding() {
    if (this.fbLogin) {
      Navigator.pushNamed(context, '/onboarding',
          arguments: OnboardingParams(
              fbUserId: this.fbUserId,
              fbAccessToken: this.fbAccessToken,
              firstName: this.firstName,
              lastName: this.lastName,
              imageUrl: this.imageUrl,
              email: this.email,
              isFbLogin: true));
    }
  }

  String formatExceptionMessage(String str) {
    int idx = str.indexOf(":");
    return str.substring(idx + 1).trim();
  }
}
