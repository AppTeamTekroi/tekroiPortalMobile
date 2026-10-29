// import 'package:flutter/material.dart';
//
// import '../../core/routes/app_routes.dart';
// import '../../core/routes/route_controller.dart';
// import '../../core/utils/pageStatus.dart';
// import '../../ui/theme/appColor.dart';
// import '../../ui/widgets/AppDateField.dart';
// import '../../ui/widgets/AppDropdown.dart';
// import '../../ui/widgets/button.dart';
// import '../../ui/widgets/commonAppBar.dart';
// import '../../ui/widgets/containerWidgets.dart';
// import '../../ui/widgets/loading.dart';
// import 'controller/profile_controller.dart';
// import 'package:get/get.dart';
//
// class EditProfilePage extends StatelessWidget {
//   EditProfilePage({super.key});
//
//   final ProfileController controller = Get.find();
//   final _formKey = GlobalKey<FormState>();
//   RouteController routeController = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(),
//       body:
//       Form(
//         key: _formKey,
//         child: ListView(
//           children: [
//             _header(),
//             const SizedBox(height: 15),
//             _buildTextField("Full Name", controller.nameController),
//             _buildTextField("Phone", controller.altphoneController,
//                 keyboardType: TextInputType.phone),
//             _buildTextField("Email", controller.emailController,
//                 keyboardType: TextInputType.emailAddress),
//             _buildTextField("Address", controller.addressController),
//             _buildTextField("City", controller.cityController),
//             _buildTextField("State", controller.stateController),
//             _buildTextField("Pincode", controller.pincodeController,
//                 keyboardType: TextInputType.number),
//             AppDropdown(label: 'Gender', value: controller.gender ?? "", items: ["Male","Female",'Others'], icon: Icons.person, onChanged: (value) {controller.gender = value!; },),
//             AppDateField(
//               controller: controller.DOB,
//               label: "Purchase Date",
//               hint: "Select purchase date",
//               icon: Icons.date_range,
//             ),
//             Obx(() {
//               final state = controller.profileEditState.value;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
//                 child: ButtonBS(
//                   title: 'Update Profile',
//                   // onPressed: handleConform,
//                   backgroundColor: AppColors.primary,
//                   borderRadius: 12,
//                   prefixIcon: Icons.verified,
//                   prefixIconColor: Colors.white,
//                   separatePrefixIcon: 10,
//                   padding: 12,
//                   textColor: Colors.white,
//                   fontSize: 15,
//                 ),
//               );
//             })
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _header() {
//     return  ContainerWidget.headerGradient(
//       child: Row(
//         spacing: 10,
//         children: [
//           InkWell(onTap: routeController.back,child: Icon(Icons.arrow_back_ios,color: Colors.white),),
//           Text(
//             'Edit Profile',
//             style: TextStyle(
//                 color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }  Widget _buildTextField(String label, TextEditingController controller,
//       {TextInputType keyboardType = TextInputType.text}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
//       child: TextFormField(
//
//         controller: controller,
//         keyboardType: keyboardType,
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return "$label is required";
//           }
//           return null;
//         },
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
