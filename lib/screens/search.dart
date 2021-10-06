import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

import '../constants.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Organisation> organisations = [];
  List<Activity> activities = [];
  bool currentSearchTypeIsOrg = true;
  bool currentActivitySearchTypeIsActivity = true;
  int skip = 0;
  late bool isEndOfList;
  String currentQuery = '';
  ScrollController organisationsScrollController = new ScrollController();
  ScrollController activitiesScrollController = new ScrollController();
  ScrollController searchbarScrollController = new ScrollController();
  FloatingSearchBarController fsbController = FloatingSearchBarController();

  @override
  void initState() {
    super.initState();
    isEndOfList = false;
    searchbarScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    searchbarScrollController.removeListener(_scrollListener);
    activitiesScrollController.dispose();
    organisationsScrollController.dispose();
    searchbarScrollController.dispose();
    super.dispose();
  }

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
      controller: fsbController,
      scrollController: searchbarScrollController,
      onFocusChanged: (isFocused) {
        if (!isFocused) {
          setState(() {
            this.organisations = [];
            this.activities = [];
            this.skip = 0;
            this.isEndOfList = false;
          });
        }
      },
      onQueryChanged: (query) async {
        setState(() {
          this.skip = 0;
          this.isEndOfList = false;
        });
        if (currentSearchTypeIsOrg) {
          List<Organisation>? result = await performOrganisationsQuery(query);
          if (result != null) {
            setState(() {
              this.organisations = result;
              this.currentQuery = query;
            });
          }
        }
        else {
          List<Activity>? result = await performActivitiesQuery(query);
          if (result != null) {
            setState(() {
              this.activities = result;
              this.currentQuery = query;
            });
          }
        }
      },
      onSubmitted: (query) async {
        if (currentSearchTypeIsOrg) {
          List<Organisation>? result = await performOrganisationsQuery(query);
          if (result != null) {
            setState(() {
              this.organisations = result;
              this.currentQuery = query;
              this.skip = 0;
              this.isEndOfList = false;
            });
          }
        }
        else {
          List<Activity>? result = await performActivitiesQuery(query);
          if (result != null) {
            setState(() {
              this.activities = result;
              this.currentQuery = query;
              this.skip = 0;
              this.isEndOfList = false;
            });
          }
        }
      },
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
                  skip = 0;
                });
                fsbController.clear();
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
            child: currentSearchTypeIsOrg ?
              displayOrganisationsResultList() : displayActivitiesResultList(),
          ),
        );
      },
      isScrollControlled: true,
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
                          skip = 0;
                        });
                        fsbController.clear();
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
                          skip = 0;
                        });
                        fsbController.clear();
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

  void _scrollListener() {
    if (searchbarScrollController.position.pixels == searchbarScrollController.position.maxScrollExtent && !isEndOfList) {
      currentSearchTypeIsOrg ? loadMoreOrganisations() : loadMoreActivities();
    }
  }

  Future<List<Organisation>?> performOrganisationsQuery(String query) async {
    setState(() {
      this.currentQuery = query;
    });
    List<Map<String, dynamic>>? result = await doSearchOrganisations(query);

    if (result == null) {
      return null;
    }
    List<Organisation> organisationsList = [];
    for (Map<String, dynamic> org in result) {
      organisationsList.add(Organisation.fromJson(org));
    }
    return organisationsList;
  }

  Future<List<Map<String, dynamic>>?> doSearchOrganisations(String query) async {
    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/mp/org/list?name=$query&skip=${skip.toString()}')
    );

    if (response.statusCode == 200) {

      List<dynamic> resultList = jsonDecode(response.body);
      List<Map<String, dynamic>> mapList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        mapList.add(i);
      }
      setState(() {
        this.skip += resultList.length;
        if (resultList.length < backendSkipLimit) {
          isEndOfList = true;
        }
      });

      return mapList;
    } else {
      String result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during your search');
    }
  }

  void loadMoreOrganisations() async {
    var response = await widget.http.get(
        Uri.parse('https://eq-lab-dev.me/api/mp/org/list?name=${this.currentQuery}&skip=${skip.toString()}')
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);

      if (resultList.length > 0) {
        List<Map<String, dynamic>> mapList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String, dynamic>.from(item);
          mapList.add(i);
        }
        List<Organisation> organisationsList = [];
        for (Map<String, dynamic> org in mapList) {
          organisationsList.add(Organisation.fromJson(org));
        }
        setState(() {
          this.organisations.addAll(organisationsList.where((a) => this.organisations.every((b) => a.organisationId != b.organisationId)));
          skip += organisationsList.length;
        });
      }
      else {
        setState(() {
          this.isEndOfList = true;
        });
      }
    }
    else {
      String result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while loading more organisations for search results');
    }
  }

  ListView displayOrganisationsResultList() {
    return ListView.builder(
      controller: organisationsScrollController,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: organisations.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              this.organisations[index].name,
              style: bodyTextStyle,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/organisation-details', arguments: organisations[index].organisationId);
          },
        );
      },
    );
  }

  Future<List<Activity>?> performActivitiesQuery(String query) async {
    setState(() {
      this.currentQuery = query;
    });
    List<Map<String, dynamic>>? result = await doSearchActivities(query);

    if (result == null) {
      return null;
    }
    List<Activity> activityList = [];
    for (Map<String, dynamic> act in result) {
      activityList.add(Activity.fromJson(act));
    }
    return activityList;
  }

  Future<List<Map<String, dynamic>>?> doSearchActivities(String query) async {
    String uri = '';

    if (currentActivitySearchTypeIsActivity) {
      uri = 'https://eq-lab-dev.me/api/activity-svc/mp/activity/search?actName=$query&orgName=&skip=${skip.toString()}';
    } else {
      uri = 'https://eq-lab-dev.me/api/activity-svc/mp/activity/search?actName=&orgName=$query&skip=${skip.toString()}';
    }

    var response = await widget.http.get(
        Uri.parse(uri)
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);

      List<Map<String, dynamic>> mapList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        mapList.add(i);
      }
      setState(() {
        this.skip += resultList.length;
        if (resultList.length < backendSkipLimit) {
          isEndOfList = true;
        }
      });

      return mapList;
    }
    else {
      String result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occurred during your search');
    }
  }

  void loadMoreActivities() async {
    String uri = '';

    if (currentActivitySearchTypeIsActivity) {
      uri = 'https://eq-lab-dev.me/api/activity-svc/mp/activity/search?actName=${this.currentQuery}&orgName=&skip=${skip.toString()}';
    } else {
      uri = 'https://eq-lab-dev.me/api/activity-svc/mp/activity/search?actName=&orgName=${this.currentQuery}&skip=${skip.toString()}';
    }

    var response = await widget.http.get(
        Uri.parse(uri)
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);

      if (resultList.length > 0) {
        List<Map<String, dynamic>> mapList = [];
        for (dynamic item in resultList) {
          Map<String, dynamic> i = Map<String, dynamic>.from(item);
          mapList.add(i);
        }
        List<Activity> activityList = [];
        for (Map<String, dynamic> act in mapList) {
          activityList.add(Activity.fromJson(act));
        }
        setState(() {
          this.activities.addAll(activityList.where((a) => this.activities.every((b) => a.activityId != b.activityId)));
          skip += activityList.length;
        });
      }
      else {
        setState(() {
          this.isEndOfList = true;
          print('isEndOfList set to true');
        });
      }
    }
    else {
      String result = jsonDecode(response.body);
      print(result);
      throw Exception('A problem occured while loading more activities for search results');
    }
  }

  ListView displayActivitiesResultList() {
    return ListView.builder(
        controller: activitiesScrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: activities.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                this.activities[index].name,
                style: bodyTextStyle,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/activity-details', arguments: activities[index].activityId);
            },
          );
        }
    );
  }
}
