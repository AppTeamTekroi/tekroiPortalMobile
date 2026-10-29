// import 'package:flutter/material.dart';
//
// import '../../core/routes/route_controller.dart';
// import '../../ui/widgets/commonAppBar.dart';
// import 'package:get/get.dart';
// class RemindersScreen extends StatefulWidget {
//   const RemindersScreen({Key? key}) : super(key: key);
//
//   @override
//   _RemindersScreenState createState() => _RemindersScreenState();
// }
//
// class _RemindersScreenState extends State<RemindersScreen> {
//   RouteController routeController = Get.find();
//
//   List<Map<String, dynamic>> reminders = [
//     {
//       'id': 1,
//       'type': 'Service Due',
//       'message': 'Next service due in 2,153 km or 45 days',
//       'priority': 'medium',
//       'icon': Icons.lock_clock,
//       'action': 'Book Service',
//       'dueIn': 'In 2,153 km',
//       'color': Colors.amber,
//     },
//     {
//       'id': 2,
//       'type': 'Insurance Renewal',
//       'message': 'Vehicle insurance expires on 2079-10-03',
//       'priority': 'high',
//       'icon': Icons.receipt,
//       'action': 'Renew Now',
//       'dueIn': '15 days left',
//       'color': Colors.red,
//     },
//     {
//       'id': 3,
//       'type': 'AMC Coupon Expiring',
//       'message': '2 AMC coupons will expire on 2079-11-15',
//       'priority': 'medium',
//       'icon': Icons.gif,
//       'action': 'Use Coupon',
//       'dueIn': '28 days left',
//       'color': Colors.purple,
//     },
//     {
//       'id': 4,
//       'type': 'Tax Renewal',
//       'message': 'Vehicle tax renewal due on 2079-08-15',
//       'priority': 'low',
//       'icon': Icons.calendar_today,
//       'action': 'View Details',
//       'dueIn': 'Upcoming',
//       'color': Colors.blue,
//     },
//   ];
//
//   // Notification settings
//   bool whatsapp = true;
//   bool sms = true;
//   bool push = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               color: Color(0xFF0055A4),
//               padding: EdgeInsets.all(16),
//               width: double.infinity,
//               child: Row(
//                 children: [
//                   IconButton(onPressed: routeController.back, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Reminders',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold)),
//                       SizedBox(height: 4),
//                       Text('Stay on top of your vehicle maintenance',
//                           style: TextStyle(color: Colors.blue[100], fontSize: 14)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.all(16),
//                 children: [
//                   // Active Reminders
//                   Text('Active Reminders',
//                       style:
//                       TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 12),
//                   ...reminders.map((reminder) {
//                     Color borderColor;
//                     Color bgColor;
//                     Color dueColor;
//
//                     switch (reminder['priority']) {
//                       case 'high':
//                         borderColor = Colors.red.shade200;
//                         bgColor = Colors.red.shade50;
//                         dueColor = Colors.red.shade600;
//                         break;
//                       case 'medium':
//                         borderColor = Colors.amber.shade200;
//                         bgColor = Colors.amber.shade50;
//                         dueColor = Colors.amber.shade600;
//                         break;
//                       default:
//                         borderColor = Colors.grey.shade200;
//                         bgColor = Colors.white;
//                         dueColor = Colors.grey.shade600;
//                     }
//
//                     return Card(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           side: BorderSide(color: borderColor, width: 2)),
//                       color: bgColor,
//                       margin: EdgeInsets.only(bottom: 12),
//                       child: Padding(
//                         padding: EdgeInsets.all(12),
//                         child: Column(
//                           children: [
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   width: 40,
//                                   height: 40,
//                                   decoration: BoxDecoration(
//                                     color: reminder['color'].withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   // child: Center(
//                                   //     child: reminder['icon'] as Widget),
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(reminder['type'],
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 14)),
//                                           Text(reminder['dueIn'],
//                                               style: TextStyle(
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: dueColor)),
//                                         ],
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(reminder['message'],
//                                           style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.grey[700])),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 8),
//                             ElevatedButton(
//                               onPressed: () {},
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: dueColor,
//                                 minimumSize: Size(double.infinity, 36),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: Text(reminder['action'],
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500)),
//                             )
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//
//                   SizedBox(height: 16),
//                   // Notification Preferences
//                   Text('Notification Preferences',
//                       style:
//                       TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 8),
//                   Column(
//                     children: [
//                       buildSwitchTile('WhatsApp Updates', whatsapp, Colors.green,
//                               (val) {
//                             setState(() => whatsapp = val);
//                           }),
//                       buildSwitchTile('SMS Notifications', sms, Colors.blue,
//                               (val) {
//                             setState(() => sms = val);
//                           }),
//                       buildSwitchTile('Push Notifications', push, Colors.purple,
//                               (val) {
//                             setState(() => push = val);
//                           }),
//                     ],
//                   ),
//
//                   SizedBox(height: 16),
//                   // Preferred Dealer
//                   Text('Preferred Service Center',
//                       style:
//                       TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 8),
//                   ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.black,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             side: BorderSide(color: Colors.grey.shade300)),
//                         padding: EdgeInsets.all(12)),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                               color: Colors.green.shade100,
//                               borderRadius: BorderRadius.circular(8)),
//                           child: Center(child: Icon(Icons.location_pin,
//                               color: Colors.green.shade600)),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('KTM-01 Koteshwor',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold, fontSize: 14)),
//                               Text('Koteshwor, Kathmandu',
//                                   style: TextStyle(
//                                       fontSize: 12, color: Colors.grey[700])),
//                               SizedBox(height: 4),
//                               Text('Change Dealer →',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.blue[600],
//                                       fontWeight: FontWeight.w500)),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: 16),
//                   // Info Section
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.blue.shade200)),
//                     child: Text(
//                         '💡 Stay Updated: Enable notifications to never miss important service reminders and renewal dates.',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[700])),
//                   ),
//                   SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper for Notification switches
//   Widget buildSwitchTile(
//       String title, bool value, Color iconColor, Function(bool) onChanged) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: SwitchListTile(
//         value: value,
//         onChanged: (v) => onChanged(v),
//         title: Row(
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(8)),
//               child: Center(
//                   child: Icon(Icons.notifications, color: iconColor, size: 18)),
//             ),
//             SizedBox(width: 12),
//             Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
//           ],
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 12),
//       ),
//     );
//   }
// }
