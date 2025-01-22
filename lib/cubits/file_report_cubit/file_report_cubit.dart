import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:files_manager/models/file_report_model.dart';
import 'package:dio/dio.dart' as Dio;
import 'dart:html' as html;
import '../../core/server/dio_settings.dart';

part 'file_report_state.dart';

class FileReportCubit extends Cubit<FileReportState> {
  FileReportCubit() : super(FileReportInitial());

  Future<void> getAllFileReports({
    required BuildContext context,
    required int fileId,
  }) async {
    try {
      emit(FileReportLoadingState());
      String? token = CashNetwork.getCashData(key: 'token');
      print("==================All File Reports===========");
      final response = await dio().get(
        'files/$fileId/report',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final fileReportModel = FileReportModel.fromJson(response.data);
        emit(FileReportSuccessState(fileReportModel: fileReportModel));
      } else {
        emit(FileReportFailureState(errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      errorHandler(e: e, context: context);
      emit(FileReportFailureState(
          errorMessage: e.response?.data['message'] ?? 'An error occurred'));
    } catch (e) {
      emit(FileReportFailureState(errorMessage: 'Catch exception'));
    }
  }

  Future<void> getAllFileReportsPdf({
    required BuildContext context,
    required int fileId,
  }) async {
    try {
      // emit(FileReportPdfLoadingState());
      String? token = CashNetwork.getCashData(key: 'token');
      print("==================All File Reports Pdf===========");
      final response = await dio().get(
        'files/$fileId/report?pdf=1',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print('Response data type: ${response.data.runtimeType}');
        print('Response data: ${response.data}');
        print('Response data: ${response.data['data']}');

        final bytes = response.data is String
            ? utf8.encode(response.data)
            : response.data;

        final content = base64Encode(bytes);

        final mimeType =
            'application/pdf';

        final anchor = html.AnchorElement(
          href: 'data:$mimeType;base64,$content',
        )
          ..target = 'blank'
          ..download =
              "File_${fileId}_Report.pdf";

        anchor.click();
        print('File downloaded successfully as File_${fileId}_Report.pdf');
        // emit(FileReportPdfSuccessState());

      } else {
        // emit(FileReportFailureState(errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      // errorHandler(e: e, context: context);
      // emit(FileReportFailureState(
      //     errorMessage: e.response?.data['message'] ?? 'An error occurred'));
    } catch (e) {
      // emit(FileReportFailureState(errorMessage: e.toString()));
    }
  }
}
