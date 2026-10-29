// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../core/routes/app_routes.dart';
// import '../../core/routes/route_controller.dart';
// import '../../ui/widgets/commonTextStyles.dart';
//
// class CreatePage extends StatelessWidget {
//   const CreatePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     RouteController routes = Get.find();
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       // appBar: AppBar(
//       //   backgroundColor: Colors.grey.shade100,
//       //   elevation: 0,
//       //   title: CommonTextStyles.commonBoldStyle(
//       //     title: "Create New Entry",
//       //     weight: FontWeight.w600,
//       //   ),
//       //   centerTitle: false,
//       // ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),
//             CommonTextStyles.commonBoldStyle(
//               title: "Create New Entry",
//               weight: FontWeight.w600,
//               Size: 19
//             ),
//             /// Subtitle
//             Text(
//               "Choose what you'd like to create",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             /// Travel Log Card
//             _buildCard(
//               icon: Icons.location_on_outlined,
//               iconBg: Colors.blue.shade100,
//               iconColor: Colors.blue,
//               title: "Travel Log",
//               subtitle:
//               "Record daily check-in/check-out, travel type, mode, and taxi expenses",
//               onTap: () {
//                 routes.to(Routes.createTravel);
//               },
//             ),
//
//             const SizedBox(height: 10),
//
//             /// Expense Claim Card
//             _buildCard(
//               icon: Icons.receipt_long_outlined,
//               iconBg: Colors.green.shade100,
//               iconColor: Colors.green,
//               title: "Expense Claim",
//               subtitle:
//               "Submit travel expenses for tickets and hotels when with customer representatives",
//               onTap: () {
//                 routes.to(Routes.createExpenses);
//               },
//             ),
//
//             const SizedBox(height: 10),
//
//             _buildCard(
//               icon: Icons.access_time,
//               iconBg: Colors.indigo.shade100,
//               iconColor: Colors.indigo,
//               title: "Timesheet",
//               subtitle:
//               "Log project hours, dates, and work descriptions",
//               onTap: () {
//                 routes.to(Routes.createTimesheet);
//               },
//             ),
//
//             const SizedBox(height: 10),
//
//             _buildCard(
//               icon: Icons.event_busy_outlined,
//               iconBg: Colors.orange.shade100,
//               iconColor: Colors.orange,
//               title: "Leave Request",
//               subtitle:
//               "Apply for sick or casual leave with dates and attachments",
//               onTap: () {
//                 routes.to(Routes.createLeave);
//               },
//             ),
//
//             const SizedBox(height: 10),
//
//             _buildCard(
//               icon: Icons.support_agent_outlined,
//               iconBg: Colors.purple.shade100,
//               iconColor: Colors.purple,
//               title: "Support",
//               subtitle:
//               "View and filter support tickets by user, domain, and status",
//               onTap: () {
//                 routes.to(Routes.timesheetSupport);
//               },
//             ),
//
//             const SizedBox(height: 10),
//
//             _buildCard(
//               icon: Icons.confirmation_number_outlined,
//               iconBg: Colors.deepPurple.shade100,
//               iconColor: Colors.deepPurple,
//               title: "View Tickets",
//               subtitle:
//               "Open a ticket, update domain, and log timesheet hours",
//               onTap: () {
//                 routes.to(Routes.ticketView);
//               },
//             ),
//           ],
//         ),
//         ),
//       ),
//     );
//   }
//
//   /// 🔥 Reusable Card Widget
//   Widget _buildCard({
//     required IconData icon,
//     required Color iconBg,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Icon Box
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: iconBg,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: iconColor),
//             ),
//
//             const SizedBox(width: 16),
//
//             /// Text Content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }