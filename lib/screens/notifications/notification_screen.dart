import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/widgets/home/custom_appbar.dart';
import 'package:intl/intl.dart';

import '../../core/animation/dialogs/dialogs.dart';
import 'package:files_manager/cubits/notification_cubit/notification_cubit.dart';

import '../../models/notification_model.dart';
import '../../widgets/notification/notificationModel_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(
        title: S.of(context).notifications,
        autoLeading: false,
      ),
      backgroundColor: Theme.of(context).textTheme.headlineSmall!.color,
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          // if (state is NotificationLoading) {
          //   loadingDialog(context: context, mediaQuery: mediaQuery);
          // }
          // if (state is NotificationError) {
          //   // Navigator.pop(context);
          //   errorDialog(context: context, text: state.message);
          // }
        },
        builder: (context, state) {
          if (state is NotificationLoaded) {
            return _buildNotificationsList(state.notifications, context);
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildNotificationsList(
      List<NotificationModel> notifications, BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Text(
          S.of(context).no_notifications,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationModelCard(
          title: notification.title,
          body: notification.body,
          time: DateFormat('yyyy-MM-d HH:mm:ss').format(notification.time),
          isRead: notification.isRead,
        ).animate().fade(duration: 500.ms);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
