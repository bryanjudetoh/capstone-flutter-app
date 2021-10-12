import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:http/http.dart' as http;
import 'package:youthapp/utilities/navigation-service.dart';

import '../constants.dart';

class RefreshTokenRetryPolicy extends RetryPolicy {
  @override
  int get maxRetryAttempts => 3;
  final Map<String, int> currentRetryAttempt = {
    'currentAttempt' : 0,
  };
  final SecureStorage secureStorage = SecureStorage();

  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData data) async {
    if (data.statusCode == 401) {
      print('doing 401 intercept');
      currentRetryAttempt['currentAttempt'] = currentRetryAttempt['currentAttempt']! + 1;
      print('current retry attempt: ${currentRetryAttempt['currentAttempt']}');
      final String refreshToken = await secureStorage.readSecureData('refreshToken');

      final body = jsonEncode(<String, String>{
        'token': refreshToken,
      });

      final response = await http.post(
        Uri.parse('https://eq-lab-dev.me/api/auth/refresh'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var token = responseBody['token'];

        secureStorage.writeSecureData('accessToken', token['accessToken']);
        secureStorage.writeSecureData('refreshToken', token['refreshToken']);

        print('successfully refreshed token');
        return true;
      }
      return false;
    }
    if (this.currentRetryAttempt['currentAttempt'] == 2) {
      print('doing force logout');
      currentRetryAttempt['currentAttempt'] = 0;
      secureStorage.deleteAllData();
      Navigator.pushNamedAndRemoveUntil(NavigationService.navigatorKey.currentContext!, '/welcome', (route) => false);
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: const Text(
              "ERROR: Please log in again",
              style: bodyTextStyle,
            ),
            duration: const Duration(seconds: 2),
          )
      );
    }
    return false;
  }

}