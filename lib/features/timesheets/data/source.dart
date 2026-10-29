



import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travelPortal/core/constants/api_constants.dart';
import 'package:travelPortal/core/network/api_helper.dart';
import 'package:travelPortal/core/utils/failure.dart';
import '../models/model.dart';

abstract class VehicleDataSourceRepository {
  Future<Either<Failure, List<User>>> Users();
  Future<Either<Failure, List<Project>>> Projects();
  Future<Either<Failure, dynamic>> timesheetslist(
    BuildContext context,
    String userId,
    String roleId, {
    String? min,
    String? max,
    String? userSelect,
  });
  Future<Either<Failure, dynamic>> leavesList(BuildContext context, String userId, String roleId);
  Future<Either<Failure, dynamic>> fetchDashboard(BuildContext context, String userId);
  Future<Either<Failure, dynamic>> summaryData(BuildContext context, String userId);
  Future<Either<Failure, dynamic>> supportData(BuildContext context, String userId);
  Future<Either<Failure, dynamic>> supportList(BuildContext context, String userId);
}

class VehicleDataSourceImpl implements VehicleDataSourceRepository {

  @override
  Future<Either<Failure, List<User>>> Users() async {
    try {
      final response = await
      http.get(
        ApiHelper.withToken(Uri.parse("${ApiConstants.baseUrl}${ApiConstants.timesheets}")),
        headers: ApiHelper.getHeaders(),
      );
      print('response of types ${response.body}');
      if (response.statusCode == 200) {
        print("Work List fetched: ${response.body}");

        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> worklist = jsonResponse['users'] ?? [];
        final List<User> workreports = worklist.map((json) {
          return User.fromJson(json);
        }).toList();
        return Right(workreports);
      } else {
        return Left(Failure(
          statusCode: response.statusCode,
          message: 'Failed to fetch Work List',
        ));
      }
    } catch (e) {
      print('Exception in source: $e');
      return Left(
          Failure(statusCode: 500, message: 'Error occurred in source: $e'));
    }
  }
  @override
  Future<Either<Failure, List<Project>>> Projects() async {
    try {
      final response = await
      http.get(
        ApiHelper.withToken(Uri.parse("${ApiConstants.baseUrl}${ApiConstants.timesheets}")),
        headers: ApiHelper.getHeaders(),
      );
      print('response of types ${response.body}');
      if (response.statusCode == 200) {
        print("Project List fetched: ${response.body}");

        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> worklist = jsonResponse['projects'] ?? [];
        final List<Project> workreports = worklist.map((json) {
          return Project.fromJson(json);
        }).toList();
        return Right(workreports);
      } else {
        return Left(Failure(
          statusCode: response.statusCode,
          message: 'Failed to fetch Work List',
        ));
      }
    } catch (e) {
      print('Exception in source: $e');
      return Left(
          Failure(statusCode: 500, message: 'Error occurred in source: $e'));
    }
  }

