import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  final LoginController controller = Get.find();
  int selectedIndex = 0;
  bool _obscureText = true;

  @override
  // void initState() {
  //   super.initState();
  //   controller.fetchUsers();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700], // Matches the background border color
      body: Center(
        child: Container(
          height: 700,
          width: 400,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon and Header
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue[50],
                child: Icon(Icons.person_outline, color: Colors.blue, size: 30),
              ),
              SizedBox(height: 16),
              Text("TEKROI SUPPORT", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Select your profile to continue", style: TextStyle(color: Colors.grey[600])),

              SizedBox(height: 32),
              Align(alignment: Alignment.centerLeft, child: Text("Select User", style: TextStyle(fontWeight: FontWeight.w500))),
              SizedBox(height: 12),
              // Profile List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.userList.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: controller.userList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = controller.userList[index];
                      bool isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: UserCard(
                          user: {
                            "name": user['name'] ?? '',
                            "email": user['email'] ?? '',
                            "role": "Employee • ${user['employee_id'] ?? ''}",
                          },
                          isSelected: isSelected,
                        ),
                      );
                    },
                  );
                }),
              ),

              SizedBox(height: 24),

              // --- NEW PASSWORD FIELD ---
              TextField(
                controller: controller.passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Enter Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              SizedBox(height: 20),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    print("Logging in as ");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, String> user;
  final bool isSelected;

  const UserCard({super.key, required this.user, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F5FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF1A5CFF) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radio
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF1A5CFF) : Colors.grey,
                width: isSelected ? 6 : 2,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 🔥 IMPORTANT FIX
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user['role'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}