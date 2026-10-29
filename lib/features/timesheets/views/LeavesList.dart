import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:travelPortal/core/constants/api_constants.dart';
import 'package:travelPortal/core/network/api_helper.dart';
import 'package:travelPortal/core/routes/app_routes.dart';
import 'package:travelPortal/core/routes/route_controller.dart';
import 'package:travelPortal/core/utils/size_utils.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';
import 'package:travelPortal/ui/theme/appColor.dart';
import 'package:travelPortal/ui/widgets/commonTextStyles.dart';
import 'package:travelPortal/ui/widgets/custom_search_view.dart';
import 'package:travelPortal/ui/widgets/portal_list_kit.dart';

import '../controllers/VehicleController.dart';

class Enginnerservicescreen extends StatefulWidget {
  const Enginnerservicescreen({super.key});

  @override
  State<Enginnerservicescreen> createState() => _ServicescreenState();
}

class _ServicescreenState extends State<Enginnerservicescreen> {
  final VehicleController vehicleController = Get.find<VehicleController>();
  final LoginController loginController = Get.find<LoginController>();
  final isSubmitting = false.obs;
  final searchQuery = ''.obs;
  final selectedStatus = 'All'.obs;
  final expandedLeaveIds = <String>{}.obs;

  static const statuses = [
    'All',
    'Pending Approval',
    'Approved',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    vehicleController.fetchleaves(
      context,
      loginController.UserId.toString(),
      loginController.rollId.toString(),
    );
  }

