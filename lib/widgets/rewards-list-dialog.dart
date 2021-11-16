import 'package:flutter/material.dart';
import 'package:youthapp/models/claimed-reward.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';

import '../constants.dart';

class RewardsListDialog extends StatefulWidget {
  const RewardsListDialog({Key? key, required this.inAppRewardsList, required this.updateSelectedRewardIndex}) : super(key: key);

  final List<ClaimedReward> inAppRewardsList;
  final Function updateSelectedRewardIndex;

  @override
  _RewardsListDialogState createState() => _RewardsListDialogState();
}

class _RewardsListDialogState extends State<RewardsListDialog> {
  late int selectedRewardIndex;

  @override
  void initState() {
    super.initState();
    selectedRewardIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.5,
      width: MediaQuery.of(context).size.width*0.6,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.inAppRewardsList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: index == this.selectedRewardIndex ? kLightBlue : Colors.white),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.inAppRewardsList[index].reward.name}',
                      style: bodyTextStyleBold,
                    ),
                    Text(
                      'Discount: ${widget.inAppRewardsList[index].reward.discount != null
                          ? '\$${widget.inAppRewardsList[index].reward.discount!.toStringAsFixed(2)}'
                          : '\$0.00'
                      }',
                      style: subtitleTextStyle,
                    ),
                    Text(
                      'Expires on: ${dateFormat.format(widget.inAppRewardsList[index].expiryDate!)}',
                      style: subtitleTextStyle,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    this.selectedRewardIndex = index;
                  });
                  widget.updateSelectedRewardIndex(index);
                },
              ),
            );
          }
      ),
    );
  }
}