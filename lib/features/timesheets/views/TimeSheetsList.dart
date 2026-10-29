import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travelPortal/core/routes/app_routes.dart';
import 'package:travelPortal/core/routes/route_controller.dart';
import 'package:travelPortal/core/utils/size_utils.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';
import 'package:travelPortal/ui/theme/appColor.dart';
import 'package:travelPortal/ui/widgets/commonTextStyles.dart';
import 'package:travelPortal/ui/widgets/custom_search_view.dart';
import 'package:travelPortal/ui/widgets/portal_list_kit.dart';

import '../controllers/VehicleController.dart';

class EngTrainingscreen extends StatefulWidget {
  const EngTrainingscreen({super.key});

  @override
  State<EngTrainingscreen> createState() => _TrainingscreenState();
}

class _TrainingscreenState extends State<EngTrainingscreen> {
  final VehicleController vehicleController = Get.find<VehicleController>();
  final LoginController loginController = Get.find<LoginController>();
  final searchQuery = ''.obs;
  final selectedStatus = 'All'.obs;
  final selectedUser = ''.obs;
  final minDate = ''.obs;
  final maxDate = ''.obs;

  // static const statuses = [
  //   'All',
  //   'In Progress',
  //   'Completed',
  //   'Transferred',
  // ];

  static final _apiDate = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _lockToThisMonth();
    _fetch();
  }

  ({DateTime start, DateTime end}) _thisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return (start: start, end: end);
  }

  ({DateTime start, DateTime end}) _thisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    return (start: start, end: end);
  }

  void _lockToThisWeek() {
    final week = _thisWeek();
    minDate.value = _apiDate.format(week.start);
    maxDate.value = _apiDate.format(week.end);
  }

  void _lockToThisMonth() {
    final month = _thisMonth();
    minDate.value = _apiDate.format(month.start);
    maxDate.value = _apiDate.format(month.end);
  }

  void _applyThisWeek() {
    _lockToThisWeek();
    _fetch();
  }

  void _applyThisMonth() {
    _lockToThisMonth();
    _fetch();
  }

  bool get _isThisWeekSelected {
    final week = _thisWeek();
    return minDate.value == _apiDate.format(week.start) &&
        maxDate.value == _apiDate.format(week.end);
  }

  bool get _isThisMonthSelected {
    final month = _thisMonth();
    return minDate.value == _apiDate.format(month.start) &&
        maxDate.value == _apiDate.format(month.end);
  }

  Future<void> _fetch() async {
    await vehicleController.fetchbinbatch(
      context,
      loginController.UserId.toString(),
      loginController.rollId.toString(),
      min: minDate.value,
      max: maxDate.value,
      userSelect: selectedUser.value,
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final currentRaw = isFrom ? minDate.value : maxDate.value;
    final current = DateTime.tryParse(currentRaw) ?? DateTime.now();
    final minBound = isFrom
        ? DateTime(2020)
        : (DateTime.tryParse(minDate.value) ?? DateTime(2020));
    final maxBound = isFrom
        ? (DateTime.tryParse(maxDate.value) ?? DateTime.now().add(const Duration(days: 365)))
        : DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(minBound)
          ? minBound
          : (current.isAfter(maxBound) ? maxBound : current),
      currentDate: DateTime.now(),
      firstDate: isFrom ? DateTime(2020) : minBound,
      lastDate: isFrom ? maxBound : DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;

    final formatted = _apiDate.format(picked);
    if (isFrom) {
      minDate.value = formatted;
      final max = DateTime.tryParse(maxDate.value);
      if (max != null && picked.isAfter(max)) {
        maxDate.value = formatted;
      }
    } else {
      maxDate.value = formatted;
      final min = DateTime.tryParse(minDate.value);
      if (min != null && picked.isBefore(min)) {
        minDate.value = formatted;
      }
    }
    _fetch();
  }

  String convertTo12Hour(String time24) {
    if (time24.isEmpty) return '';
    for (final format in ['HH:mm:ss', 'HH:mm', 'hh:mm a']) {
      try {
        return DateFormat('hh:mm a').format(DateFormat(format).parse(time24));
      } catch (_) {}
    }
    return time24;
  }

  String _timeRange(Map<String, dynamic> item) {
    final start = convertTo12Hour(item['start_time']?.toString() ?? '');
    final end = convertTo12Hour(item['end_time']?.toString() ?? '');
    if (start.isNotEmpty && end.isNotEmpty) return '$start - $end';
    if (start.isNotEmpty) return start;
    if (end.isNotEmpty) return end;
    return '';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.green;
      case 'in progress':
        return AppColors.blue;
      case 'transferred':
        return AppColors.orange;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _filtered() {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatus.value;
    final min = DateTime.tryParse(minDate.value);
    final max = DateTime.tryParse(maxDate.value);
    return vehicleController.binbatch.where((entry) {
      final date = _parseEntryDate(entry);
      if (date != null && min != null && max != null) {
        final day = DateTime(date.year, date.month, date.day);
        if (day.isBefore(min) || day.isAfter(max)) return false;
      }
      final itemStatus = (entry['status'] ?? '').toString();
      final statusOk = status == 'All' ||
          itemStatus.toLowerCase() == status.toLowerCase();
      if (!statusOk) return false;
      if (query.isEmpty) return true;
      final haystack = [
        entry['project_name'],
        entry['user_id'],
        entry['description'],
        entry['who_assigned'],
        entry['date'],
        itemStatus,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  DateTime? _parseEntryDate(Map<String, dynamic> entry) {
    for (final raw in [entry['date'], entry['created_at']]) {
      final value = raw?.toString().trim() ?? '';
      if (value.isEmpty) continue;
      final datePart = value.split(' ').first;
      for (final format in ['dd-MM-yyyy', 'yyyy-MM-dd', 'dd/MM/yyyy']) {
        try {
          return DateFormat(format).parseStrict(datePart);
        } catch (_) {}
      }
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final routes = Get.find<RouteController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: CommonTextStyles.commonBoldStyle(
          title: 'Timesheets',
          weight: FontWeight.w500,
        ),
        centerTitle: false,
        actions: [
          portalAddButton(onTap: () => routes.to(Routes.createTimesheet)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CustomSearchView(
              //   hintText: 'Search timesheet...',
              //   onChanged: (value) => searchQuery.value = value,
              // ),
              // SizedBox(height: 17.h),
              // Row(
              //   children: [
              //     const Icon(Icons.filter_alt_outlined),
              //     CommonTextStyles.commonBoldStyle(
              //       title: 'Filters',
              //       Size: 17,
              //     ),
              //   ],
              // ),
              // SizedBox(height: 12.h),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _dateField(
                        label: 'From date',
                        value: minDate.value,
                        onTap: () => _pickDate(isFrom: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dateField(
                        label: 'To date',
                        value: maxDate.value,
                        onTap: () => _pickDate(isFrom: false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  children: [
                    PortalFilterChip(
                      label: 'This week',
                      selected: _isThisWeekSelected,
                      onTap: _applyThisWeek,
                    ),
                    const SizedBox(width: 8),
                    PortalFilterChip(
                      label: 'This month',
                      selected: _isThisMonthSelected,
                      onTap: _applyThisMonth,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                // Touch filter observables so the list rebuilds on date changes.
                minDate.value;
                maxDate.value;
                searchQuery.value;
                selectedStatus.value;
                if (vehicleController.isLoading7.value) {
                  return const CircularProgressIndicator(color: Colors.black);
                }
                if (vehicleController.errorMessage7.value.isNotEmpty &&
                    vehicleController.binbatch.isEmpty) {
                  return Text(vehicleController.errorMessage7.value);
                }
                final items = _filtered();
                if (items.isEmpty) {
                  return const Text(
                    'No timesheets for selected dates',
                    style: TextStyle(color: Colors.black),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _timesheetCard(items[index]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final display = value.isEmpty
        ? 'Select'
        : DateFormat('dd-MM-yyyy').format(DateTime.parse(value));
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 16, color: AppColors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      display,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timesheetCard(Map<String, dynamic> item) {
    final status = (item['status'] ?? 'Unknown').toString();
    final timeRange = _timeRange(item);
    final totalTime = (item['total_time'] ?? '').toString().trim();
    final assignee = (item['who_assigned'] ?? item['user_id'] ?? '--').toString();

    return PortalListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item['project_name'] ?? 'No Project',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        PortalStatusPill(
                          label: status,
                          color: _statusColor(status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignee,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: Colors.blue.shade50,
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: Icon(
              //     Icons.schedule_outlined,
              //     size: 20,
              //     color: AppColors.blue,
              //   ),
              // ),
            ],
          ),
          if ((item['description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item['description'].toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ],
          // const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['date']?.toString() ?? '--',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (timeRange.isNotEmpty)
                    Text(
                      timeRange,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  // if (totalTime.isNotEmpty) ...[
                  //   if (timeRange.isNotEmpty) const SizedBox(height: 2),
                  //   Text(
                  //     totalTime,
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       color: Colors.grey.shade600,
                  //     ),
                  //   ),
                  // ],
                  if (timeRange.isEmpty && totalTime.isEmpty)
                    const Text(
                      '--',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
