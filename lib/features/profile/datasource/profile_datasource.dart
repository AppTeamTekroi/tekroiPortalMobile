import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_helper.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/failure.dart';
import '../model/profile_model.dart';
import '../model/vehicle_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  Future<Either<Failure, ProfileModel>> fetchProfile(String userId) async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        ApiConstants.baseUrl + ApiConstants.profile + userId,
      ));

      final response = await http.get(
        url,
        headers: ApiHelper.getHeaders(),
      );

      final body = jsonDecode(response.body);

      print(body);

      if (response.statusCode == 200) {
        /// ✅ Check API status
        if (body['status'] == true) {
          return Right(ProfileModel.fromJson(body));
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
        Failure(
          message: "Unexpected error: ${e.toString()}",
        ),
      );
    }
  }
}