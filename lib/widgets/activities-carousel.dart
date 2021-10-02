import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youthapp/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youthapp/models/activity.dart';

class ActivitiesCarousel extends StatefulWidget {
  const ActivitiesCarousel({Key? key, required this.title, required this.seeAllFunc, required this.activityList}) : super(key: key);

  final String title;
  final VoidCallback seeAllFunc;
  final String placeholderPicUrl = 'https://media.gettyimages.com/photos/in-this-image-released-on-may-13-marvel-shang-chi-super-hero-simu-liu-picture-id1317787772?s=612x612';
  final List<Activity> activityList;

  @override
  _ActivitiesCarouselState createState() => _ActivitiesCarouselState();
}

class _ActivitiesCarouselState extends State<ActivitiesCarousel> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(widget.title, style: titleThreeTextStyleBold,),
            TextButton(
                onPressed: widget.seeAllFunc,
                child: Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context)!.seeMore, style: smallBodyTextStyleBold,),
                    Icon(Icons.navigate_next_rounded),
                  ],
                ),
            ),
          ],
        ),
        Column(
          children: [
            if (widget.activityList.length > 0)
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: false,
                  enableInfiniteScroll: false,
                  // enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(
                          () {
                        _currentIndex = index;
                      },
                    );
                  },
                ),
                items: widget.activityList
                    .map(
                      (item) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {print('tapped');},
                      child: Card(
                        margin: EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        elevation: 6.0,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Image.network( //need to change to Image.network, where item = url string
                                item.mediaContentUrls!.isEmpty ? widget.placeholderPicUrl : item.mediaContentUrls![0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  '${item.name}',
                                  style: TextStyle( //need to change to constant TextStyles
                                    fontFamily: 'SF Display Pro',
                                    fontSize: 16.0,
                                    backgroundColor: Colors.black45,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.activityList.map((urlOfItem) {
                int index = widget.activityList.indexOf(urlOfItem);
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Color.fromRGBO(0, 0, 0, 0.8)
                        : Color.fromRGBO(0, 0, 0, 0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
