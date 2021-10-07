import 'package:http_interceptor/http_interceptor.dart';
import 'package:youthapp/utilities/securestorage.dart';

class AuthHeaderInterceptor implements InterceptorContract {

  final SecureStorage secureStorage = SecureStorage();

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    final String accessToken = await secureStorage.readSecureData('accessToken');

    try {
      data.headers.addAll(<String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      });
    }
    catch (err) {
      print(err);
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async => data;



}