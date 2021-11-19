import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/models/transaction.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/authheader-interceptor.dart';
import 'package:youthapp/utilities/date-time-formatter.dart';
import 'package:youthapp/utilities/refreshtoken-interceptor.dart';

import '../constants.dart';

class InitTransactionDetailsScreen extends StatelessWidget {
  InitTransactionDetailsScreen({Key? key}) : super(key: key);

  final http = InterceptedHttp.build(
    interceptors: [
      AuthHeaderInterceptor(),
    ],
    retryPolicy: RefreshTokenRetryPolicy(),
  );

  @override
  Widget build(BuildContext context) {
    final String transactionId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: initTransactionDetailsData(transactionId),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!;
            return TransactionDetailsScreen(txn: data['txn'], org: data['org'],);
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

  Future<Map<String, dynamic>> initTransactionDetailsData(String transactionId) async {
    Map<String, dynamic> data = {};
    Transaction txn = await retrieveTransactionDetails(transactionId);
    String orgId = txn.payTo!['refId']!;
    data['txn'] = txn;
    data['org'] = await getOrganisationDetails(orgId);
    return data;
  }

  Future<Transaction> retrieveTransactionDetails(String transactionId) async {
    var response = await this.http.get(
        Uri.parse('https://eq-lab-dev.me/api/payment/mp/transaction/$transactionId'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      return Transaction.fromJson(responseBody);
    }
    else {
      var result = jsonDecode(response.body);
      print('retrieveTransactionDetails error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      throw Exception('A problem occured while retrieving this transaction details');
    }
  }

  Future<Organisation> getOrganisationDetails(String orgId) async {
    final response = await http.get(
      Uri.parse('https://eq-lab-dev.me/api/mp/org/' + orgId),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      //print(responseBody);
      return Organisation.fromJson(responseBody);
    }
    else {
      var result = jsonDecode(response.body);
      print('getOrganisationDetails error: ${response.statusCode}');
      print('error response body: ${result.toString()}');
      throw Exception(jsonDecode(response.body)['error']['message']);
    }
  }
}

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({Key? key, required this.txn, required this.org}) : super(key: key);

  final Transaction txn;
  final Organisation org;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
                    'Transaction Details',
                    style: titleOneTextStyleBold,
                  ),
                  Flexible(
                    child: SizedBox(width: 65),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment:',
                    style: titleThreeTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          '${this.txn.amount!['currency']}\$',
                          style: bodyTextStyle,
                        ),
                      ),
                      SizedBox(width: 5,),
                      Text(
                        '${this.txn.amount!['value']!.toStringAsFixed(2)}',
                        style: largeTitleTextStyle,
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status:',
                    style: titleThreeTextStyle,
                  ),
                  SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${transactionTypeMap[this.txn.status]}', style: titleThreeTextStyle,),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/activity-details', arguments: this.txn.details!['refId']);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity:',
                      style: titleThreeTextStyle,
                    ),
                    SizedBox(height: 10,),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          alignment: Alignment.centerRight,
                          width: MediaQuery.of(context).size.width*0.5,
                          child: Text(
                            '${this.txn.details!['activityName']}',
                            style: titleThreeTextStyle,
                            textAlign: TextAlign.right,
                          ),
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              if (this.txn.discount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discount:',
                      style: titleThreeTextStyle,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Value: '
                            '${this.txn.discount!['currency']} '
                            '\$${this.txn.discount!['value']!.toStringAsFixed(2)}',
                            style: titleThreeTextStyle,
                          ),
                          Text(
                            'Reward ID: ${this.txn.discount!['rewardId']!}',
                            style: subtitleTextStyle,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paid to:',
                    style: titleThreeTextStyle,
                  ),
                  SizedBox(height: 15,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                            this.org.orgDisplayPicUrl!.isNotEmpty ?
                            this.org.orgDisplayPicUrl! : placeholderDisplayPicUrl
                        ),
                        maxRadius: 40,
                      ),
                      SizedBox(width: 20,),
                      Container(
                        width: MediaQuery.of(context).size.width*0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${this.org.name}',
                              style: titleTwoTextStyle,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${this.org.email}',
                              style: subtitleTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${this.org.website}',
                              style: subtitleTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 20,),
              if (this.txn.paymentChannel != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paid by:', style: titleThreeTextStyle,),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        child: this.txn.paymentChannel == 'paypal'
                            ? Image.network(
                                'https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_37x23.jpg',
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                    print('bad url: https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_37x23.jpg');
                                    return const Center(
                                      child: Text('Couldn\'t load image.'),
                                    );
                                }
                            )
                            : Icon(Icons.attach_money, size: 40,),
                      )
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date and time:', style: titleThreeTextStyle,),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${dateTimeFormat.format(this.txn.transactedDate!.toLocal())}', style: subtitleTextStyle,),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transaction ID:', style: titleThreeTextStyle,),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${this.txn.transactionId}', style: subtitleTextStyle,),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
