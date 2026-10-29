import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/storage_service.dart';
import '../../../ui/widgets/loading.dart';
import '../../login/controller/login_controller.dart';
import '../data/attendance_data.dart';
import '../models/attendance_model.dart';
import '../views/attendance_camera_page.dart';

class AttendanceController extends GetxController {
  final AttendanceService _service = AttendanceService();
  final LoginController loginController = Get.find();

  final Rxn<AttendanceRecord> checkIn = Rxn<AttendanceRecord>();
  final Rxn<AttendanceRecord> checkOut = Rxn<AttendanceRecord>();
  final isSubmitting = false.obs;

  bool get isInForToday => checkIn.value != null;
  bool get isOutForToday => checkOut.value != null;

  static const _inKey = 'attendance_in';
  static const _outKey = 'attendance_out';

  @override
  void onInit() {
    super.onInit();
    loadToday();
  }

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> loadToday() async {
    await _loadLocal();
    final userId = _resolvedUserId();
    if (userId == null) return;

    final result = await _service.fetchToday(userId);
    await result.fold(
      (_) async {},
      (today) async {
        // Successful API response is source of truth — clear stale local cache.
        if (today.checkIn != null &&
            (today.checkIn!.date.isEmpty || today.checkIn!.date == _today)) {
          checkIn.value = today.checkIn;
          await _saveLocal(today.checkIn!);
        } else {
          checkIn.value = null;
          await _clearLocal(_inKey);
        }

        if (today.checkOut != null &&
            (today.checkOut!.date.isEmpty || today.checkOut!.date == _today)) {
          checkOut.value = today.checkOut;
          await _saveLocal(today.checkOut!);
        } else {
          checkOut.value = null;
          await _clearLocal(_outKey);
        }
      },
    );
  }

  String? _resolvedUserId() {
    final fromLogin = loginController.UserId?.toString();
    if (fromLogin != null && fromLogin.isNotEmpty && fromLogin != 'null') {
      return fromLogin;
    }
    final fromStorage = Get.find<StorageService>().userId?.toString();
    if (fromStorage != null && fromStorage.isNotEmpty) {
      loginController.UserId ??= int.tryParse(fromStorage);
      return fromStorage;
    }
    return null;
  }

  Future<void> punchIn() => _punch(type: 'in');

  Future<void> punchOut() async {
    if (isSubmitting.value) return;

    if (!isInForToday) {
      _snack('Check in first', 'Mark in for the day before checking out.');
      return;
    }
    if (isOutForToday) {
      _snack('Already out', 'You already checked out today.');
      return;
    }

    LoadingOverlay.show('Capturing location...');
    final location = await _currentLocation();
    LoadingOverlay.hide();

    if (location == null) {
      _snack('Location needed', 'Turn on location to check out.');
      return;
    }

    final confirmed = await _confirmCheckOut(
      time: DateFormat('hh:mm a').format(DateTime.now()),
      location: location.address,
    );
    if (confirmed != true) return;

    isSubmitting.value = true;
    LoadingOverlay.show('Checking out...');

    final userId = _resolvedUserId() ?? '';
    final apiResult = await _service.checkOut(
      userId: userId,
      location: location.apiLocation,
    );

    isSubmitting.value = false;
    LoadingOverlay.hide();
    await Future<void>.delayed(Duration.zero);

    await apiResult.fold(
      (failure) async {
        _snack('Checkout failed', failure.message);
      },
      (record) async {
        final saved = AttendanceRecord(
          date: record.date.isNotEmpty ? record.date : _today,
          time: record.time.isNotEmpty
              ? record.time
              : DateFormat('hh:mm a').format(DateTime.now()),
          location: record.location.isNotEmpty
              ? record.location
              : location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          type: 'out',
          id: record.id,
        );
        await _saveLocal(saved);
        checkOut.value = saved;
        _snack('Checked out', 'Out at ${saved.time}', error: false);
      },
    );
  }

