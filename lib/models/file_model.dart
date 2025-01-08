  import 'package:files_manager/models/group.dart';
import 'package:files_manager/models/member_model.dart';
  import 'package:flutter/material.dart';
  import 'package:files_manager/cubits/all_boards_cubit/all_boards_cubit.dart';
  import 'package:files_manager/cubits/application_cubit/application_cubit.dart';
  import 'package:files_manager/cubits/board_cubit/board_cubit.dart';
  import 'package:files_manager/interfaces/applications_abstract.dart';

  import 'package:files_manager/models/task_model.dart';

  class FileModel extends Application {
    BoardCubit? boardCubit;

    String langChatApp = 'default';
    List<TaskModel> tasks = [];
    IconData icon = Icons.file_copy;
    int? applicationColor;
    Member? member;
    FileModel({
      required this.id,
      required this.boardId,
      required this.title,
      required this.mode,
      required this.createdAt,
      required this.updatedAt,
      // required this.applicationName,
      // required this.boardCubit,
    });

    // String applicationName;
    // final BoardCubit boardCubit;

    int id;
    int boardId;

    String title;
    String mode;

    DateTime createdAt;
    DateTime updatedAt;

    factory FileModel.fromJson(Map<String, dynamic> json) {
      return FileModel(
        id: json['id'],
        boardId: json['board_id'],
        title: json['title'],
        mode: json['mode'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
    }


    // Add fromFileApi method
    factory FileModel.fromFileApi(FileApiModel fileApi,int group_id) {
      return FileModel(
        id: fileApi.id,
        boardId: group_id,  // You can assign boardId based on your logic
        title: fileApi.name,
        mode: fileApi.extension ?? 'unknown',
        createdAt: DateTime.now(),  // Assign based on the API response or current time
        updatedAt: DateTime.now(),  // Assign based on the API response or current time
      );
    }

    @override
    Member? getApplicationOwner() {
      return member;
    }

    @override
    IconData getIcon() {
      return icon;
    }

    @override
    bool isFolder() {
      return false;
    }

    @override
    String getApplicationName() {
      return title;
    }

    @override
    void updateApplicationTitle(String title) {
      this.title = title;
    }

    @override
    int getApplicationId() {
      return id;
    }

    @override
    void pushToScreen({
      required BuildContext context,
      Application? application,
      required BoardCubit boardCubit,
      required AllBoardsCubit allBoardCubit,
      required ApplicationCubit applicationCubit,
    }) {
      print('todo navigation');
    }
  }
