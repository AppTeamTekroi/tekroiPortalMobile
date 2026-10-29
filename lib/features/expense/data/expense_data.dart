import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_helper.dart';
import '../../../core/utils/failure.dart';
import '../models/expenseModel.dart';

class ExpenseService {
  Map<String, String> get headers => ApiHelper.getHeaders();
  Map<String, String> get multipartHeaders => ApiHelper.getMultipartHeaders();

  /// ✅ FETCH EXPENSE LIST
  Future<Either<Failure, List<ExpenseModel>>> fetchExpenses(String userId) async {
    try {
      final response = await http.get(
        ApiHelper.withToken(Uri.parse(ApiConstants.baseUrl + ApiConstants.expenseList + userId)),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == true) {
          final List list = data['data'] ?? [];
          final expenses =
          list.map((e) => ExpenseModel.fromJson(e)).toList();

          return Right(expenses);
        } else {
          return Right([]); // ✅ no data
        }
      } else {
        return Left(
          Failure(
            message: data['message'] ?? "Server error",
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

  Future<Either<Failure, dynamic>> createExpense(
      Map<String, dynamic> payload,
      File? billFile,
      int type,
      ) async {
    try {
      final uri = ApiHelper.withToken(Uri.parse(
        ApiConstants.baseUrl + ApiConstants.createExpense,
      ));

      final request = http.MultipartRequest("POST", uri);
      request.headers.addAll(multipartHeaders);

      payload.forEach((key, value) {
        if (value == null) return;
        if (key == "entries") {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
        print("📦 FIELD => $key : ${request.fields[key]}");
      });

      request.fields["status"] = type.toString();

      if (billFile != null && billFile.path.isNotEmpty) {
        final fileName = billFile.path.split('/').last;
        print("📁 FILE PATH => ${billFile.path}");
        request.files.add(
          await http.MultipartFile.fromPath(
            "bill_receipt",
            billFile.path,
            filename: fileName,
          ),
        );
      } else {
        print("❌ No file selected");
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("✅ STATUS => ${response.statusCode}");
      print("✅ RESPONSE => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Right(data);
      } else {
        String message = response.body;
        try {
          final body = jsonDecode(response.body);
          if (body is Map) {
            message = (body['message'] ?? body['error'] ?? message).toString();
          }
        } catch (_) {}
        return Left(
          Failure(
            message: message,
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      print("❌ ERROR => $e");
      return Left(
        Failure(message: "Unexpected error: ${e.toString()}"),
      );
    }
  }

  Future<Either<Failure, dynamic>> updateExpense(
      Map<String, dynamic> payload,
      File? billFile,
      String id,
      String type,
      ) async {
    try {
      final uri = ApiHelper.withToken(Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.updateExpense}$id',
      ));

      final request = http.MultipartRequest("POST", uri);
      print(uri);
      request.headers.addAll(multipartHeaders);

      payload.forEach((key, value) {
        if (value == null) return;
        if (key == "entries") {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
        print("📦 FIELD => $key : ${request.fields[key]}");
      });
      request.fields["status"] = type.toString();
      print("📦 FIELD => status : ${request.fields["status"]}");

      if (billFile != null && billFile.path.isNotEmpty) {
        final fileName = billFile.path.split('/').last;
        print("📁 FILE PATH => ${billFile.path}");
        request.files.add(
          await http.MultipartFile.fromPath(
            "bill_receipt",
            billFile.path,
            filename: fileName,
          ),
        );
      } else {
        print("❌ No file selected");
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("✅ STATUS => ${response.statusCode}");
      print("✅ RESPONSE => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return Right(decoded);
      } else {
        String message = response.body;
        try {
          final body = jsonDecode(response.body);
          if (body is Map) {
            message = (body['message'] ?? body['error'] ?? message).toString();
          }
        } catch (_) {}
        return Left(
          Failure(
            message: message,
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      print("❌ ERROR => $e");
      return Left(
        Failure(message: "Unexpected error: ${e.toString()}"),
      );
    }
  }

  Future<Either<Failure, String>> deleteExpense(String id) async {
    try {
      final url = ApiHelper.withToken(Uri.parse(
        ApiConstants.baseUrl + ApiConstants.expenseDelete + id,
      ));

      final response = await http.delete(url, headers: headers);

      final body = jsonDecode(response.body);
      print(body);
      if (response.statusCode == 200) {
        if (body['status'] == true) {
          final travels = body["message"];
          return Right(travels);
        } else {
          return Right(body["message"]);
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
}