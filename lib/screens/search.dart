import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:youthapp/widgets/alert-popup.dart';

import 'package:youthapp/widgets/text-button.dart';

import '../constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SecureStorage secureStorage = SecureStorage();
  List<Organisation> organisations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildFloatingSearchBar()
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
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
          });//make api call here
        }
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.clear),
            onPressed: () {}, //delete all input
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
              children: organisations.map((org) {
                return ListTile(
                  title: Text(org.name, style: bodyTextStyle,),
                  onTap: () {},
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<List<Organisation>?> performQuery(String query) async {
    List<Map<String, dynamic>>? result = await doSearch(query);
    if (result == null) {
      return null;
    }
    List<Organisation> organisations = [];
    for (Map<String, dynamic> org in result) {
      organisations.add(Organisation.fromJson(org));
    }
    return organisations;
  }

  Future<List<Map<String, dynamic>>?> doSearch(String query) async {
    final String accessToken = await secureStorage.readSecureData('accessToken');

    var request = http.Request('GET', Uri.parse('https://eq-lab-dev.me/api/mp/org/list?name=' + query));
    request.headers.addAll(
        <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        }
    );
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
    }
    else {
      String result = await response.stream.bytesToString();
      print(result);
      throw Exception('A problem occurred during your search');
    }
  }
}
