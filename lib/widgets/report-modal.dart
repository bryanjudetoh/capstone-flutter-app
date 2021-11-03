import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http_interceptor/http/intercepted_http.dart';

import '../constants.dart';

class ReportModal extends StatefulWidget {
  const ReportModal({Key? key, required this.reportedContentId, required this.reportTypes, required this.http, required this.isPost}) : super(key: key);

  final String reportedContentId;
  final List<String> reportTypes;
  final InterceptedHttp http;
  final bool isPost;

  @override
  _ReportModalState createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  final _formkey = GlobalKey<FormState>();
  late String selectedReportType;
  late TextEditingController reportReasonController;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    this.selectedReportType = '';
    this.reportReasonController = TextEditingController();
    this.pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    this.reportReasonController.dispose();
    this.pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: PageView(
        children: [
          reportMainPage(),
          submitReportPage(),
        ],
        controller: this.pageController,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  void changePage(int page) {
    pageController.jumpToPage(page);
  }

  Widget reportMainPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ExpansionTile(
            leading: Icon(Icons.report_problem_outlined, color: Colors.redAccent,),
            title: Text('Report ${widget.isPost ? 'Post' : 'Comment'}', style: bodyTextStyleBold,),
            trailing: Icon(Icons.arrow_drop_down),
            children: [
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.reportTypes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('${widget.reportTypes[index]}', style: bodyTextStyle,),
                      onTap: () {
                        setState(() {
                          this.selectedReportType = widget.reportTypes[index];
                        });
                        changePage(1);
                      },
                    );
                  }
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget submitReportPage() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        changePage(0);
                      },
                      icon: Icon(Icons.arrow_back_outlined)),
                  Text('Reason: ${this.selectedReportType}', style: bodyTextStyle,),
                ],
              ),
              TextButton(
                child: Text('Submit', style: smallBodyTextStyleBold,),
                onPressed: () async {
                  if (this._formkey.currentState!.validate()) {
                    String message = '';
                    try {
                      message = await doReport(this.reportReasonController.text, this.selectedReportType);
                      Navigator.pop(context);
                    }
                    on Exception catch (err) {
                      message = formatExceptionMessage(err.toString());
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            message,
                            style: bodyTextStyle,
                          ),
                          duration: const Duration(seconds: 3),
                        )
                    );
                  }
                },
              ),
            ],
          ),
          Form(
            key: _formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  maxLines: 4,
                  controller: this.reportReasonController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Why are you reporting this ${widget.isPost ? 'post' : 'comment'}?',
                    contentPadding: EdgeInsets.all(12),
                  ),
                  validator: RequiredValidator(errorText: "* Required"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> doReport(String reason, String type) async {
    var response = await widget.http.post(
      Uri.parse('https://eq-lab-dev.me/api/social-media/mp/${widget.isPost ? 'post' : 'comment'}/${widget.reportedContentId}/report'),
      body: jsonEncode(<String, String> {
        'reason': reason,
        'type': type,
      }),
    );

    if (response.statusCode == 201) {
      var result = jsonDecode(response.body);
      print(result);
      return 'Successfully reported this ${widget.isPost ? 'post' : 'comment'}';
    }
    else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      print(result);
      return result['error']['message'];
    }
    else {
      var result = jsonDecode(response.body);
      print(response.statusCode);
      print(result);
      throw Exception('A problem occurred while reporting this ${widget.isPost ? 'post' : 'comment'}');
    }
  }
}
