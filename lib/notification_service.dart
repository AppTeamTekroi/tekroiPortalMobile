// import 'dart:convert';
// //
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   // Optional: Handle data silently in background
//   print('Handling background message: ${message.messageId}');
// }
//
// Future<void> initFCM() async {
//   // Android channel for local notifications
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     importance: Importance.high,
//   );
//
//   // Init plugin
//   await flutterLocalNotificationsPlugin.initialize(
//     const InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     ),
//   );
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   // Handle foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//
//     if (notification != null && android != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             icon: '@mipmap/ic_launcher',
//           ),
//         ),
//       );
//
//       final prefs = await SharedPreferences.getInstance();
//       const key = 'local_notifications';
//
//       // Get existing list
//       List<String> currentList = prefs.getStringList(key) ?? [];
//
//       // Create notification map
//       Map<String, dynamic> newNotification = {
//         'title': notification.title ?? '',
//         'body': notification.body ?? '',
//         'timestamp': DateTime.now().toIso8601String(),
//       };
//
//       // Add to list
//       currentList.insert(0, jsonEncode(newNotification));
//
//       // currentList.add(jsonEncode(newNotification));
//       await prefs.setStringList(key, currentList);
//     }
//
//   });
// }
