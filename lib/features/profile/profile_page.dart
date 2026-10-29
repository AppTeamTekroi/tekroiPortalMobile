import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../ui/widgets/containerWidgets.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_controller.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/pageStatus.dart';
import '../../core/utils/size_utils.dart';
import '../../ui/theme/appColor.dart';
import '../../ui/widgets/AppDateField.dart';
import '../../ui/widgets/AppDropdown.dart';
import '../../ui/widgets/AppTextField.dart';
import '../../ui/widgets/button.dart';
import '../../ui/widgets/commonAppBar.dart';
import '../../ui/widgets/loading.dart';
import '../../ui/widgets/shimmer.dart';
import '../login/controller/login_controller.dart';
import '../login/welcome_page.dart';
import 'controller/profile_controller.dart';
import 'model/profile_model.dart';

void showProfileSheet() {
  Get.bottomSheet(
    SafeArea(
      child: Container(
        height: Get.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Expanded(child: ProfilePage(asSheet: true)),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    ignoreSafeArea: false,
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.asSheet = false});
  final bool asSheet;
  RouteController get routeController => Get.find();
  LoginController get loginController => Get.find();
  ProfileController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      child: Column(
        children: [
          Obx(() {
            final state = controller.profileState.value;
            switch (state.status) {
              case PageStatus.initial:
              case PageStatus.loading:
                return shimmerBox(70);

              case PageStatus.error:
                return Text(
                  state.error ?? "Error",
                  style: const TextStyle(color: Colors.black),
                );

              case PageStatus.empty:
                return const Text(
                  "No Data",
                  style: TextStyle(color: Colors.black),
                );

              case PageStatus.success:
                final profile = state.data!;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _employeeCard(profile),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
            }
          }),
          Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: _logoutButton(loginController)),
        ],
      ),
    );

    if (asSheet) return content;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: content,
    );
  }

  // 🔹 Employee Card
  Widget _employeeCard(ProfileModel profile) {
    final emp = profile.data?.employee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, color: Colors.blue, size: 30),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp?.name ?? "--",
                      softWrap: true,
                      maxLines: 5,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emp?.department ?? "Employee",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          _infoRow(Icons.email, emp?.email ?? "--"),
          _infoRow(Icons.badge, emp?.employeeId ?? "--"),
          _infoRow(Icons.business, emp?.department ?? "--"),

          const Divider(height: 24),

          const Text("Reports to", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),

          Text(
            emp?.reportingTo ?? "--",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            emp?.reportingEmail ?? "--",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  // 🔹 Activity Summary
  // 🔹 Common Card Decoration
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}

// 🔹 Reusable Summary Card
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const SummaryCard({
    super.key,
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

Widget _switchTile(String text, bool value) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(text, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: (_) {},
    ),
  );
}

// ================= PRIVACY =================
Widget _privacyNotice() {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Privacy & Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            'Your data is stored securely and used only for service purposes.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

// ================= APP INFO =================
Widget _appInfo() {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      children: const [
        Text(
          'Tekroi Employee App',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'Version 0.0.1 • Build 20790918',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        // Text(
        //   '© 2026 Bajaj Auto Nepal',
        //   style: TextStyle(fontSize: 12, color: Colors.grey),
        // ),
      ],
    ),
  );
}

// ================= LOGOUT =================
Widget _logoutButton(LoginController loginController) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: ButtonBS(
      title: "Logout",
      // type: ButtonBSType.outlined,
      borderColor: Colors.red,
      textColor: Colors.red,
      prefixIcon: Icons.logout,
      prefixIconColor: Colors.red,
      onPressed: () => loginController.logout(),
      // routeController.offAll(Routes.login);
      borderRadius: 18,
      padding: 15,
      separatePrefixIcon: 10,
    ),

    //   OutlinedButton.icon(
    //   style: OutlinedButton.styleFrom(
    //     side: const BorderSide(color: Colors.red),
    //     padding: const EdgeInsets.symmetric(vertical: 14),
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //   ),
    //   onPressed: () {},
    //   icon: const Icon(Icons.logout, color: Colors.red),
    //   label: const Text('Logout',
    //       style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
    // ),
  );
}

Widget _vehicleRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.black87)),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );
}

Widget _infoRow(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
