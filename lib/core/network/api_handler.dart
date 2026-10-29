import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../utils/failure.dart';

class ApiHandler {
  static Either<Failure, dynamic> handleResponse(http.Response response) {
    try {
      final statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 201) {
        return Right(json.decode(response.body));
      }

      if (statusCode == 401) {
        return Left(Failure(
          statusCode: 401,
          message: 'Unauthorized',
        ));
      }

      return Left(Failure(
        statusCode: statusCode,
        message: 'Something went wrong',
      ));
    } catch (e) {
      return Left(Failure(
        statusCode: 500,
        message: 'Parsing error',
      ));
    }
  }
}
