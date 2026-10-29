import 'package:flutter/material.dart';

import '../../core/utils/size_utils.dart';
import '../theme/appColor.dart';

class PortalFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PortalFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18.h),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF34353d),
          ),
        ),
      ),
    );
  }
}

class PortalStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const PortalStatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class PortalListCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PortalListCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: child,
      ),
    );
  }
}

Widget portalAddButton({
  required VoidCallback onTap,
  Color? color,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 8, top: 8),
      decoration: BoxDecoration(
        color: color ?? AppColors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
}
