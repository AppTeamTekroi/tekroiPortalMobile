import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travelPortal/core/routes/app_routes.dart';
import 'package:travelPortal/core/routes/route_controller.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';
import 'package:travelPortal/ui/theme/appColor.dart';
import 'package:travelPortal/ui/widgets/commonTextStyles.dart';
import 'package:travelPortal/ui/widgets/portal_list_kit.dart';

import '../controllers/VehicleController.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final vehicleCtrl = Get.find<VehicleController>();
  final loginCtrl = Get.find<LoginController>();
  // final searchQuery = ''.obs;
  // final selectedStatus = 'All'.obs;
  final selectedDateRange = 'Today'.obs;
  final selectedDomain = 'All'.obs;

  static const dateRanges = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'Last 7 days',
    'Last 30 days',
    'Beyond 30 days',
  ];

  // final statuses = const [
  //   'All',
  //   'Open',
  //   'Initiated',
  //   'Work in Progress',
  //   'Waiting for Customer',
  //   'Confirmation Pending',
  //   'On Hold',
  //   'Closed',
  // ];

  @override
  void initState() {
    super.initState();
    final userId = loginCtrl.UserId.toString();
    vehicleCtrl.fetchSupport(context, userId);
    vehicleCtrl.DomainData(context, userId);
  }

  String statusText(dynamic id) {
    const statuses = [
      'All',
      'Open',
      'Initiated',
      'Work in Progress',
      'Waiting for Customer',
      'Confirmation Pending',
      'On Hold',
      'Closed',
    ];
    if (id is int && id >= 0 && id < statuses.length - 1) {
      return statuses[id + 1];
    }
    return 'Unknown';
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.green;
      case 'Closed':
        return Colors.red;
      case 'Work in Progress':
        return AppColors.blue;
      case 'On Hold':
        return AppColors.orange;
      case 'Waiting for Customer':
        return Colors.amber.shade700;
      default:
        return AppColors.primary;
    }
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? _parseCreatedAt(Map<String, dynamic> item) {
    final raw = item['created_at']?.toString().trim() ?? '';
    if (raw.isEmpty) return null;

    final datePart = raw.split(' ').first;
    for (final format in [
      'yyyy-MM-dd',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
    ]) {
      try {
        return DateFormat(format).parseStrict(datePart);
      } catch (_) {}
    }
    return DateTime.tryParse(raw);
  }

  bool _matchesDateRange(DateTime? created) {
    if (created == null) return selectedDateRange.value == 'Beyond 30 days';

    final day = DateTime(created.year, created.month, created.day);
    final today = _today();

    switch (selectedDateRange.value) {
      case 'Today':
        return day.isAtSameMomentAs(today);
      case 'Yesterday':
        return day.isAtSameMomentAs(today.subtract(const Duration(days: 1)));
      case 'Tomorrow':
        return day.isAtSameMomentAs(today.add(const Duration(days: 1)));
      case 'Last 7 days':
        final start = today.subtract(const Duration(days: 6));
        return !day.isBefore(start) && !day.isAfter(today);
      case 'Last 30 days':
        final start = today.subtract(const Duration(days: 29));
        return !day.isBefore(start) && !day.isAfter(today);
      case 'Beyond 30 days':
        return day.isBefore(today.subtract(const Duration(days: 30)));
      default:
        return true;
    }
  }

  List<String> _domainOptions() {
    final fromApi = vehicleCtrl.domain
        .map((d) => d.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    if (fromApi.isNotEmpty) {
      fromApi.sort();
      return fromApi;
    }

    final fromTickets = vehicleCtrl.support
        .map((item) => item['domain']?.toString().trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    fromTickets.sort();
    return fromTickets;
  }

  List<Map<String, dynamic>> _filtered() {
    final domain = selectedDomain.value;
    return vehicleCtrl.support.where((item) {
      if (!_matchesDateRange(_parseCreatedAt(item))) return false;

      if (domain != 'All') {
        final itemDomain = (item['domain'] ?? '').toString();
        if (itemDomain != domain) return false;
      }

      // final query = searchQuery.value.trim().toLowerCase();
      // final status = selectedStatus.value;
      // final itemStatus = statusText(item['status_id']);
      // final statusOk = status == 'All' || itemStatus == status;
      // if (!statusOk) return false;
      // if (query.isNotEmpty) {
      //   final haystack = [
      //     item['ticket_id'],
      //     item['subject'],
      //     item['domain'],
      //     item['assigned'],
      //     itemStatus,
      //   ].join(' ').toLowerCase();
      //   if (!haystack.contains(query)) return false;
      // }

      return true;
    }).toList();
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _filterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          isDense: true,
          isExpanded: true,
          value: items.contains(value) ? value : items.first,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: _dropdownDecoration(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final routes = Get.find<RouteController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: CommonTextStyles.commonBoldStyle(
          title: 'Support',
          weight: FontWeight.w500,
        ),
        centerTitle: false,
        actions: [
          portalAddButton(
            onTap: () => routes.to(Routes.ticketView),
            color: AppColors.primary,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CustomSearchView(
              //   hintText: 'Search ticket...',
              //   onChanged: (value) => searchQuery.value = value,
              // ),
              // SizedBox(height: 17.h),
              // Row(
              //   children: [
              //     const Icon(Icons.filter_alt_outlined),
              //     CommonTextStyles.commonBoldStyle(
              //       title: 'Filter by status:',
              //       Size: 17,
              //     ),
              //   ],
              // ),
              // SizedBox(height: 17.h),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Obx(
              //     () => Row(
              //       spacing: 7,
              //       children: statuses
              //           .map(
              //             (status) => PortalFilterChip(
              //               label: status,
              //               selected: selectedStatus.value == status,
              //               onTap: () => selectedStatus.value = status,
              //             ),
              //           )
              //           .toList(),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // Row(
              //   children: [
              //     const Icon(Icons.filter_alt_outlined, size: 18),
              //     const SizedBox(width: 6),
              //     CommonTextStyles.commonBoldStyle(
              //       title: 'Filters',
              //       Size: 16,
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () => _filterDropdown(
                        label: 'Date',
                        value: selectedDateRange.value,
                        items: dateRanges,
                        onChanged: (val) {
                          if (val != null) selectedDateRange.value = val;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      final domains = ['All', ..._domainOptions()];
                      final current = domains.contains(selectedDomain.value)
                          ? selectedDomain.value
                          : 'All';
                      return _filterDropdown(
                        label: 'Domain',
                        value: current,
                        items: domains,
                        onChanged: (val) {
                          if (val != null) selectedDomain.value = val;
                        },
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (vehicleCtrl.isLoading10.value) {
                  return const CircularProgressIndicator(color: Colors.black);
                }
                if (vehicleCtrl.errorMessage10.value.isNotEmpty &&
                    vehicleCtrl.support.isEmpty) {
                  return Text(
                    vehicleCtrl.errorMessage10.value,
                    style: const TextStyle(color: Colors.black),
                  );
                }
                final items = _filtered();
                if (items.isEmpty) {
                  return const Text(
                    'No tickets for these filters',
                    style: TextStyle(color: Colors.black),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _ticketCard(items[index]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketCard(Map<String, dynamic> item) {
    final routes = Get.find<RouteController>();
    final status = statusText(item['status_id']);

    return PortalListCard(
      onTap: () => routes.to(Routes.ticketView, arguments: item),
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
                          item['subject'] ?? 'No Subject',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        PortalStatusPill(
                          label: status,
                          color: statusColor(status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['domain'] ?? '--',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                            item['assigned'] ?? 'Unassigned',
                            style: const TextStyle(fontWeight: FontWeight.w200),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: AppColors.primary.withValues(alpha: 0.12),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: Icon(
              //     Icons.support_agent_outlined,
              //     size: 20,
              //     color: AppColors.primary,
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),
          Text(
            '#${item['ticket_id'] ?? '--'}  •  ${item['created_at'] ?? ''}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          // Text(
          //   item['assigned'] ?? 'Unassigned',
          //   style: const TextStyle(fontWeight: FontWeight.w500),
          // ),
        ],
      ),
    );
  }
}
