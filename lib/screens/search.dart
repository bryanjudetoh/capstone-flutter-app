import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

import 'package:http/http.dart' as http;
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/utilities/securestorage.dart';

import '../constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SecureStorage secureStorage = SecureStorage();
  List<Organisation> organisations = [];
  List<bool> isSelected = [true, false];
  bool currentSearchTypeIsOrg = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildFloatingSearchBar());
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      clearQueryOnClose: false,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) async {
        List<Organisation>? result = await performQuery(query);
        if (result != null) {
          setState(() {
            this.organisations = result;
          }); //make api call here
        }
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
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
              children: organisations.map((org) {
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
              }).toList(),
            ),
          ),
        );
      },
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 100,),
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
                        'Organisations',
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
                        'Activities',
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

  Future<List<Organisation>?> performQuery(String query) async {
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

      List<dynamic> list = jsonDecode(result);
      List<Map<String, dynamic>> resultList = [];
      for (dynamic item in list) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        resultList.add(i);
      }

      return resultList;
    } else {
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occurred during your search');
    }
  }
}