  Future<void> submitApproval(Map<String, dynamic> body) async {
    isSubmitting.value = true;
    try {
      final res = await http.post(
        ApiHelper.withToken(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.leaveApproval}')),
        headers: ApiHelper.getHeaders(),
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        vehicleController.fetchleaves(
          context,
          loginController.UserId.toString(),
          '',
        );
        Get.snackbar(
          'Success',
          'Action completed',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Action failed');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.green;
      case 'rejected':
        return Colors.red;
      case 'pending approval':
        return AppColors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatCreatedAt(Map data) {
    final raw = (data['created_at'] ??
            data['createdAt'] ??
            data['applied_on'] ??
            data['applied_at'] ??
            '')
        .toString()
        .trim();
    if (raw.isEmpty) return '';

    for (final format in [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
      'yyyy-MM-dd\'T\'HH:mm:ss.SSSSSS\'Z\'',
      'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'',
      'yyyy-MM-dd\'T\'HH:mm:ss',
      'yyyy-MM-dd',
    ]) {
      try {
        final parsed = DateFormat(format).parse(raw, true).toLocal();
        return DateFormat('dd-MM-yyyy hh:mm a').format(parsed);
      } catch (_) {}
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return DateFormat('dd-MM-yyyy hh:mm a').format(parsed.toLocal());
    }
    return raw;
  }

  bool _isPending(Map data) {
    final status = (data['status_display'] ?? '').toString().toLowerCase();
    return status == 'pending approval' || status == 'pending';
  }

  bool _isOwnLeave(Map data) {
    final dataEmp = '${data['employee_id'] ?? ''}'.trim().toLowerCase();
    final dataUser = '${data['user_id'] ?? ''}'.trim();
    final myEmp =
        (loginController.UserEmployeeId ?? loginController.employeeId ?? '')
            .toString()
            .trim()
            .toLowerCase();
    final myUser = '${loginController.UserId ?? ''}'.trim();
    if (dataEmp.isNotEmpty && myEmp.isNotEmpty && dataEmp == myEmp) {
      return true;
    }
    if (dataUser.isNotEmpty && myUser.isNotEmpty && dataUser == myUser) {
      return true;
    }
    return false;
  }

  bool _canAct(Map data) {
    final isManager =
        loginController.rollId == 1 || loginController.rollId == 2;
    return _isPending(data) && isManager && !_isOwnLeave(data);
  }

  List _filtered() {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatus.value.toLowerCase();
    return vehicleController.leavesList.reversed.where((item) {
      final itemStatus = (item['status_display'] ?? '').toString();
      final statusOk =
          status == 'all' || itemStatus.toLowerCase() == status;
      if (!statusOk) return false;
      if (query.isEmpty) return true;
      final haystack = [
        item['employee_name'],
        item['employee_id'],
        item['leave_display'],
        item['location'],
        item['description'],
        itemStatus,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final routes = Get.find<RouteController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: CommonTextStyles.commonBoldStyle(
          title: 'Leaves',
          weight: FontWeight.w500,
        ),
        centerTitle: false,
        actions: [
          portalAddButton(onTap: () => routes.to(Routes.createLeave)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSearchView(
                hintText: 'Search leave...',
                onChanged: (value) => searchQuery.value = value,
              ),
              SizedBox(height: 17.h),
              Row(
                children: [
                  const Icon(Icons.filter_alt_outlined),
                  CommonTextStyles.commonBoldStyle(
                    title: 'Filter by status:',
                    Size: 17,
                  ),
                ],
              ),
              SizedBox(height: 17.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => Row(
                    spacing: 7,
                    children: statuses
                        .map(
                          (status) => PortalFilterChip(
                            label: status,
                            selected: selectedStatus.value == status,
                            onTap: () => selectedStatus.value = status,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (vehicleController.isLoading8.value) {
                  return const CircularProgressIndicator(color: Colors.black);
                }
                final items = _filtered();
                if (items.isEmpty) {
                  return const Text(
                    'No Data',
                    style: TextStyle(color: Colors.black),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _leaveCard(items[index]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leaveCard(Map data) {
    final status = (data['status_display'] ?? 'Unknown').toString();
    final createdAt = _formatCreatedAt(data);
    final leaveKey = '${data['id'] ?? data['leave_id'] ?? data.hashCode}';

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
                          data['employee_name'] ?? '—',
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
                      data['leave_display'] ?? '--',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_canAct(data))
                _actionMenu(data)
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.event_busy_outlined,
                    size: 20,
                    color: AppColors.orange,
                  ),
                ),
            ],
          ),
          if ((data['description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _expandableText(
              id: '${leaveKey}_desc',
              label: 'Description',
              text: data['description'].toString(),
              color: Colors.grey.shade700,
            ),
          ],
          if ((data['rejected_reason'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            _expandableText(
              id: '${leaveKey}_reason',
              label: 'Rejected reason',
              text: data['rejected_reason'].toString(),
              color: Colors.red,
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${data['start_date'] ?? '--'}  -  ${data['end_date'] ?? '--'}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              if ((data['attachements'] ?? '').toString().isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(data['attachements'].toString());
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Attached 📎',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                )
              else if ((data['location'] ?? '').toString().isNotEmpty)
                Text(
                  data['location'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
            ],
          ),
          if (createdAt.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Created: $createdAt',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _expandableText({
    required String id,
    required String label,
    required String text,
    required Color color,
  }) {
    return Obx(() {
      final expanded = expandedLeaveIds.contains(id);
      final needsExpand = text.trim().length > 90 || text.contains('\n');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            maxLines: expanded || !needsExpand ? null : 2,
            overflow:
                expanded || !needsExpand ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 13, height: 1.35),
          ),
          if (needsExpand)
            InkWell(
              onTap: () {
                if (expanded) {
                  expandedLeaveIds.remove(id);
                } else {
                  expandedLeaveIds.add(id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expanded ? 'Show less' : 'Show more',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue,
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _actionMenu(Map data) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'approve') {
          await submitApproval({'id': data['id'], 'approval_status': 1});
        } else {
          _showRejectDialog(data);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'approve',
          child: Row(
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text('Approve'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reject',
          child: Row(
            children: [
              Icon(Icons.close, color: Colors.red),
              SizedBox(width: 8),
              Text('Reject'),
            ],
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(Map data) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Reason for Rejection'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter details...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await submitApproval({
                'id': data['id'],
                'approval_status': 2,
                'rejected_reason': reasonCtrl.text.trim(),
              });
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
