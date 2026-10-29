import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../ui/theme/appColor.dart';
import '../controllers/attendance_controller.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();

    return Obx(() {
      final checkedIn = controller.isInForToday;
      final checkedOut = controller.isOutForToday;
      final record = controller.checkIn.value;
      final outRecord = controller.checkOut.value;
      final photoPath = record?.photoPath;
      final hasNetworkPhoto = record?.hasNetworkPhoto == true;
      final localPhoto =
          photoPath != null && !hasNetworkPhoto ? File(photoPath) : null;
      final hasLocalPhoto =
          localPhoto != null && localPhoto.existsSync();
      final networkPhoto = hasNetworkPhoto ? photoPath! : null;

      final title = checkedOut
          ? "You're out"
          : checkedIn
              ? "You're in"
              : 'Mark attendance';

      final subtitle = checkedOut
          ? [
              if (record != null) 'In ${record.time}',
              if (outRecord != null) 'Out ${outRecord.time}',
              if (outRecord != null && outRecord.location.trim().isNotEmpty)
                outRecord.location,
            ].join('  •  ')
          : checkedIn
              ? [
                  if (record != null) 'In ${record.time}',
                  if (record != null && record.location.trim().isNotEmpty)
                    record.location,
                ].join('  •  ')
              : 'Photo, time and location';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasLocalPhoto
                  ? Image.file(localPhoto, width: 48, height: 48, fit: BoxFit.cover)
                  : networkPhoto != null
                      ? Image.network(
                          networkPhoto,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _photoPlaceholder(checkedIn, checkedOut),
                        )
                      : _photoPlaceholder(checkedIn, checkedOut),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (!checkedIn) ...[
              const SizedBox(width: 8),
              _pillButton(
                'Check in',
                AppColors.green,
                controller.isSubmitting.value ? null : controller.punchIn,
              ),
            ] else if (!checkedOut) ...[
              const SizedBox(width: 8),
              _pillButton(
                'Check out',
                AppColors.orange,
                controller.isSubmitting.value ? null : controller.punchOut,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _photoPlaceholder(bool checkedIn, bool checkedOut) {
    final color = checkedOut
        ? AppColors.orange
        : checkedIn
            ? AppColors.green
            : AppColors.primary;
    return Container(
      width: 48,
      height: 48,
      color: color.withValues(alpha: 0.12),
      child: Icon(
        checkedOut
            ? Icons.logout
            : checkedIn
                ? Icons.verified
                : Icons.camera_alt_outlined,
        color: color,
      ),
    );
  }

  Widget _pillButton(String label, Color color, VoidCallback? onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
