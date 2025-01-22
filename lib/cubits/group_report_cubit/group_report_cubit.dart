// group_report_cubit.dart
import 'package:files_manager/models/group_report_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:dio/dio.dart' as Dio;
import 'dart:html' as html;
import '../../core/server/dio_settings.dart';

part 'group_report_state.dart';

class GroupReportCubit extends Cubit<GroupReportState> {
  GroupReportCubit() : super(GroupReportInitial());

  bool includeCreation = true;
  bool includeFileManagement = true;
  bool includeCheckInOut = true;
  bool includeMemberManagement = true;
  int? userId;

  Future<void> getAllGroupReports(
      {required BuildContext context,
      required int groupId,
      required int pdf}) async {
    try {
      emit(GroupReportLoadingState());
      String? token = CashNetwork.getCashData(key: 'token');
      print("==============Group Reports=============");
      print("==============User id $userId=============");
      final params = {
        'include_creation_related': includeCreation ? '1' : '0',
        'include_file_management_related': includeFileManagement ? '1' : '0',
        'include_check_inNout_related': includeCheckInOut ? '1' : '0',
        'include_member_management_related':
            includeMemberManagement ? '1' : '0',
        if (userId != null) 'user_id': userId.toString(),
        if (pdf != null) 'pdf': pdf.toString()
      };
      print("params");
      print(params);

      final url = Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: 8000,
        path: 'api/groups/$groupId/report',
        queryParameters: params,
      ).toString();

      print("Full URL: $url");
      print("Params: $params");
      print(params);
      var groupReport = dio();
      groupReport.options.baseUrl = url;
      final response = await groupReport.get(
        '',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        if (pdf == 1) {
          print("convering..........");
          await convertToPdf(
              context: context, groupId: groupId, response: response);
        }
        final groupReportModel = GroupReportModel(
          data: response.data['data'] != null
              ? (response.data['data'] as List)
                  .map((e) => GroupReportData.fromJson(e))
                  .toList()
              : [],
          message: response.data['message'] ?? '',
        );
        // GroupReportModel.fromJson(response.data);
        emit(GroupReportSuccessState(groupReportModel: groupReportModel));
      } else {
        emit(GroupReportFailureState(errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      print("dio error +${e.toString()}");
      errorHandler(e: e, context: context);
      emit(GroupReportFailureState(
          errorMessage: e.response?.data['message'] ?? 'An error occurred'));
    } catch (e) {
      print("catch error +${e.toString()}");
      if (e.toString() ==
          "TypeError: \"message\": type 'String' is not a subtype of type 'int'") {
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        emit(GroupReportFailureState(errorMessage: 'Catch exception'));
      }
    }
  }

  void updateFilters({
    bool? creation,
    bool? fileManagement,
    bool? checkInOut,
    bool? memberManagement,
    int? userId,
  }) {
    includeCreation = creation ?? includeCreation;
    includeFileManagement = fileManagement ?? includeFileManagement;
    includeCheckInOut = checkInOut ?? includeCheckInOut;
    includeMemberManagement = memberManagement ?? includeMemberManagement;
    this.userId = userId ?? this.userId;
  }

  Future<void> convertToPdf({
    required BuildContext context,
    required int groupId,
    required Response<dynamic> response,
  }) async {
    try {
      // emit(FileReportPdfLoadingState());
      String? token = CashNetwork.getCashData(key: 'token');
      print("================== Group Report Pdf===========");

      if (response.statusCode == 200) {
        print('Response data type: ${response.data.runtimeType}');
        print('Response data: ${response.data}');
        print('Response data: ${response.data['data']}');

        final bytes = response.data is String
            ? utf8.encode(response.data)
            : response.data;

        final content = base64Encode(bytes);

        final mimeType = 'application/pdf';

        final anchor = html.AnchorElement(
          href: 'data:$mimeType;base64,$content',
        )
          ..target = 'blank'
          ..download = "Group_${groupId}_Report.pdf";

        anchor.click();
        print('File downloaded successfully as File_${groupId}_Report.pdf');
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
