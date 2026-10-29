import 'dart:io';

import 'package:get/get.dart';

import '../services/storage_service.dart';

class ApiHelper {
  static String? get _token {
    if (!Get.isRegistered<StorageService>()) return null;
    final token = Get.find<StorageService>().token?.trim();
    if (token == null || token.isEmpty) return null;
    return token;
  }

  static Map<String, String> getHeaders() {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      if (_token != null) HttpHeaders.authorizationHeader: 'Bearer $_token',
    };
  }

  /// This host's Apache drops the Authorization header before PHP.
  /// The API accepts the same bearer token as a `token` query parameter.
  static Uri withToken(Uri uri) {
    final token = _token;
    if (token == null) return uri;
    final params = Map<String, String>.from(uri.queryParameters);
    params['token'] = token;
    return uri.replace(queryParameters: params);
  }

  /// Multipart must not set Content-Type; boundary is set by the client.
  static Map<String, String> getMultipartHeaders() {
    return {
      HttpHeaders.acceptHeader: 'application/json',
      if (_token != null) HttpHeaders.authorizationHeader: 'Bearer $_token',
    };
  }
}
