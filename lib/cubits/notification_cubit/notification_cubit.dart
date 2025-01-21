import 'package:bloc/bloc.dart';
import 'package:files_manager/models/notification_model.dart';
import 'package:flutter/material.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final List<NotificationModel> _notifications = [];

  NotificationCubit() : super(NotificationInitial());

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // Add new notifications at top
    emit(NotificationLoaded(notifications: List.of(_notifications)));
  }

  void clearNotifications() {
    _notifications.clear();
    emit(NotificationLoaded(notifications: []));
  }
}