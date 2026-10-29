import 'package:http/http.dart' as http;
import 'api_helper.dart';

class ApiClient {
  Future<http.Response> post(String url, {dynamic body}) async {
    final headers = ApiHelper.getHeaders();
    return http.post(
      ApiHelper.withToken(Uri.parse(url)),
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> get(String url) async {
    final headers = ApiHelper.getHeaders();
    return http.get(ApiHelper.withToken(Uri.parse(url)), headers: headers);
  }
}
