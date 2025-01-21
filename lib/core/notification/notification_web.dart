// import 'package:files_manager/models/notification_model.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> listenNotifications() async {
//     FirebaseMessaging.onMessage.listen(_showFlutterNotification);
//   }
//
//   void _showFlutterNotification(RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     print("==============Notification==================");
//     print('------------------------------------------------------');
//     print('The body is =>${notification?.title}');
//     print('------------------------------------------------------');
//     print('------------------------------------------------------');
//     print('The body is =>${notification?.body}');
//     print('------------------------------------------------------');
//     // Feel free to add UI according to your preference, I am just using a custom Toast.
//
//     final notificationModel = NotificationModel(
//       title: notification?.title ?? 'No Title',
//       body: notification?.body ?? 'No Body',
//       time: DateTime.now(),
//     );
//   }
//
//   Future<String?> getToken() async {
//     try {
//       String? token = await _firebaseMessaging.getToken();
//       print("FCM Token: $token");
//       return token;
//     } catch (e) {
//       print("Error getting FCM token: $e");
//       return null;
//     }
//   }
// // Future<String> getToken() async {
// //   return await FirebaseMessaging.instance.getToken() ?? '';
// // }
// }
import 'package:files_manager/cubits/notification_cubit/notification_cubit.dart';
import 'package:files_manager/models/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  NotificationService();

  Future<void> initialize() async {
    await _setupInteractedMessage();
    _configureFirebaseListeners();
    await _requestPermissions();
  }

  Future<void> _setupInteractedMessage() async {
    RemoteMessage? initialMessage =
    await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) _handleMessage(initialMessage);

    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
      _showLocalNotification(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    final notification = NotificationModel(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      time: DateTime.now(),
    );

    // _cubit.addNotification(notification);
  }

  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _showLocalNotification(RemoteMessage message) {
    // Implement local notifications using flutter_local_notifications if needed
    print('Foreground Notification: ${message.notification?.title}');
  }

  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }
}