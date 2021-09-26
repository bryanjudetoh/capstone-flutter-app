import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youthapp/constants.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/text-button.dart';
import 'package:http/http.dart' as http;

class InitOrganisationDetailsScreen extends StatelessWidget {
  InitOrganisationDetailsScreen({Key? key}) : super(key: key);

  final SecureStorage secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    final String orgId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Organisation>(
        future: retrieveOrganisation(orgId),
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

  Future<Organisation> retrieveOrganisation(String orgId) async {
    final String accessToken =
        await secureStorage.readSecureData('accessToken');
    final response = await http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/org/' + orgId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
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

  @override
  _OrganisationDetailsScreenState createState() =>
      _OrganisationDetailsScreenState();
}

class _OrganisationDetailsScreenState extends State<OrganisationDetailsScreen> {
  String? orgDisplayPicUrl = '';

  @override
  Widget build(BuildContext context) {
    if (widget.org.orgDisplayPicUrl != null) {
      this.orgDisplayPicUrl = widget.org.orgDisplayPicUrl;
    }

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
                      style: titleTwoTextStyleBold,
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
                          backgroundImage: this.orgDisplayPicUrl!.isNotEmpty
                              ? NetworkImage('https://cdn.eq-lab-dev.me/' +
                                  this.orgDisplayPicUrl!)
                              : Image.asset(
                                      'assets/images/default-profilepic.png')
                                  .image,
                          maxRadius: 40,
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
                          'Categories: ${widget.org.orgTags!.isNotEmpty ? widget.org.orgTags.toString() : 'None'}',
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
