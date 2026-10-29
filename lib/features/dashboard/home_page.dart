import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ui/theme/appColor.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_controller.dart';
import '../../core/utils/pageStatus.dart';
import '../../ui/widgets/commonTextStyles.dart';
import '../analytics/models/analytics_model.dart';
import '../attendance/views/attendance_card.dart';
import '../login/controller/login_controller.dart';
import '../profile/controller/profile_controller.dart';
import 'controller/dashboard_controller.dart';
import 'model/dashboard_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final RouteController routes = Get.find();
    final DashboardController controller = Get.find();
    final ProfileController profileController = Get.find();
    final LoginController login = Get.find();
    final rawName = login.UserName?.trim();
    final firstName = (rawName == null || rawName.isEmpty)
        ? 'there'
        : rawName.split(' ').first;
    final today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextStyles.commonBoldStyle(
                title: 'Hi, $firstName',
                Size: 24,
                weight: FontWeight.w700,
              ),
              const SizedBox(height: 4),
              Text(
                today,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const AttendanceCard(),

              const SizedBox(height: 20),
              const Text(
                'Quick actions',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _shortcutGrid(routes),
              const SizedBox(height: 20),
              Obx(() {
                final state = controller.dashboardState.value;
                switch (state.status) {
                  case PageStatus.initial:
                  case PageStatus.loading:
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  case PageStatus.error:
                    return Text(state.error ?? 'Could not load overview');
                  case PageStatus.empty:
                    return const SizedBox.shrink();
                  case PageStatus.success:
                    final overview = state.data?.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _overviewCard(
                          month: '${overview?.thisMonth ?? 0}',
                          pending: '${overview?.pendingApproval ?? 0}',
                          expense: '\$ ${overview?.totalExpenses ?? '0.00'}',
                          onAnalytics: () => routes.to(Routes.analytics),
                        ),
                        // if ((overview?.recentActivity ?? []).isNotEmpty) ...[
                        //   const SizedBox(height: 20),
                        //   const Text(
                        //     'Recent',
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w700,
                        //       fontSize: 16,
                        //     ),
                        //   ),
                        //   const SizedBox(height: 12),
                        //   _recentList(overview!.recentActivity, routes),
                        // ],
                      ],
                    );
                }
              }),
              // const SizedBox(height: 20),
              // Obx(() {
              //   final state = profileController.profileState.value;
              //   switch (state.status) {
              //     case PageStatus.initial:
              //     case PageStatus.loading:
              //       return const Padding(
              //         padding: EdgeInsets.symmetric(vertical: 16),
              //         child: Center(child: CircularProgressIndicator()),
              //       );
              //     case PageStatus.error:
              //     case PageStatus.empty:
              //       return _activitySummary(null);
              //     case PageStatus.success:
              //       return _activitySummary(state.data?.data?.summary);
              //   }
              // }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shortcutGrid(RouteController routes) {
    final items = [
      _Shortcut(
        icon: Icons.directions_car_outlined,
        label: 'Travel',
        hint: 'New trip',
        color: const Color(0xFF2F80ED),
        onTap: () => routes.to(Routes.createTravel),
      ),
      _Shortcut(
        icon: Icons.receipt_long_outlined,
        label: 'Expense',
        hint: 'New claim',
        color: const Color(0xFF27AE60),
        onTap: () => routes.to(Routes.createExpenses),
      ),
      _Shortcut(
        icon: Icons.schedule_outlined,
        label: 'Timesheet',
        hint: 'Log hours',
        color: const Color(0xFF5B5BD6),
        onTap: () => routes.to(Routes.createTimesheet),
      ),
      _Shortcut(
        icon: Icons.event_busy_outlined,
        label: 'Leave',
        hint: 'My leaves',
        color: const Color(0xFFF2994A),
        onTap: () => routes.to(Routes.leaves),
      ),
      _Shortcut(
        icon: Icons.support_agent_outlined,
        label: 'Support',
        hint: 'Raise a ticket',
        color: const Color(0xFF9B51E0),
        onTap: () => routes.to(Routes.ticketView),
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _shortcutTile(items[0])),
            const SizedBox(width: 10),
            Expanded(child: _shortcutTile(items[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _shortcutTile(items[2])),
            const SizedBox(width: 10),
            Expanded(child: _shortcutTile(items[3])),
          ],
        ),
        const SizedBox(height: 10),
        _shortcutTile(items[4]),
      ],
    );
  }

  Widget _shortcutTile(_Shortcut item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.hint,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activitySummary(Summary? summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _SummaryCard(
                title: 'Total Travel Logs',
                value: '${summary?.totalTravels ?? 0}',
                bgColor: const Color(0xFFE3F2FD),
                textColor: Colors.blue,
              ),
              _SummaryCard(
                title: 'Total Expenses',
                value: '${summary?.totalExpenses ?? 0}',
                bgColor: const Color(0xFFE8F5E9),
                textColor: Colors.green,
              ),
              _SummaryCard(
                title: 'Pending',
                value: '${summary?.pending ?? 0}',
                bgColor: const Color(0xFFFFF3E0),
                textColor: Colors.orange,
                icon: Icons.error_outline,
              ),
              _SummaryCard(
                title: 'Approved',
                value: '${summary?.approved ?? 0}',
                bgColor: const Color(0xFFE0F2F1),
                textColor: Colors.teal,
                icon: Icons.check_box_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewCard({
    required String month,
    required String pending,
    required String expense,
    required VoidCallback onAnalytics,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _overviewItem('This month', month),
              _vDivider(),
              _overviewItem('Pending', pending),
              _vDivider(),
              _overviewItem('Expense', expense),
            ],
          ),
          TextButton(
            onPressed: onAnalytics,
            child: const Text('View analytics'),
          ),
        ],
      ),
    );
  }

  Widget _overviewItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 36, color: Colors.grey.shade200);
  }

  Widget _recentList(List<RecentActivity> items, RouteController routes) {
    final visible = items.take(4).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
            ListTile(
              onTap: () {
                final type = visible[i].type?.toLowerCase() ?? '';
                if (type.contains('expense')) {
                  routes.to(Routes.expense);
                } else {
                  routes.to(Routes.travel);
                }
              },
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Icon(
                  (visible[i].type?.toLowerCase().contains('expense') ?? false)
                      ? Icons.receipt_long_outlined
                      : Icons.directions_car_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                visible[i].title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                [
                  if ((visible[i].subtitle ?? '').isNotEmpty) visible[i].subtitle!,
                  if ((visible[i].date ?? '').isNotEmpty) visible[i].date!,
                ].join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: visible[i].amount == null
                  ? null
                  : Text(
                      visible[i].amount!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Shortcut {
  final IconData icon;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  const _Shortcut({
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.bgColor,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 18, color: textColor),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
