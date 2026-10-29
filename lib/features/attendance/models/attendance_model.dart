import 'package:intl/intl.dart';
import 'package:travelPortal/core/constants/api_constants.dart';

class AttendanceRecord {
  final String date;
  final String time;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? photoPath;
  final String type;
  final int? id;
  final String? userName;

  AttendanceRecord({
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    this.latitude,
    this.longitude,
    this.photoPath,
    this.id,
    this.userName,
  });

  bool get hasNetworkPhoto =>
      photoPath != null &&
      (photoPath!.startsWith('http://') || photoPath!.startsWith('https://'));

  Map<String, dynamic> toJson() => {
        'date': date,
        'time': time,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'photo_path': photoPath,
        'type': type,
        'id': id,
        'user_name': userName,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('created_at') || json.containsKey('image_url')) {
      return AttendanceRecord.fromCheckInApi(json);
    }

    return AttendanceRecord(
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? json['check_time']?.toString() ?? '',
      location:
          json['location']?.toString() ?? json['check_location']?.toString() ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      photoPath: json['photo_path']?.toString() ?? json['photo']?.toString(),
      type: json['type']?.toString() ?? 'in',
      id: _toInt(json['id']),
      userName: json['user_name']?.toString(),
    );
  }

  factory AttendanceRecord.fromCheckInApi(Map<String, dynamic> json) {
    final createdAt = json['created_at']?.toString() ?? '';
    var time = json['time']?.toString() ?? '';
    if (time.isEmpty && createdAt.isNotEmpty) {
      time = _timeFromCreatedAt(createdAt);
    }

    return AttendanceRecord(
      id: _toInt(json['id']),
      date: json['date']?.toString() ?? '',
      time: time,
      location: json['location']?.toString() ?? '',
      photoPath: _resolveImageUrl(json),
      type: 'in',
      userName: json['user_name']?.toString(),
    );
  }

  factory AttendanceRecord.fromCheckOutApi(Map<String, dynamic> json) {
    var time = json['checkout_time']?.toString() ?? json['time']?.toString() ?? '';
    if (time.isNotEmpty) time = _formatClockTime(time);

    return AttendanceRecord(
      id: _toInt(json['id']),
      date: json['date']?.toString() ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
      time: time,
      location:
          json['checkout_location']?.toString() ?? json['location']?.toString() ?? '',
      type: 'out',
      userName: json['user_name']?.toString(),
    );
  }

  static String? _resolveImageUrl(Map<String, dynamic> json) {
    final imageUrl = json['image_url']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) return imageUrl;

    final image = json['image']?.toString();
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    return '${ApiConstants.mediaBaseUrl}$image';
  }

  static String _formatClockTime(String time) {
    for (final format in ['HH:mm:ss', 'HH:mm', 'hh:mm a']) {
      try {
        return DateFormat('hh:mm a').format(DateFormat(format).parse(time));
      } catch (_) {}
    }
    return time;
  }

  static String _timeFromCreatedAt(String createdAt) {
    for (final format in ['yyyy-MM-dd HH:mm:ss', 'yyyy-MM-dd HH:mm']) {
      try {
        return DateFormat('hh:mm a').format(DateFormat(format).parse(createdAt));
      } catch (_) {}
    }
    final parts = createdAt.split(' ');
    return parts.length > 1 ? parts[1] : createdAt;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class TodayAttendance {
  final AttendanceRecord? checkIn;
  final AttendanceRecord? checkOut;

  const TodayAttendance({this.checkIn, this.checkOut});
}