  @override
  Future<Either<Failure, dynamic>> timesheetslist(
    BuildContext context,
    String userId,
    String roleId, {
    String? min,
    String? max,
    String? userSelect,
  }) async {
    try {
      final week = _thisWeekRange();
      final params = <String, String>{
        'user_id': userId,
        'role_id': roleId,
        'min': (min != null && min.isNotEmpty) ? min : week.min,
        'max': (max != null && max.isNotEmpty) ? max : week.max,
        if (userSelect != null && userSelect.isNotEmpty) 'user_select': userSelect,
      };
      final url = ApiHelper.withToken(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.timesheetsJson}')
            .replace(queryParameters: params),
      );
      print('time sheets $url');

      final response = await http.get(url, headers: ApiHelper.getHeaders());

      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unauthorized access'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        return Left(Failure(statusCode: 401, message: 'Unauthorized access'));
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final dataList = jsonResponse['data'];
        if (dataList is List) {
          return Right(List<Map<String, dynamic>>.from(dataList));
        } else {
          return Left(Failure(statusCode: 500, message: 'Invalid data format'));
        }
      } else {
        return Left(Failure(
          statusCode: response.statusCode,
          message: 'Failed to fetch data',
        ));
      }
    } catch (e) {
      return Left(Failure(
        statusCode: 500,
        message: 'Error occurred: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, dynamic>> leavesList(
      BuildContext context,
      String userId,
      String roleId,
      ) async {
    try {
      final url = "${ApiConstants.baseUrl}${ApiConstants.employeeLeavesJson}?user_id=$userId&role_id=$roleId";
      print("📡 Fetching Leave List from: $url"); // 👈 print the full URL

      final response = await http.get(
        ApiHelper.withToken(Uri.parse(url)),
        headers: ApiHelper.getHeaders(),
      );

      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unauthorized access'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        return Left(Failure(statusCode: 401, message: 'Unauthorized access'));
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final dataList = jsonResponse['data'];
        if (dataList is List) {
          return Right(List<Map<String, dynamic>>.from(dataList));
        } else {
          return Left(Failure(statusCode: 500, message: 'Invalid data format'));
        }
      } else {
        return Left(Failure(
          statusCode: response.statusCode,
          message: 'Failed to fetch data',
        ));
      }
    } catch (e) {
      print("❌ Error fetching leave list: $e"); // 👈 print error for debugging
      return Left(Failure(
        statusCode: 500,
        message: 'Error occurred: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, dynamic>> summaryData(BuildContext context, String userId) async {
    try {
      final response = await http.get(
        ApiHelper.withToken(Uri.parse("${ApiConstants.baseUrl}${ApiConstants.timesheetsMonthlySummary}?user_id=$userId")),
        headers: ApiHelper.getHeaders(),
      );

      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unauthorized access'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        return Left(Failure(statusCode: 401, message: 'Unauthorized access'));
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final dataList = jsonResponse['data'];
        if (dataList is List) {
          return Right(jsonResponse);
        } else {
          return Left(Failure(statusCode: 500, message: 'Invalid data format'));
        }
      } else {
        return Left(Failure(
          statusCode: response.statusCode,
          message: 'Failed to fetch data',
        ));
      }
    } catch (e) {
      return Left(Failure(
        statusCode: 500,
        message: 'Error occurred: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, dynamic>> supportData(BuildContext context, String userId) async {
    try {
      final url = "${ApiConstants.baseUrl}${ApiConstants.supportJson}?user_id=$userId";
      print("supportdata $url");
      final response = await http.get(
        ApiHelper.withToken(Uri.parse(url)),
        headers: ApiHelper.getHeaders(),
      );

      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unauthorized access'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        return Left(Failure(statusCode: 401, message: 'Unauthorized access'));
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final dataList = jsonResponse['data'];
        if (dataList is List) {
          return Right(jsonResponse);
        } else {
          return Left(Failure(statusCode: 500, message: 'Invalid data format'));
        }
      } else {
        return Left(Failure(
          statusCode: response.statusCode,
          message: 'Failed to fetch data',
        ));
      }
    } catch (e) {
      return Left(Failure(
        statusCode: 500,
        message: 'Error occurred: $e',
      ));
    }
  }


  @override
  Future<Either<Failure, dynamic>> fetchDashboard(
      BuildContext context, String userId) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.indexJson}?user_id=$userId';
      print("dashboard $url");
      final response = await http.get(
        ApiHelper.withToken(Uri.parse(url)),
        headers: ApiHelper.getHeaders(),
      );

      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unauthorized access'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        // Handle unauthorized
        return Left(Failure(statusCode: 401, message: 'Unauthorized'));
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Right(jsonResponse);
      } else {
        return Left(Failure(
            statusCode: response.statusCode,
            message: 'Fetch failed: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure(statusCode: 500, message: 'Error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Domain>>> supportList(BuildContext context, String userId) async {
    try {
      final url = "${ApiConstants.baseUrl}${ApiConstants.supportJson}?user_id=$userId";
      print("Support $url");
      final response = await
      http.get(
        ApiHelper.withToken(Uri.parse(url)),
        headers: ApiHelper.getHeaders(),
      );
      print('response of types ${response.body}');
      if (response.statusCode == 200) {
        print("Project List fetched: ${response.body}");

        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> worklist = jsonResponse['domains'] ?? [];
        final List<Domain> workreports = worklist.map((json) {
          return Domain.fromJson(json);
        }).toList();
        return Right(workreports);
      } else {
        return Left(Failure(
          statusCode: response.statusCode,
          message: 'Failed to fetch Work List',
        ));
      }
    } catch (e) {
      print('Exception in source: $e');
      return Left(
          Failure(statusCode: 500, message: 'Error occurred in source: $e'));
    }
  }

}

({String min, String max}) _thisWeekRange() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = today.subtract(Duration(days: today.weekday - 1));
  final end = start.add(const Duration(days: 6));
  String ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  return (min: ymd(start), max: ymd(end));
}