  Future<void> _punch({required String type}) async {
    if (isSubmitting.value) return;

    if (isInForToday) {
      _snack('Already in', 'You already checked in today.');
      return;
    }

    final photo = await _capturePhoto();
    if (photo == null) return;

    LoadingOverlay.show('Capturing location...');
    final location = await _currentLocation();
    LoadingOverlay.hide();

    if (location == null) {
      _snack('Location needed', 'Turn on location to mark attendance.');
      return;
    }

    final confirmed = await _confirmPunch(
      type: type,
      photo: photo,
      time: DateFormat('hh:mm a').format(DateTime.now()),
      location: location.address,
    );
    if (confirmed != true) return;

    isSubmitting.value = true;
    LoadingOverlay.show('Marking attendance...');

    final record = AttendanceRecord(
      date: _today,
      time: DateFormat('hh:mm a').format(DateTime.now()),
      location: location.address,
      latitude: location.latitude,
      longitude: location.longitude,
      photoPath: photo.path,
      type: type,
    );

    final userId = _resolvedUserId() ?? '';
    final apiResult = await _service.punch(
      type: type,
      userId: userId,
      location: location.apiLocation,
      image: photo,
    );

    await _saveLocal(record);

    if (type == 'in') {
      checkIn.value = record;
    } else {
      checkOut.value = record;
    }

    isSubmitting.value = false;
    LoadingOverlay.hide();

    final synced = apiResult.isRight();
    if (synced && type == 'in') {
      await loadToday();
      // Keep the just-submitted punch if /today hasn't caught up yet.
      if (checkIn.value == null) {
        checkIn.value = record;
        await _saveLocal(record);
      }
    }

    // Let the loading dialog finish closing before toasting.
    await Future<void>.delayed(Duration.zero);
    if (!synced) {
      _snack(
        'Saved on this device',
        'You are ${type == 'in' ? 'in' : 'out'} for the day. Server sync can retry later.',
      );
    } else {
      _snack(
        type == 'in' ? 'You are in' : 'Checked out',
        type == 'in'
            ? 'Attendance marked for ${checkIn.value?.time ?? record.time}'
            : 'See you tomorrow. Out at ${record.time}',
        error: false,
      );
    }
  }

  Future<File?> _capturePhoto() async {
    final context = Get.overlayContext ?? Get.context;
    if (context != null && context.mounted) {
      try {
        return await Navigator.of(context, rootNavigator: true).push<File>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const AttendanceCameraPage(),
          ),
        );
      } catch (_) {}
    }

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (picked == null) return null;
      return File(picked.path);
    } catch (_) {
      _snack('Camera', 'Could not open camera. Check camera permission.');
      return null;
    }
  }

  Future<_GeoFix?> _currentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final marks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = marks.isNotEmpty ? marks.first : null;
      final address = place == null
          ? '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}'
          : _formatAddress(place);

      return _GeoFix(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        apiLocation: address,
      );
    } catch (_) {
      return null;
    }
  }

  String _formatAddress(Placemark place) {
    final parts = <String>[];
    if (place.thoroughfare?.isNotEmpty == true) {
      parts.add(place.thoroughfare!);
    } else if (place.street?.isNotEmpty == true) {
      parts.add(place.street!);
    }
    if (place.subLocality?.isNotEmpty == true) parts.add(place.subLocality!);
    if (place.locality?.isNotEmpty == true) parts.add(place.locality!);
    if (place.postalCode?.isNotEmpty == true) parts.add(place.postalCode!);
    if (place.country?.isNotEmpty == true) parts.add(place.country!);
    return parts.join(', ');
  }

  Future<bool?> _confirmPunch({
    required String type,
    required File photo,
    required String time,
    required String location,
  }) {
    return Get.bottomSheet<bool>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                type == 'in' ? 'Confirm check-in' : 'Confirm check-out',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  photo,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.access_time, time),
              const SizedBox(height: 8),
              _infoRow(Icons.location_on_outlined, location),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF069C3C),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Get.back(result: true),
                      child: Text(type == 'in' ? 'I am in' : 'Check out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<bool?> _confirmCheckOut({
    required String time,
    required String location,
  }) {
    return Get.bottomSheet<bool>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirm check-out',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.access_time, time),
              const SizedBox(height: 8),
              _infoRow(Icons.location_on_outlined, location),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF84C02),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Get.back(result: true),
                      child: const Text('Check out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    checkIn.value = _decode(prefs.getString(_inKey));
    checkOut.value = _decode(prefs.getString(_outKey));

    // Drop prefs for other days so they can't resurrect later.
    if (checkIn.value == null && prefs.containsKey(_inKey)) {
      await prefs.remove(_inKey);
    }
    if (checkOut.value == null && prefs.containsKey(_outKey)) {
      await prefs.remove(_outKey);
    }
  }

  AttendanceRecord? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final record = AttendanceRecord.fromJson(jsonDecode(raw));
      if (record.date != _today) return null;
      return record;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveLocal(AttendanceRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final key = record.type == 'out' ? _outKey : _inKey;
    await prefs.setString(key, jsonEncode(record.toJson()));
  }

  Future<void> _clearLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  void _snack(String title, String message, {bool error = true}) {
    AppSnackbar.show('$title\n$message', error);
  }
}

class _GeoFix {
  final double latitude;
  final double longitude;
  final String address;
  final String apiLocation;

  _GeoFix({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.apiLocation,
  });
}
