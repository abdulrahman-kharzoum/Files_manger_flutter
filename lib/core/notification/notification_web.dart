import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
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

  Future<String> getToken() async {
    return await FirebaseMessaging.instance.getToken() ?? '';
  }
}
