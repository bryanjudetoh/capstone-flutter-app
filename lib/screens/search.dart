import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

import 'package:http/http.dart' as http;
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SecureStorage secureStorage = SecureStorage();
  List<Organisation> organisations = [];
  List<Activity> activities = [];
  List<bool> isSelected = [true, false];
  bool currentSearchTypeIsOrg = true;
  bool currentActivitySearchTypeIsActivity = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: buildFloatingSearchBar(),
        )
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: currentSearchTypeIsOrg ? 'Search organisations by name...' :
        currentActivitySearchTypeIsActivity ? 'Search activities by name...' : 'Search activities by organisation...',
      clearQueryOnClose: false,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      height: 65,
      debounceDelay: const Duration(milliseconds: 500),
      onFocusChanged: (isFocused) {
        if (!isFocused) {
          setState(() {
            this.organisations = [];
            this.activities = [];
          });
        }
      },
      onQueryChanged: (query) async {
        if (currentSearchTypeIsOrg) {
          List<Organisation>? result = await performOrganisationsQuery(query);
          if (result != null) {
            setState(() {
              this.organisations = result;
            });
          }
        } else {
          List<Activity>? result = await performActivitiesQuery(query);
          if (result != null) {
            setState(() {
              this.activities = result;
            });
          }
        }
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        if (!currentSearchTypeIsOrg)
          FloatingSearchBarAction(
            showIfOpened: false,
            child: TextButton(
              child: Text( currentActivitySearchTypeIsActivity ? 'ACT' : 'ORG', style: smallBodyTextStyleBold,),
              onPressed: () {
                setState(() {
                  currentActivitySearchTypeIsActivity = !currentActivitySearchTypeIsActivity;
                });
              },
            ),
          ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: currentSearchTypeIsOrg ?
              getOrganisationsResultList(this.organisations) :
              getActivitiesResultList(this.activities),
            ),
          ),
        );
      },
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 85,),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        primary: currentSearchTypeIsOrg ? kLightBlue : kBluishWhite,
                      ),
                      onPressed: () {
                        setState(() {
                          currentSearchTypeIsOrg = true;
                          print(currentSearchTypeIsOrg);
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.organisation,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 17.0,
                          height: 1.25,
                          color: currentSearchTypeIsOrg ? kWhite : kLightBlue,
                        ),
                      )),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        primary: currentSearchTypeIsOrg ? kBluishWhite : kLightBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          currentSearchTypeIsOrg = false;
                          print(currentSearchTypeIsOrg);
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.activities,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 17.0,
                          height: 1.25,
                          color: currentSearchTypeIsOrg ? kLightBlue : kWhite,
                        ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Organisation>?> performOrganisationsQuery(String query) async {
    List<Map<String, dynamic>>? result = await doSearchOrganisations(query);
    if (result == null) {
      return null;
    }
    List<Organisation> organisations = [];
    for (Map<String, dynamic> org in result) {
      organisations.add(Organisation.fromJson(org));
    }
    return organisations;
  }

  Future<List<Map<String, dynamic>>?> doSearchOrganisations(String query) async {
    final String accessToken =
        await secureStorage.readSecureData('accessToken');

    var request = http.Request('GET',
        Uri.parse('https://eq-lab-dev.me/api/mp/org/list?name=' + query));
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(jsonDecode(result));

      List<dynamic> orgList = jsonDecode(result);
      List<Map<String, dynamic>> orgResultList = [];
      for (dynamic item in orgList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        orgResultList.add(i);
      }

      return orgResultList;
    } else {
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occurred during your search');
    }
  }

  Future<List<Activity>?> performActivitiesQuery(String query) async {
    List<Map<String, dynamic>>? result = await doSearchActivities(query);

    if (result == null) {
      return null;
    }
    List<Activity> activities = [];
    for (Map<String, dynamic> act in result) {
      activities.add(Activity.fromJson(act));
    }
    return activities;
  }

  Future<List<Map<String, dynamic>>?> doSearchActivities(String query) async {
    final String accessToken = await secureStorage.readSecureData('accessToken');
    String uri = '';

    if (currentActivitySearchTypeIsActivity) {
      uri = 'https://eq-lab-dev.me/api/activity-svc/mp/activity/search?actName=' + query + '&orgName=';
    } else {
      uri = 'https://eq-lab-dev.me/api/activity-svc/mp/activity/search?actName=&orgName=' + query;
    }

    var request = http.Request('GET',
        Uri.parse(uri));
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(jsonDecode(result));

      List<dynamic> activityList = jsonDecode(result);
      List<Map<String, dynamic>> activityResultList = [];
      for (dynamic item in activityList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        activityResultList.add(i);
      }

      return activityResultList;
    } else {
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occurred during your search');
    }
  }

  List<ListTile> getOrganisationsResultList(List<Organisation> organisations) {
    return organisations.map((org) {
      return ListTile(
        title: Text(
          org.name,
          style: bodyTextStyle,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/organisation-details',
              arguments: org.id);
        },
      );
    }).toList();
  }

  List<ListTile> getActivitiesResultList(List<Activity> activities) {
    return activities.map((act) {
      return ListTile(
        title: Text(
          act.name,
          style: bodyTextStyle,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/activity-details',
              arguments: act.id);
        },
      );
    }).toList();
  }
}
