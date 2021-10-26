import 'package:flutter/material.dart';
import 'package:youthapp/models/user.dart';

import '../constants.dart';

class SocialMediaScreenBody extends StatefulWidget {
  const SocialMediaScreenBody({Key? key,required this.user}) : super(key: key);

  final User user;

  @override
  _SocialMediaScreenBodyState createState() => _SocialMediaScreenBodyState();
}

class _SocialMediaScreenBodyState extends State<SocialMediaScreenBody> with TickerProviderStateMixin {

  bool currentTabIsPost = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: false,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Social Media',
                            style: titleOneTextStyleBold,
                          ),
                          IconButton(
                            onPressed: () {
                              //Navigator.of(context).pushNamed('/search-friends');
                            },
                            icon: Icon(Icons.search),
                            iconSize: 30,
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  primary: this.currentTabIsPost ? kLightBlue : kBluishWhite,
                                ),
                                onPressed: () {
                                  setState(() {
                                    this.currentTabIsPost = true;
                                  });
                                },
                                child: Text(
                                  'Posts',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 17.0,
                                    height: 1.25,
                                    color: this.currentTabIsPost ? kWhite : kLightBlue,
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
                                  primary: this.currentTabIsPost ? kBluishWhite : kLightBlue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    this.currentTabIsPost = false;
                                  });
                                },
                                child: Text(
                                  'Friends',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 17.0,
                                    height: 1.25,
                                    color: this.currentTabIsPost ? kLightBlue : kWhite,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                expandedHeight: 160.0,
                bottom: TabBar(
                  unselectedLabelColor: Colors.blueGrey,
                  indicatorColor: kLightBlue,
                  labelColor: kLightBlue,
                  tabs: [
                    Tab(child: Text('${this.currentTabIsPost ? 'Feed' : 'My Friends'}', style: bodyTextStyle,)),
                    Tab(child: Text('${this.currentTabIsPost ? 'My Posts' : 'Requests'}', style: bodyTextStyle,)),
                  ],
                  controller: this.tabController,
                ),
              )
            ];
          },
          body: TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                child: this.currentTabIsPost
                    ? Center(
                        child: Text('This is Feed', style: bodyTextStyle,),
                      )
                    : Center(
                        child: Text('This is My Friends', style: bodyTextStyle,),
                      )
                ,
              ),
              Container(
                child: this.currentTabIsPost
                    ? Center(
                        child: Text('This is My Posts', style: bodyTextStyle,),
                      )
                    : Center(
                        child: Text('This is Requests', style: bodyTextStyle,),
                      )
                ,
              ),
            ],
          ),
      ),
    );
  }
}
