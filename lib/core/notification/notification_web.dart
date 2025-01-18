import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> listenNotifications() async {
    FirebaseMessaging.onMessage.listen(_showFlutterNotification);
  }

  void _showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    print('------------------------------------------------------');
    print('The body is =>${notification?.body}');
    print('------------------------------------------------------');
    // Feel free to add UI according to your preference, I am just using a custom Toast.
  }

  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");
      return token;
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }
// Future<String> getToken() async {
//   return await FirebaseMessaging.instance.getToken() ?? '';
// }
}
