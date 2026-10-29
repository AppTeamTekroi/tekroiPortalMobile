import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelPortal/ui/widgets/AppTextField.dart';
import '../../../ui/theme/appColor.dart';

import '../../core/utils/size_utils.dart';
import 'controller/login_controller.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  LoginController controller = Get.find();
  int selectedIndex = -1;
  void _showPasswordSheet(dynamic user) {
    controller.passwordController.clear();
    controller.userErrorMessage.value = '';

    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(Get.context!).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "User Authentication",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// USER INFO
                  Text(
                    "User Details",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Employee Name : ${user['name'] ?? ''}",
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Employee Address : ${user['email'] ?? ''}",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Employee Id : ${user['employee_id'] ?? ''}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  /// PASSWORD FIELD
                  AppTextField(
                    controller: controller.passwordController,
                    hint: "Enter Password",
                    label: "Password",
                    color: Colors.red,
                  ),

                  const SizedBox(height: 20),

                  /// 🔴 ERROR MESSAGE (REACTIVE)
                  Obx(() => controller.userErrorMessage.value.isNotEmpty
                      ? Text(
                          controller.userErrorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        )
                      : const SizedBox.shrink()),

                  const SizedBox(height: 10),

                  /// 🔵 BUTTON / LOADING
                  Obx(() => controller.isLoading.value
                      ? const Center(child: Text("Loading ....."))
                      : ElevatedButton(
                          onPressed: () async {
                            if (controller.passwordController.text.trim().isEmpty) {
                              controller.userErrorMessage.value = "Enter password";
                              return;
                            }

                            controller.emailController.text = user['email'];

                            await controller.loginUser();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.w),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Proceed to Login',
                                style: TextStyle(
                                    fontSize: 16.fSize, color: Colors.white),
                              ),
                              SizedBox(width: 8.w),
                              const Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                        )),

                  SizedBox(height: 22.h),

                  /// FOOTER
                  Center(
                    child: Text(
                      'Version 1.0.0 • © 2025 Tekroi Pvt Ltd',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blue,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(24.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.blue,
                AppColors.blue,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// LOGO
                CircleAvatar(
                  radius: 38.h,
                  backgroundColor: Colors.white,
                  child: Text(
                    '👦🏻',
                    style: TextStyle(
                      fontSize: 48.fSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Travel and Expense',
                  style: TextStyle(
                    fontSize: 22.fSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Select your user profile to continue',
                  style: TextStyle(
                    color: AppColors.secondaryText, // blue-100
                  ),
                ),

                SizedBox(height: 20.h),
                TextField(
                  onChanged: (value) {
                    setState(() => selectedIndex = -1);
                    controller.filterUsers(value);
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Search employee name",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.grey[400], size: 22),

                    // Clear button appears only when text is entered
                    suffixIcon: Obx(
                      () => controller.searchQuery.value.isEmpty
                          ? const SizedBox.shrink()
                          : IconButton(
                              icon: const Icon(Icons.cancel,
                                  color: Colors.grey, size: 20),
                              onPressed: () {
                                setState(() => selectedIndex = -1);
                                controller.searchQuery.value = "";
                                controller.filterUsers("");
                              },
                            ),
                    ),

                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),

                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0), // Centers text vertically
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Pill shape
                      borderSide: BorderSide.none, // Remove harsh lines
                    ),
                    // enabledBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(12),
                    //   borderSide: BorderSide(color: Colors.white, width: 1),
                    // ),
                    // focusedBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(12),
                    //   borderSide: BorderSide(color: Colors.white, width: 1.5),
                    // ),
                  ),
                ),
                SizedBox(height: 20.h),

                Obx(() {
                  if (controller.isUserLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredUsers.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  return Expanded(
                    child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: controller.filteredUsers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 5),
                        itemBuilder: (context, index) {
                          final user = controller.filteredUsers[index];
                          bool isSelected = selectedIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => selectedIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: isSelected ? 6 : 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user["name"] ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            user["email"] ?? "",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "Employee • ${user['employee_id'] ?? ''}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  );
                }),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
          child: SizedBox(
            height: 56.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (selectedIndex == -1) {
                  Get.snackbar("Error", "Please select a profile");
                  return;
                }

                final selectedUser = controller.filteredUsers[selectedIndex];

                _showPasswordSheet(selectedUser);
              },
              // routes.to(Routes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.w),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(fontSize: 16.fSize),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
