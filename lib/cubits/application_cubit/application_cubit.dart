import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:dio/dio.dart' as Dio;
import 'package:files_manager/models/folder_model.dart';
import 'package:files_manager/models/file_model.dart';
import 'package:files_manager/models/group.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/core/shared/connect.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/interfaces/applications_abstract.dart';

part 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  ApplicationCubit() : super(ApplicationInitial());
  final int pageSize = 10;
  final List<int> folderHistory = [];

  PagingController<int, Application> pagingController =
      PagingController(firstPageKey: 1);
  final List<Application> newBoardsApp = [];

  Future<void> initState({
    required BuildContext context,
    required int groupId,
  }) async {
    newBoardsApp.clear();
    getAllFilesBoard(context: context, groupId: groupId);
    // pagingController.addPageRequestListener(
    //   (pageKey) async {
    //     getApplicationsInBoards(context: context, uuid: uuid, pageKey: pageKey);
    //   },
    // );
    emit(ApplicationInitial());
  }

  Future<void> refresh() async {
    emit(ApplicationInitial());
  }

  Future<void> refreshData() async {
    newBoardsApp.clear();
    pagingController.itemList!.clear();
    pagingController.refresh();
  }

  // Future<void> getApplicationsInBoards({
  //   required BuildContext context,
  //   required String uuid,
  //   required int pageKey,
  // }) async {
  //   try {
  //     emit(GetAllApplicationsInBoardLoading());
  //     if (pageKey == 1) {
  //       newBoardsApp.clear();
  //     }
  //     String? token = CashNetwork.getCashData(key: 'token');
  //     print('The page we will get is => $pageKey');
  //     final response = await dio().get(
  //       'board-applications/get-applications-in-board/$uuid',
  //       queryParameters: {'page': pageKey},
  //       options: Dio.Options(
  //         headers: {'Authorization': 'Bearer $token'},
  //       ),
  //     );
  //     print('The status code is => ${response.statusCode}');
  //     print(response.data);
  //     if (response.statusCode == 200) {
  //       final List jsonData =
  //           await response.data['board_applications']['data'] as List;
  //
  //       for (var i = 0; i < jsonData.length; i++) {
  //         if (jsonData[i]['application']['id'] == 1) {
  //           FileModel todoModel = FileModel.fromJson(jsonData[i]);
  //           newBoardsApp.add(todoModel);
  //         } else if (jsonData[i]['application']['id'] == 2) {
  //           FolderModel chatModel = FolderModel.fromJson(jsonData[i]);
  //           newBoardsApp.add(chatModel);
  //         }
  //       }
  //
  //       print('we will emit success');
  //       emit(GetAllApplicationsInBoardSuccess(
  //           newBoardsApp: newBoardsApp,
  //           isReachMax:
  //               response.data['board_applications']['links']['next'] == null));
  //     }
  //     if (response.statusCode == 204) {
  //       emit(GetAllApplicationsInBoardSuccess(
  //           newBoardsApp: const [], isReachMax: false));
  //     }
  //   } on DioException catch (e) {
  //     if (e.type == DioExceptionType.connectionTimeout ||
  //         e.type == DioExceptionType.receiveTimeout ||
  //         e.type == DioExceptionType.connectionError) {
  //       await checkInternet()
  //           ? emit(GetAllApplicationsInBoardServerError())
  //           : emit(GetAllApplicationsInBoardNoInternet());
  //       print('Connection Error.');
  //       return;
  //     }
  //     errorHandlerWithoutInternet(e: e, context: context);
  //     if (e.response!.statusCode == 401) {
  //       emit(GetAllApplicationsInBoardExpiredToken());
  //       return;
  //     }
  //     print('The response is => ${e.response!.data}');
  //     print('The failed status code is ${e.response!.statusCode}');
  //     emit(GetAllApplicationsInBoardFailure(
  //         errorMessage: e.response!.data['message']));
  //   } catch (e) {
  //     print('================ catch exception =================');
  //     print(e);
  //     emit(GetAllApplicationsInBoardFailure(errorMessage: 'Catch exception'));
  //     print(e);
  //   }
  // }
  void navigateBack({required BuildContext context, required int groupId}) {

    if (folderHistory.isNotEmpty) {
      final previousFolderId = folderHistory.removeLast();
      if (folderHistory.isNotEmpty) {
        getAllFilesFolder(context: context, groupId: groupId, folderId: previousFolderId);
      } else {
        getAllFilesBoard(context: context, groupId: groupId);
      }
    } else {
      getAllFilesBoard(context: context, groupId: groupId);
    }

  }


  Future<void> getAllFilesFolder(
      {required BuildContext context,
      required int groupId,
      required int folderId}) async {
    try {
      print("===============Folder FILES====================");
      print("===============Folder $folderId====================");
      emit(GetAllApplicationsInFolderLoading());
      String? token = CashNetwork.getCashData(key: 'token');

      print("token get boards: $token");
      final response = await dio().get(
        'files/$folderId/children',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('The status code is => ${response.statusCode}');
      print(response.data);

      if (response.statusCode == 200) {
        final FilesList = response.data['data'] as List;
        newBoardsApp.clear();
        for (int i = 0; i < FilesList.length; i++) {
          FileApiModel file = FileApiModel.fromJson(FilesList[i]);
          if (file.extension == null) {
            FolderModel folderModel = FolderModel.fromFileApi(file, groupId);
            newBoardsApp.add(folderModel);
          } else {
            FileModel fileModel = FileModel.fromFileApi(file, groupId);
            newBoardsApp.add(fileModel);
          }
        }
        print('we will emit success');

        emit(GetAllApplicationsInFolderSuccess(newBoardsApp: newBoardsApp));

      } else {
        print('Failed to fetch boards: ${response.statusCode}');
        emit(GetAllApplicationsInBoardFailure(
            errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        await checkInternet()
            ? emit(GetAllApplicationsInBoardServerError())
            : emit(GetAllApplicationsInBoardNoInternet());
        print('Connection Error.');
        return;
      }
      errorHandlerWithoutInternet(e: e, context: context);

      print('The response is => ${e.response!.data}');
      print('The failed status code is ${e.response!.statusCode}');
      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response!.data['message']));
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(GetAllApplicationsInBoardFailure(errorMessage: 'Catch exception'));
    }
  }

  Future<void> getAllFilesBoard(
      {required BuildContext context, required int groupId}) async {
    try {
      print("===============Boards FILES====================");
      emit(GetAllApplicationsInBoardLoading());
      String? token = CashNetwork.getCashData(key: 'token');

      final response = await dio().get(
        'groups/show/$groupId',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('The status code is => ${response.statusCode}');
      print(response.data);

      if (response.statusCode == 200) {
        final groupData = response.data['data'];
        GroupModel groupModel = GroupModel.fromJson(groupData);
        newBoardsApp.clear();

        for (int i = 0; i < groupModel.files.length; i++) {
          FileApiModel file = groupModel.files[i];
          if(file.parentId == 0 || file.parentId == null){
            print("we are adding.....");
            if (file.extension == null) {
              FolderModel folderModel = FolderModel.fromFileApi(file, groupId);
              newBoardsApp.add(folderModel);
            } else {
              FileModel fileModel = FileModel.fromFileApi(file, groupId);
              newBoardsApp.add(fileModel);
            }
          }

        }
        print('we will emit success');

        emit(GetAllApplicationsInBoardSuccess(
            newBoardsApp: newBoardsApp, isReachMax: true));

      } else {
        print('Failed to fetch boards: ${response.statusCode}');
        emit(GetAllApplicationsInBoardFailure(
            errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        await checkInternet()
            ? emit(GetAllApplicationsInBoardServerError())
            : emit(GetAllApplicationsInBoardNoInternet());
        print('Connection Error.');
        return;
      }
      errorHandlerWithoutInternet(e: e, context: context);

      print('The response is => ${e.response!.data}');
      print('The failed status code is ${e.response!.statusCode}');
      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response!.data['message']));
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(GetAllApplicationsInBoardFailure(errorMessage: 'Catch exception'));
    }
  }
}
