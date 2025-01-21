import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/shared/connect.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/interfaces/applications_abstract.dart';
import 'package:files_manager/models/file_model.dart';
import 'package:files_manager/models/folder_model.dart';
import 'package:files_manager/models/group.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as Dio;
import '../../core/server/dio_settings.dart';
import '../../models/Api_user.dart';
import '../../models/invite_model.dart';

part 'pending_state.dart';

class PendingCubit extends Cubit<PendingState> {
  PendingCubit() : super(PendingInitial());
  final List<Application> applicationsToApprove = [];
  int? group_id ;
  List<Invite> invitations = [];

  Future<void> getAllFilesToApprove({
    required BuildContext context,
    required int groupId,
  }) async {
    try {
      print("===============Approve Folder FILES====================");
      group_id = groupId;
      emit(PendingLoading());
      String? token = CashNetwork.getCashData(key: 'token');

      print("token get boards: $token");
      final response = await dio().get(
        '/groups/$groupId/files-to-approve',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('The status code is => ${response.statusCode}');
      print(response.data);

      if (response.statusCode == 200) {
        if (response.data['data'] == null || (response.data["data"] as List).isEmpty){
          emit(PendingNoData());
          print("no data");
          return;


        }
        final FilesList = response.data['data'] as List;
        applicationsToApprove.clear();

        for (int i = 0; i < FilesList.length; i++) {
          FileApiModel file = FileApiModel.fromJson(FilesList[i]);

          if (file.extension == null) {
            FolderModel folderModel = FolderModel.fromFileApi(file, groupId);

            applicationsToApprove.add(folderModel);
          } else {
            FileModel fileModel = FileModel.fromFileApi(file, groupId);
            applicationsToApprove.add(fileModel);
          }
        }

        emit(PendingToAprroveFilesSucces(
            applicationsToApprove: applicationsToApprove));
      } else {
        print('Failed to fetch boards: ${response.statusCode}');
        emit(PendingFailedState(errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        await checkInternet()
            ? emit(PendingFailedServerError())
            : emit(PendingFailedNoInternet());
        print('Connection Error.');
        return;
      }
      errorHandlerWithoutInternet(e: e, context: context);

      print('The response is => ${e.response!.data}');
      print('The failed status code is ${e.response!.statusCode}');
      emit(PendingFailedState(errorMessage: e.response!.data['message']));
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(PendingFailedState(errorMessage: 'Catch exception'));
    }
  }

  Future<void> getInvites({
    required BuildContext context,
  }) async {
    try {
      emit(PendingLoading());

      String? token = CashNetwork.getCashData(key: 'token');

      final response = await dio().get(
        'group-invitations/all',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('===================Invitations==============');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        print(response.data['data']);

        if (data == null || (data['invitationsFromMe'] == null && data['invitationsToMe'] == null)) {
          emit(PendingNoData());
          return;
        }
        InvitationResponse invitationResponse =
            InvitationResponse.fromJson(data);

        print(
            'Invitations from me: ${invitationResponse.invitationsFromMe.length}');
        print(
            'Invitations to me: ${invitationResponse.invitationsToMe.length}');

        emit(PendingSuccessState(invitationResponse: invitationResponse));
      } else {
        emit(PendingFailedState(errorMessage: 'Failed to load invites'));
      }
    } on DioException catch (e) {
      print('Dio Exception => ${e.response?.data}');
      if (!isClosed) {
        emit(PendingFailedState(
            errorMessage: e.response?.data['message'] ?? 'Unknown error'));
      }
    } catch (e) {
      print('Catch Exception => $e');
      if (!isClosed) {
        emit(PendingFailedState(errorMessage: 'Unexpected error'));
      }
    }
  }

  Future<void> acceptInvite({
    required BuildContext context,
    required int inviteId,
  }) async {
    try {
      emit(PendingLoading());

      String? token = CashNetwork.getCashData(key: 'token');

      final response = await dio().post(
        'group-invitations/accept/$inviteId',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('===================Invitation Accept==============');
      if (response.statusCode == 200) {
        // final data = response.data['data'];
        // print(response.data['data']);

        // InvitationResponse invitationResponse = InvitationResponse.fromJson(data);
        //
        //
        // print('Invitations from me: ${invitationResponse.invitationsFromMe.length}');
        // print('Invitations to me: ${invitationResponse.invitationsToMe.length}');

        emit(PendingInviteAcceptedSuccessState());
      } else {
        emit(PendingFailedState(errorMessage: 'Failed to load invites'));
      }
    } on DioException catch (e) {
      print('Dio Exception => ${e.response?.data}');
      if (!isClosed) {
        emit(PendingFailedState(
            errorMessage: e.response?.data['message'] ?? 'Unknown error'));
      }
    } catch (e) {
      print('Catch Exception => $e');
      if (!isClosed) {
        emit(PendingFailedState(errorMessage: 'Unexpected error'));
      }
    }
  }
  void emitUpdatedState(List<Invite> updatedInvitations) {
    var userModelData = CashNetwork.getCashData(key: 'user_model');
    var user = UserModel.fromJson(jsonDecode(userModelData));
    emit(PendingSuccessState(
      invitationResponse: InvitationResponse(
        invitationsFromMe: updatedInvitations.where((i) => i.inviterId == user.id).toList(),
        invitationsToMe: updatedInvitations.where((i) => i.userId == user.id).toList(),
        message: 'Invitations updated',
      ),
    ));
  }

  Future<void> deleteInvite({
    required BuildContext context,
    required int inviteId,
    required bool isRejected,
  }) async {
    try {
      emit(PendingLoading());

      String? token = CashNetwork.getCashData(key: 'token');

      final response = await dio().delete(
        'group-invitations/delete/$inviteId',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('===================Invitation Delete==============');
      if (response.statusCode == 200) {
        invitations.removeWhere((invite) => invite.id == inviteId);
        emitUpdatedState(invitations);
        // final data = response.data['data'];
        print(response.data['data']);

        // InvitationResponse invitationResponse = InvitationResponse.fromJson(data);
        //
        //
        // print('Invitations from me: ${invitationResponse.invitationsFromMe.length}');
        // print('Invitations to me: ${invitationResponse.invitationsToMe.length}');
        if(isRejected){
          emit(PendingInviteRejectedSuccessState());
        }else{
          emit(PendingInviteDeletedSuccessState());
        }
      } else {
        emit(PendingFailedState(errorMessage: 'Failed to load invites'));
      }
    } on DioException catch (e) {
      print('Dio Exception => ${e.response?.data}');
      if (!isClosed) {
        emit(PendingFailedState(
            errorMessage: e.response?.data['message'] ?? 'Unknown error'));
      }
    } catch (e) {
      print('Catch Exception => $e');
      if (!isClosed) {
        emit(PendingFailedState(errorMessage: 'Unexpected error'));
      }
    }
  }
  Future<void> acceptOrRejectFile({
    required BuildContext context,
    required String status,
    required int groupId,
    required int fileId,
  }) async {
    try {
      emit(PendingLoading());

      String? token = CashNetwork.getCashData(key: 'token');

      final response = await dio().post(
        'groups/files/decideStatus',
        data: {
          "status":status,
          "group_id":groupId,
          "file_id":fileId
        },
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('===================Accept Or Reject File==============');
      if (response.statusCode == 200) {


        emit(PendingFileAcceptedOrRejectedSuccessState());
      } else {
        emit(PendingFailedState(errorMessage: 'Failed to load invites'));
      }
    } on DioException catch (e) {
      print('Dio Exception => ${e.response?.data}');
      if (!isClosed) {
        emit(PendingFailedState(
            errorMessage: e.response?.data['message'] ?? 'Unknown error'));
      }
    } catch (e) {
      print('Catch Exception => $e');
      if (!isClosed) {
        emit(PendingFailedState(errorMessage: 'Unexpected error'));
      }
    }
  }
}
