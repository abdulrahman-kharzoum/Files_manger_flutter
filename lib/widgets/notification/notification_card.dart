import 'package:files_manager/cubits/add_board_cubit/add_board_cubit.dart';
import 'package:files_manager/cubits/pending_cubit/pending_cubit.dart';
import 'package:flutter/material.dart';
import 'package:files_manager/generated/l10n.dart';

class NotificationCard extends StatefulWidget {

  final String title;
  final String content;
  final bool isRead;
  final String time;
  final bool isThisNotificationToMe;

  final bool showAcceptDeniedButtons;

  final VoidCallback? onAccept;
  final VoidCallback? onDenied;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.title,
    required this.content,
    this.isRead = false,
    required this.time,
    required this.isThisNotificationToMe,
    this.showAcceptDeniedButtons = false,


    this.onAccept,
    this.onDenied,
    this.onDelete,
  });

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    final description = widget.content;
    final textPainter = TextPainter(
      text: TextSpan(
        text: description,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: mediaQuery.width - 100);
    final isLongDescription = textPainter.didExceedMaxLines;

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
                        color: const Color.fromARGB(255, 235, 175, 98)),
                  ),
                  child: Icon(
                   widget.isThisNotificationToMe
                  ? Icons.notifications
                      : Icons.send,

                  color: const Color.fromARGB(255, 235, 175, 98),
                    size: 30,
                  ),
                ),
              ),
              title: Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: _isExpanded ? null : 2,
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (isLongDescription)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded
                            ? S.of(context).read_more
                            : S.of(context).show_less,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  Text(
                    widget.time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  // Conditionally show the Accept/Denied/Deleted buttons
                  if (widget.showAcceptDeniedButtons) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: widget.onAccept ??
                                  ()  {

                                print('Accept clicked');
                              },
                          child: const Text('Accept',
                              style: TextStyle(color: Colors.green)),
                        ),
                        TextButton(
                          onPressed: widget.onDenied ??
                                  () {
                                print('Denied clicked');
                              },
                          child: const Text('Denied',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: widget.onDelete ??
                                () {
                              print('Delete clicked');
                            },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
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

