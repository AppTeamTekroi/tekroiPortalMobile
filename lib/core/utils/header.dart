import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
class ApiHelper {
  final storage = Get.find();

   Future<Map<String, String>> getHeaders() async {
    final token = storage.token;
    print('in headerfiles ---$token');
    final headers = <String, String>{};
    if (token != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    headers[HttpHeaders.contentTypeHeader] = 'application/json';
    headers[HttpHeaders.acceptHeader] = 'application/json';
    return headers;
  }
}