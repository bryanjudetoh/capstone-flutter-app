import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/widgets/text-button.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InitOrganisationDetailsScreen extends StatelessWidget {
  InitOrganisationDetailsScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    final String orgId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Organisation>(
        future: initOrganisationData(orgId),
        builder: (BuildContext context, AsyncSnapshot<Organisation> snapshot) {
          if (snapshot.hasData) {
            Organisation org = snapshot.data!;
            return OrganisationDetailsScreen(org: org);
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: titleTwoTextStyleBold,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Loading...',
                      style: titleTwoTextStyleBold,
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<Organisation> initOrganisationData(String orgId) async {
    final response = await http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/org/' + orgId),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      return Organisation.fromJson(responseBody);
    } else {
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}

class OrganisationDetailsScreen extends StatefulWidget {
  const OrganisationDetailsScreen({Key? key, required this.org})
      : super(key: key);

  final Organisation org;
  final placeholderOrgProfilePicUrl = placeholderDisplayPicUrl;

  @override
  _OrganisationDetailsScreenState createState() =>
      _OrganisationDetailsScreenState();
}

class _OrganisationDetailsScreenState extends State<OrganisationDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.organisationDetails,
                      style: titleOneTextStyle,
                    ),
                    PlainTextButton(
                      title: 'Back',
                      func: () {
                        Navigator.of(context).pop();
                      },
                      textStyle: backButtonBoldItalics,
                      textColor: kBlack,
                    ),
                  ]),
              SizedBox(
                height: 20.0,
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                              widget.org.orgDisplayPicUrl!.isNotEmpty ?
                              widget.org.orgDisplayPicUrl! : widget.placeholderOrgProfilePicUrl
                          ),
                          maxRadius: 50,
                        ),
                        SizedBox(width: 20,),
                        Text(
                          '${widget.org.name}',
                          style: titleTwoTextStyleBold,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      '${widget.org.email}',
                      style: titleThreeTextStyle,
                    ),
                    Text(
                      '${widget.org.website}',
                      style: titleThreeTextStyle,
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Country code: ${widget.org.countryCode}',
                          style: captionTextStyle,
                        ),
                        SizedBox(width: 20,),
                        Text(
                          'Categories: ${widget.org.orgTags!.isNotEmpty ? widget.org.orgTags.toString().substring(1, widget.org.orgTags.toString().length -1) : 'None'}',
                          style: captionTextStyle,
                        ),
                      ],
                    ),
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
