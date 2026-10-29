import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:travelPortal/features/travel/models/travel_model.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_helper.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/failure.dart';
import 'package:http/http.dart' as http;

class TravelService {
  Map<String, String> get headers => ApiHelper.getHeaders();

  Future<Either<Failure, List<TravelModel>>> fetchTravels(String userId) async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        ApiConstants.baseUrl + ApiConstants.travelList + userId,
      ));

      final response = await http.get(url, headers: headers);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (body['status'] == true) {
          final List list = body['data'] ?? [];
          final travels =
          list.map((e) => TravelModel.fromJson(e)).toList();

          return Right(travels);
        } else {
          return Right([]); // ✅ no data
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
      return Left(Failure(message: "Unexpected error: ${e.toString()}"));
    }
  }
  Future<Either<Failure, String>> deleteTravel(String id) async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        ApiConstants.baseUrl + ApiConstants.travelDelete + id,
      ));

      final response = await http.delete(url, headers: headers);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (body['status'] == true) {

          final travels = body["message"];

          return Right(travels);
        } else {
          return Right(body["message"]); // ✅ no data
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
      return Left(Failure(message: "Unexpected error: ${e.toString()}"));
    }
  }
  Future<Either<Failure, dynamic>> fetchCustomersAndProjects() async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        ApiConstants.baseUrl + ApiConstants.customersAndProject,
      ));

      final response = await http.get(url, headers: headers);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(body);
      } else {
        return Left(
          Failure(
            message: body['message'] ?? "Server error",
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Left(Failure(message: "Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, dynamic>> createTravel(
      Map<String, dynamic> payload,
      File? taxiBill,
      ) async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        ApiConstants.baseUrl + ApiConstants.createTravel,
      ));

      var request = http.MultipartRequest("POST", url);

      /// ✅ Headers (no JSON content-type — breaks multipart boundary)
      request.headers.addAll(ApiHelper.getMultipartHeaders());

      /// ✅ Fields
      payload.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      /// ✅ File
      if (taxiBill != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "file",
            taxiBill.path,
          ),
        );
      }

      print("===== CREATE TRAVEL REQUEST =====");
      print("URL: $url");
      print("Method: ${request.method}");
      print("Headers: ${request.headers}");
      print("Fields: ${request.fields}");
      for (var file in request.files) {
        print(
          "File -> field: ${file.field}, filename: ${file.filename}, "
              "length: ${file.length}, contentType: ${file.contentType}",
        );
      }
      print("==================================");


      final response = await request.send();

      final resBody = await response.stream.bytesToString();
      // 🔍 DEBUG PRINT for response
      print("===== CREATE TRAVEL RESPONSE =====");
      print("Status Code: ${response.statusCode}");
      print("Body: $resBody");
      print("===================================");
      final body = jsonDecode(resBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(body);
      } else {
        return Left(
          Failure(
            message: body['message'] ?? "Error",
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

  Future<Either<Failure, dynamic>> updateTravel(
      Map<String, dynamic> payload,
      File? taxiBill,
      String id,
      ) async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        ApiConstants.baseUrl + ApiConstants.updateTravel + id,
      ));

      var request = http.MultipartRequest("POST", url);

      /// ✅ Headers (no JSON content-type — breaks multipart boundary)
      request.headers.addAll(ApiHelper.getMultipartHeaders());

      /// ✅ Fields
      payload.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      /// ✅ File
      if (taxiBill != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "attachments",
            taxiBill.path,
          ),
        );
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final body = jsonDecode(resBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(body);
      } else {
        return Left(
          Failure(
            message: body['message'] ?? "Error",
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


  // Future<Either<Failure, dynamic>> createTravel(Map<String, dynamic> payload,
  //     File? taxiBill) async {
  //   try {
  //     print(ApiConstants.baseUrl + ApiConstants.createTravel);
  //     FormData formData = FormData();
  //     payload.forEach((key, value) {
  //       formData.fields.add(MapEntry(key, value.toString()));
  //     });
  //     if (taxiBill != null) {
  //       String fileName = taxiBill.path
  //           .split('/')
  //           .last;
  //
  //       formData.files.add(
  //         MapEntry(
  //           "file",
  //           await MultipartFile.fromFile(
  //             taxiBill.path,
  //             filename: fileName,
  //           ),
  //         ),
  //       );
  //     }
  //
  //     final response = await _dio.post(
  //       ApiConstants.baseUrl + ApiConstants.createTravel,
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           ...headers,
  //           "Content-Type": "multipart/form-data",
  //         },
  //       ),
  //     );
  //
  //     debugPrint(response.statusMessage);
  //     // debugPrint(response.data);
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       // debugPrint(response.data);
  //
  //       return Right(response.data);
  //     } else {
  //       // print(response.statusMessage );
  //       return Left(
  //         Failure(
  //           message: response.data["message"] ?? response.statusMessage ??
  //               "Error",
  //           statusCode: response.statusCode,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print("$e----");
  //     return Left(
  //       Failure(message: "Unexpected error: ${e.toString()}"),
  //     );
  //   }
  // }

  // Future<Either<Failure, dynamic>> updateTravel(Map<String, dynamic> payload,
  //     File? taxiBill, String id) async {
  //   try {
  //     print(ApiConstants.baseUrl + ApiConstants.updateTravel + id);
  //     FormData formData = FormData();
  //     payload.forEach((key, value) {
  //       formData.fields.add(MapEntry(key, value.toString()));
  //     });
  //     print(taxiBill?.path!);
  //
  //     if (taxiBill != null) {
  //       String fileName = taxiBill.path
  //           .split('/')
  //           .last;
  //
  //       formData.files.add(
  //         MapEntry(
  //           "attachments",
  //           await MultipartFile.fromFile(
  //             taxiBill.path,
  //             filename: fileName,
  //           ),
  //         ),
  //       );
  //     }
  //
  //     final response = await _dio.post(
  //       ApiConstants.baseUrl + ApiConstants.updateTravel + id,
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           ...headers,
  //           "Content-Type": "multipart/form-data",
  //         },
  //       ),
  //     );
  //
  //     debugPrint(response.statusMessage);
  //     // debugPrint(response.data);
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       // debugPrint(response.data);
  //
  //       return Right(response.data);
  //     } else {
  //       // print(response.statusMessage );
  //       return Left(
  //         Failure(
  //           message: response.data["message"] ?? response.statusMessage ??
  //               "Error",
  //           statusCode: response.statusCode,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print("$e----");
  //     return Left(
  //       Failure(message: "Unexpected error: ${e.toString()}"),
  //     );
  //   }
  // }
}
