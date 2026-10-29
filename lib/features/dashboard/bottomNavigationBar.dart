import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_pages.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_controller.dart';
import '../../ui/theme/appColor.dart';
import '../../ui/widgets/commonAppBar.dart';
import '../login/controller/login_controller.dart';
import '../profile/profile_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final RouteController routes = Get.find();
  final LoginController loginController = Get.find();

  @override
  void initState() {
    super.initState();
    loginController.attendanceController.loadToday();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (routes.currentPage.value != Routes.home) {
          routes.backToHome();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: CommonAppBar(
          loginController.UserName,
          loginController.UserEmployeeId,
          onProfileTap: showProfileSheet,
        ),
        body: Obx(() => AppPage(page: routes.currentPage.value)),
        bottomNavigationBar: const _PortalBottomBar(),
      ),
    );
  }
}

class _PortalBottomBar extends StatelessWidget {
  const _PortalBottomBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                _NavItem(
                  page: Routes.home,
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                ),
                _NavItem(
                  page: Routes.travel,
                  label: 'Travel',
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car,
                ),
                _NavItem(
                  page: Routes.expense,
                  label: 'Expense',
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                ),
                // const _NewButton(),
                _NavItem(
                  page: Routes.timesheets,
                  label: 'Time',
                  icon: Icons.schedule_outlined,
                  activeIcon: Icons.schedule,
                ),
                _NavItem(
                  page: Routes.timesheetSupport,
                  label: 'Support',
                  icon: Icons.support_agent_outlined,
                  activeIcon: Icons.support_agent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
class _NewButton extends StatelessWidget {
  const _NewButton();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RouteController>();

    return Obx(() {
      final selected = _isTabSelected(Routes.create, controller.currentPage.value);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: selected ? AppColors.primary.withValues(alpha: 0.85) : AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => controller.switchTab(Routes.create),
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
*/

class _NavItem extends StatelessWidget {
  final Routes page;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.page,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RouteController>();

    return Expanded(
      child: InkWell(
        onTap: () => controller.switchTab(page),
        child: Obx(() {
          final selected = _isTabSelected(page, controller.currentPage.value);
          final color = selected ? AppColors.primary : Colors.grey.shade600;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? activeIcon : icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

bool _isTabSelected(Routes tab, Routes current) {
  switch (tab) {
    case Routes.home:
      return current == Routes.home ||
          current == Routes.analytics ||
          current == Routes.analyticsDetails;
    case Routes.travel:
      return current == Routes.travel ||
          current == Routes.travelDetails ||
          current == Routes.createTravel ||
          current == Routes.editTravel;
    case Routes.expense:
      return current == Routes.expense ||
          current == Routes.expenseDetails ||
          current == Routes.createExpenses ||
          current == Routes.editExpenses;
    case Routes.timesheets:
      return current == Routes.timesheets ||
          current == Routes.createTimesheet ||
          current == Routes.createLeave ||
          current == Routes.leaves;
    case Routes.timesheetSupport:
      return current == Routes.timesheetSupport || current == Routes.ticketView;
    default:
      return current == tab;
  }
}
