import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_helper.dart';
import '../../../core/utils/failure.dart';
import '../model/dashboard_model.dart';

class DashboardService {
  Map<String, String> get headers => ApiHelper.getHeaders();

  Future<Either<Failure, DashboardModel>> fetchDashboard(String id) async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        ApiConstants.baseUrl + ApiConstants.dashboard + id,
      ));

      final response = await http.get(
        url,
        headers: headers,
      );

      final body = jsonDecode(response.body);

      print(id);

      if (response.statusCode == 200) {
        /// ✅ Optional: if API has status field
        if (body['status'] == null || body['status'] == true) {
          return Right(DashboardModel.fromJson(body));
        } else {
          return Left(
            Failure(
              message: body['message'] ?? "Failed",
              statusCode: response.statusCode,
            ),
          );
        }
      } else {
        return Left(
          Failure(
            message: body['message'] ?? "Server error",
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Left(
        Failure(message: "Unexpected error: ${e.toString()}"),
      );
    }
  }
}