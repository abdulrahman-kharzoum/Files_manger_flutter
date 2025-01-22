import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as Dio;

import 'package:files_manager/models/file_version.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

import '../../core/functions/apis_error_handler.dart';
import '../../core/server/dio_settings.dart';
import '../../core/shared/local_network.dart';

part 'file_versions_state.dart';

class FileVersionsCubit extends Cubit<FileVersionsState> {
  FileVersionsCubit({required this.fileId}) : super(FileVersionsInitial());
  List<FileVersion> allVersions = [];
  final int fileId;
  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  Future downloadComparisonFile(
      {required FileVersion file,
      required String fileName,
      required BuildContext context}) async {
    if (file.comparison.isNotEmpty) {
      // emit(FileVersionsDownloadLoadingState());
      try {
        final blob = html.Blob([file.comparison]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = '$fileName-${file.version}';
        anchor.click();
        html.Url.revokeObjectUrl(url);
        // Navigator.of(context).pop();
      } catch (e) {
        // Navigator.of(context).pop();
        FileVersionsErrorState(errorMessage: e.toString());
      }
    } else {
      try {
        emit(FileVersionsDownloadLoadingState());
        final client = dio();
        client.options.baseUrl = 'http://127.0.0.1:8000';
        final response = await client.get(
          '/storage/${file.path}',
          onReceiveProgress: showDownloadProgress,
          options: Dio.Options(
            responseType: ResponseType.bytes,
          ),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          Uint8List bytes = Uint8List.fromList(response.data);
          if (kIsWeb) {
            final blob = html.Blob([bytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor = html.AnchorElement(href: url)
              ..target = 'blank'
              ..download = '$fileName-${file.version}';
            anchor.click();
            html.Url.revokeObjectUrl(url);
          } else {
            var tempDir = await getApplicationDocumentsDirectory();
            String fullPath = tempDir.path + "/$fileName-${file.version}";
            File newFile = File(fullPath);
            var raf = newFile.openSync(mode: FileMode.write);
            raf.writeFromSync(bytes);
            await raf.close();
          }
          Navigator.pop(context);
          emit(FileVersionsDownloadSuccessState());
        }
      } on DioException catch (e) {
        Navigator.pop(context);
        errorHandler(e: e, context: context);
        print('The response is => ${e.response!.data}');
        print('The failed status code is ${e.response!.statusCode}');
        emit(FileVersionsErrorState(errorMessage: e.response!.data['message']));
      } catch (e) {
        Navigator.pop(context);
        print('================ catch exception =================');
        print(e);
        emit(FileVersionsErrorState(errorMessage: 'Catch exception'));
        print(e);
      }
    }
  }

  Future<void> getAllVersions({
    required BuildContext context,
  }) async {
    try {
      emit(FileVersionsLoadingState());
      allVersions.clear();
      String? token = CashNetwork.getCashData(key: 'token');
      final response = await dio().get(
        '/file-history/all',
        queryParameters: {'file_id': fileId},
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('The status code is => ${response.statusCode}');
      print(response.data);
      if (response.statusCode == 200) {
        final jsonData = await response.data['data'] as List;
        allVersions =
            await jsonData.map((e) => FileVersion.fromJson(e)).toList();
        emit(FileVersionsSuccessState());
      }
    } on DioException catch (e) {
      errorHandler(e: e, context: context);
      if (e.response!.statusCode == 401) {
        emit(FileVersionsExpiredState());
        return;
      }
      print('The response is => ${e.response!.data}');
      print('The failed status code is ${e.response!.statusCode}');
      emit(FileVersionsErrorState(errorMessage: e.response!.data['message']));
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(FileVersionsErrorState(errorMessage: 'Catch exception'));
      print(e);
    }
  }
}
