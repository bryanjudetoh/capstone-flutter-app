import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/securestorage.dart';
import 'package:http/http.dart' as http;

class RefreshTokenRetryPolicy extends RetryPolicy {
  @override
  int get maxRetryAttempts => 3;
  final SecureStorage secureStorage = SecureStorage();

  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData data) async {
    if (data.statusCode == 401) {
      print('doing 401 intercept');
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
      return false; //TODO need to figure out how to do a force logout here
    }
    return false;
  }

}