import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_helper.dart';
import '../../../core/utils/failure.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  Future<Either<Failure, TodayAttendance>> fetchToday(String userId) async {
    try {
      final url = ApiHelper.withToken(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.attendanceToday}')
            .replace(queryParameters: {
          'user_id': userId.trim(),
        }),
      );

      print('checkin/today → $url');

      final response = await http.get(
        url,
        headers: ApiHelper.getHeaders(),
      );

      if (response.statusCode == 404) {
        return const Right(TodayAttendance());
      }

      if (response.statusCode != 200) {
        return Left(Failure(
          message: 'Could not load attendance',
          statusCode: response.statusCode,
        ));
      }

      final body = jsonDecode(response.body);
      if (body is! Map) return const Right(TodayAttendance());
      if (body['status'] != true) return const Right(TodayAttendance());

      final data = body['data'];
      if (data is! List || data.isEmpty) {
        return const Right(TodayAttendance());
      }

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      AttendanceRecord? checkIn;
      AttendanceRecord? checkOut;

      for (final item in data) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final recordUserId = map['user_id']?.toString();
        final recordDate = map['date']?.toString();

        if (recordUserId != null &&
            recordUserId.isNotEmpty &&
            recordUserId != userId) {
          continue;
        }
        if (recordDate != null && recordDate.isNotEmpty && recordDate != today) {
          continue;
        }

        final isCheckoutOnly = map['type']?.toString() == 'out';
        if (!isCheckoutOnly) {
          checkIn = AttendanceRecord.fromCheckInApi(map);
        }
        final checkoutTime = map['checkout_time']?.toString() ?? '';
        final checkoutLocation = map['checkout_location']?.toString() ?? '';
        if (isCheckoutOnly ||
            checkoutTime.isNotEmpty ||
            checkoutLocation.isNotEmpty) {
          checkOut = AttendanceRecord.fromCheckOutApi(map);
        }
      }

      return Right(TodayAttendance(checkIn: checkIn, checkOut: checkOut));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, dynamic>> punch({
    required String type,
    required String userId,
    required String location,
    required File image,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        ApiHelper.withToken(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.attendanceCheckIn}')),
      );
      request.headers.addAll(ApiHelper.getMultipartHeaders());

      request.fields['user_id'] = userId;
      request.fields['location'] = location;
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: p.basename(image.path),
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(response.body);
      }

      return Left(Failure(
        message: response.body.isNotEmpty
            ? response.body
            : 'Attendance submit failed',
        statusCode: response.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, AttendanceRecord>> checkOut({
    required String userId,
    required String location,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        ApiHelper.withToken(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.attendanceCheckOut}')),
      );
      request.headers.addAll(ApiHelper.getMultipartHeaders());
      request.fields['user_id'] = userId;
      request.fields['checkout_location'] = location;

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final body = _decodeBody(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return Left(Failure(
          message: _messageFromBody(body) ?? 'Checkout failed',
          statusCode: response.statusCode,
        ));
      }

      if (body is Map && body['status'] == false) {
        return Left(Failure(
          message: _messageFromBody(body) ?? 'Checkout failed',
          statusCode: response.statusCode,
        ));
      }

      if (body is Map && body['data'] is Map) {
        return Right(
          AttendanceRecord.fromCheckOutApi(
            Map<String, dynamic>.from(body['data'] as Map),
          ),
        );
      }

      return Right(
        AttendanceRecord.fromCheckOutApi({
          'checkout_location': location,
        }),
      );
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  dynamic _decodeBody(String raw) {
    if (raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }

  String? _messageFromBody(dynamic body) {
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
    if (body is String && body.trim().isNotEmpty) return body;
    return null;
  }
}
