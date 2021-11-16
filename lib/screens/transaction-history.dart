import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/models/transaction.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

import '../constants.dart';

class InitTransactionHistoryScreen extends StatelessWidget {
  InitTransactionHistoryScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Transaction>>(
        future: retrieveTransactionHistory(),
        builder: (BuildContext context, AsyncSnapshot<List<Transaction>> snapshot) {
          if (snapshot.hasData) {
            List<Transaction> transactionList = snapshot.data!;
            return TransactionHistoryScreen(transactionList: transactionList,);
          }
          else if (snapshot.hasError) {
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
          }
          else {
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

  Future<List<Transaction>> retrieveTransactionHistory() async {
    var response = await this.http.get(
        Uri.parse('https://eq-lab-dev.me/api/payment/mp/transaction/list?cancelledTxn=false'),
    );

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      List<Transaction> transactionList = [];
      for (dynamic item in resultList) {
        Map<String, dynamic> i = Map<String, dynamic>.from(item);
        //print(i);
        transactionList.add(Transaction.fromJson(i));
      }

      return transactionList;
    }
    else {
      var result = jsonDecode(response.body);
      print('retrieveTransactionHistory error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      throw Exception('A problem occured while retrieving your transaction history');
    }
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key, required this.transactionList}) : super(key: key);

  final List<Transaction> transactionList;

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: kBlack,
                          size: 25,
                        )
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                      primary: kGrey,
                    ),
                  ),
                  Text(
                    'Transaction History',
                    style: titleOneTextStyleBold,
                  ),
                  Flexible(
                    child: SizedBox(width: 65),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              displayTransactionHistory(),
            ]
          ),
        ),
      ),
    );
  }

  Widget displayTransactionHistory() {
    if (widget.transactionList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.2,),
            Icon(
              Icons.sentiment_dissatisfied_sharp,
              size: 100,
            ),
            SizedBox(height: 20,),
            Text('No transaction history found!', style: titleThreeTextStyle,),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.transactionList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                      context,
                      '/transaction-details',
                      arguments: widget.transactionList[index].transactionId);
                  },
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.6,
                        child: Text(
                          '${widget.transactionList[index].details!['activityName']}',
                          style: titleThreeTextStyle,
                        ),
                      ),
                      SizedBox(height: 15,),
                      Text(
                        '${dateTimeFormat.format(widget.transactionList[index].transactedDate!.toLocal())}',
                        style: subtitleTextStyle,
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${widget.transactionList[index].amount!['currency']} \$${(widget.transactionList[index].amount!['value'])!.toStringAsFixed(2)}',
                        style: bodyTextStyle,
                      ),
                      Text(
                        '[${transactionTypeMap[widget.transactionList[index].status]}]',
                        style: smallSubtitleTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
              if (index < widget.transactionList.length - 1)
                Divider(
                  height: 30,
                  thickness: 1,
                  color: Colors.black54,
                ),
            ],
          ),
        );
      },
    );
  }
}
