import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/models/Api_user.dart';
import 'package:files_manager/models/user_report_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/server/dio_settings.dart';
import '../../models/member_model.dart';
import 'user_report_state.dart';
import 'package:dio/dio.dart' as Dio;
import 'dart:html' as html;

class UserReportCubit extends Cubit<UserReportState> {
  UserReportCubit() : super(UserReportInitial());

  Timer? _debounceTimer;
  List<Member> searchMembers = [];
  Member? selectedMember;
  int? userId;


  Future<void> getAllUserReports({
    required BuildContext context,
    required int userId,
    required int pdf,
  }) async {
    try {
      emit(UserReportLoadingState());
      String? token = CashNetwork.getCashData(key: 'token');

      final params = {
        if (pdf != null) 'pdf': pdf.toString(),
      };

      final url = Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: 8000,
        path: 'api/users/$userId/report',
        queryParameters: params,
      ).toString();

      var userReport = dio();
      final response = await userReport.get(
        url,
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        if (pdf == 1) {
          await _convertToPdf(response: response, userId: userId);
        }
        final userReportModel = UserReportModel.fromJson(response.data);
        emit(UserReportSuccessState(userReportModel: userReportModel));
      } else {
        emit(UserReportFailureState(errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      errorHandler(e: e, context: context);
      emit(UserReportFailureState(
          errorMessage: e.response?.data['message'] ?? 'An error occurred'));
    } catch (e) {
      print("catch error +${e.toString()}");
      if (e.toString() ==
          "TypeError: \"message\": type 'String' is not a subtype of type 'int'") {
        Navigator.pop(context);
        Navigator.pop(context);
      }
      emit(UserReportFailureState(errorMessage: 'Catch exception'));
    }
  }

  Future<void> _convertToPdf({
    required Response<dynamic> response,
    required int userId,
  }) async {
    if (response.statusCode == 200) {
      try {
        // Check if the response data is already a List<int> (bytes)
        List<int> bytes;
        if (response.data is List<int>) {
          bytes = response.data;
        } else if (response.data is String) {
          // If the response data is a String, encode it to bytes
          bytes = utf8.encode(response.data);
        } else {
          // If the response data is a JSON object, convert it to a String first
          final jsonString = jsonEncode(response.data);
          bytes = utf8.encode(jsonString);
        }

        // Encode the bytes to base64
        final content = base64Encode(bytes);

        // Create a download link and trigger the download
        final anchor = html.AnchorElement(
          href: 'data:application/pdf;base64,$content',
        )..target = 'blank'
          ..download = "User_${userId}_Report.pdf";
        anchor.click();
      } catch (e) {
        print('Error converting to PDF: $e');
        throw Exception('Failed to convert response to PDF: $e');
      }
    } else {
      throw Exception('Failed to fetch PDF: ${response.statusCode}');
    }
  }

  /// Updates the filters with the selected user ID.
  void updateFilters({int? userId}) {
    this.userId = userId ?? this.userId;
  }

  /// Searches for users by name with a debounce mechanism.
  Future<void> search({
    required BuildContext context,
    required String userName,
  }) async {
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    if (userName.isEmpty) {
      searchMembers = [];
      emit(UserReportNoDataState());
      return;
    }


    _debounceTimer = Timer(const Duration(milliseconds: 1000), () async {
      try {
        emit(UserReportLoadingUserState());

        String? token = CashNetwork.getCashData(key: 'token');
        final response = await dio().get(
          'users/search?name=$userName',
          options: Dio.Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );

        if (response.statusCode == 200) {
          List<UserModel> users = (response.data['data'] as List)
              .map((userJson) => UserModel.fromJson(userJson))
              .toList();

          searchMembers = users.map((user) => Member.fromUserModel(user)).toList();

          if (searchMembers.isEmpty) {
            // No users found, emit no data state
            emit(UserReportNoDataState());
          } else {
            // Emit a state to show the search results
            emit(UserReportSearchResultsState(searchMembers));
          }
        }
      } on DioException catch (e) {
        print('Dio Exception => ${e.response?.data}');
        if (!isClosed) {
          emit(UserReportFailureState(
              errorMessage: e.response?.data['message'] ?? 'Unknown error'));
        }
      } catch (e) {
        print('Catch Exception => $e');
        if (!isClosed) {
          emit(UserReportFailureState(errorMessage: e.toString()));
        }
      }
    });
  }

  /// Selects a member from the search results.
  void selectMember(Member member) {
    selectedMember = member;
    userId = member.id;
    emit(UserReportMemberSelectedState(member));
  }

  /// Applies the filter and fetches the report for the selected member.
  void applyFilter(BuildContext context) {
    if (selectedMember != null && selectedMember!.id != null) {
      getAllUserReports(
        context: context,
        userId: selectedMember!.id!,
        pdf: 0,
      );
    }
  }
}