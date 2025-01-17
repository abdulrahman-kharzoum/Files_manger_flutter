import 'package:files_manager/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:files_manager/core/animation/dialogs/expired_dialog.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/core/shimmer/notification_shimmer.dart';
import 'package:files_manager/cubits/notification_cubit/notification_cubit.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/theme/color.dart';
import 'package:files_manager/widgets/home/custom_appbar.dart';
import 'package:files_manager/widgets/notification/no_notification.dart';
import 'package:files_manager/widgets/notification/notification_card.dart';
import '../../core/animation/dialogs/dialogs.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final cubit = context.read<NotificationCubit>();
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(title: S.of(context).notifications),
      backgroundColor: Theme.of(context).textTheme.headlineSmall!.color,
      body: Container(
        // margin: EdgeInsets.only(top: mediaQuery.height / 6),
        child: ListView(padding: EdgeInsets.zero, children: [
          NotificationCard(
            notificationModel: NotificationModel(
                id: '1',
                type: 'type',
                notifiableType: '',
                notifiableId: 1,
                task: TaskData(
                    id: 1,
                    title: 'This is the title',
                    description: 'Go and kill some people',
                    time: '2002-20-20',
                    completed: 1,
                    modificationsCount: 1,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    users: []),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()),
            title: 'This is the title',
            content: 'Go and kill some people',
            isRead: false,
            time: '2024-10-20',
          ),
        ]).animate().fade(
          duration: const Duration(milliseconds: 500),
        ),
      ),
    );
  }
}