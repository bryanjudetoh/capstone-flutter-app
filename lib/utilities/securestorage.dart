import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage{

  final _storage = FlutterSecureStorage();

  Future writeSecureData(String key, dynamic value)  async {
    var writeData = await _storage.write(key: key, value: value);
    return writeData;
  }

  Future<String> readSecureData(String key) async {
    var readData = await _storage.read(key: key);
    if (readData == null) {
      return '';
    } else {
      return readData;
    }
  }

  Future deleteSecureData(String key) async{
    var deleteData = await _storage.delete(key: key);
    return deleteData;
  }

  void deleteAllData() async {
    _storage.deleteAll();
  }

}