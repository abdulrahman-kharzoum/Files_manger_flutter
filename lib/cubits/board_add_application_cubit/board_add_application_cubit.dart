import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:dio/dio.dart' as Dio;
import 'package:file_picker/file_picker.dart';
import 'package:files_manager/models/group.dart';
import 'package:flutter/material.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/interfaces/applications_abstract.dart';

import '../../models/file_model.dart';
import '../../models/folder_model.dart';

part 'board_add_application_state.dart';

class BoardAddApplicationCubit extends Cubit<BoardAddApplicationState> {
  BoardAddApplicationCubit() : super(BoardAddApplicationInitial());

  Future<void> addApplicationFunction({
    required BuildContext context,
    required String fileName,
    required int parent_id,
    required bool is_folder,
    required int group_id,
    PlatformFile? file,
  }) async {
    emit(BoardAddApplicationLoading());

    try {
      String? token = CashNetwork.getCashData(key: 'token');

      // Prepare the data map
      var data = {
        'name': fileName,
        'is_folder': is_folder ? 1 : 0,
        'group_id': group_id,
      };

      if (!is_folder && file != null) {
        if (file.bytes != null) {
          // Use bytes directly for web
          data['path'] = MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          );
        } else if (file.path != null) {
          // Use the path for other platforms
          data['path'] = await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          );
        } else {
          throw Exception('File is invalid. Both path and bytes are null.');
        }
      }

      if (parent_id != 0|| parent_id != null) {
        data['parent_id'] = parent_id.toInt();
      }

      final formData = FormData.fromMap(data);

      print("file name $fileName");
      final response = await dio().post(
        'files/create',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print("===========Folder And Files 200 ====================");
        final fileApi = FileApiModel.fromJson(response.data['data']);
        Application createdApplication = fileApi.extension == null
            ? FolderModel.fromFileApi(fileApi,group_id)
            : FileModel.fromFileApi(fileApi,group_id);

        emit(BoardAddApplicationSuccess(addedApplication: createdApplication));
      } else {
        emit(BoardAddApplicationFailure(
            errorMessage: response.data['message'] ?? 'Error occurred'));
      }
    } on DioException catch (e) {
      errorHandler(e: e, context: context);

      if (e.response?.statusCode == 401) {
        emit(BoardAddApplicationExpiredToken());
      } else {
        emit(BoardAddApplicationFailure(
            errorMessage: e.response?.data['message'] ?? 'Dio error occurred'));
      }
    } catch (e) {
      emit(BoardAddApplicationFailure(
          errorMessage: e.toString()));
    }
  }
}
