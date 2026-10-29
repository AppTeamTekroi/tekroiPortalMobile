import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:travelPortal/core/constants/api_constants.dart';
import '../../../core/network/api_helper.dart';
import '../../../core/utils/failure.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  // ✅ GET USER LIST
  Future<Either<Failure, dynamic>> getUserList() {
    return _authService.userList();
  }

  // ✅ LOGIN
  Future<Either<Failure, Map<String, dynamic>>> login(
      String phone, String otp) {
    return _authService.login(phone, otp);
  }
}

class AuthService {
  Future<Either<Failure, dynamic>> userList() async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.usersList}',
      ));

      final response = await http.get(
        url,
        headers: ApiHelper.getHeaders(),
      );

      print('GET user list response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String,dynamic> responseData = jsonDecode(response.body);
        return Right(responseData);
      } else {
        return Left(Failure(
          statusCode: response.statusCode,
          message: 'Failed to fetch users',
        ));
      }
    } catch (e) {
      return Left(Failure(
        statusCode: 500,
        message: 'Exception: $e',
      ));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> login(String UserName, String Password) async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        '${ApiConstants.authBaseUrl}${ApiConstants.mobileLogin}',
      ));
      print('$UserName,$Password');

      final Map<String, dynamic> requestBody = {
        "user_email": UserName,
        "user_password": Password,
      };
      final response = await http.post(
        url,
        headers: ApiHelper.getHeaders(),
        body: jsonEncode(requestBody),
      );
      print("response in auth");
      print('post response ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        return Right(
            responseData); // Return successful response wrapped in Right
      } else {
        // Handle failure case
        return Left(Failure(
            statusCode: response.statusCode, message: 'Failed to login user'));
      }
    } catch (e) {
      // Catch any exceptions and rethrow
      print('Exception: $e');
      return Left(Failure(statusCode: 500, message: 'Failed to logineeee: $e'));
    }
  }
}
