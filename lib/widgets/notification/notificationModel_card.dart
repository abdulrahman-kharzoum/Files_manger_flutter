import 'package:flutter/material.dart';
import 'package:files_manager/generated/l10n.dart';

class NotificationModelCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final bool isRead;

  const NotificationModelCard({
    super.key,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(
        vertical: mediaQuery.height / 100,
        horizontal: mediaQuery.width / 50,
      ),
      child: Padding(
        padding: EdgeInsets.all(mediaQuery.width / 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 235, 175, 98),
                    ),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: const Color.fromARGB(255, 235, 175, 98),
                    size: 30,
                  ),
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isRead ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 12,
                      color: isRead ? Colors.grey : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}