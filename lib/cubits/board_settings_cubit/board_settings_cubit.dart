import 'dart:async';

import 'dart:io';


import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/models/Api_user.dart';
import 'package:files_manager/models/group.dart';
import 'package:files_manager/models/member_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:files_manager/core/functions/color_to_hex.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/cubits/locale_cubit/locale_cubit.dart';
import 'package:files_manager/models/board_model.dart';

import '../../core/shared/local_network.dart';


part 'board_settings_state.dart';

class BoardSettingsCubit extends Cubit<BoardSettingsState> {
  BoardSettingsCubit({required this.currentBoard})
      : super(BoardSettingsInitial());
  final Board currentBoard;
  TextEditingController boardTitleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  late String selectedColor;
  bool emojiKeyboard = false;
  Timer? _debounceTimer;
  List<dynamic> searchMembers = [];

  Future<void> initState() async {
    boardTitleController = TextEditingController(text: currentBoard.title);
    descriptionController =
        TextEditingController(text: currentBoard.description);

    await resetSearch();
    if (currentBoard != null) {
      // If currentBoard is provided, use its values to pre-populate the settings
      boardTitleController = TextEditingController(text: currentBoard!.title);
      selectedColor = currentBoard!.color;
    } else {
      // If no board is provided, set default values for a new board
      boardTitleController = TextEditingController();
      selectedColor = '#FFFFFF'; // Default color for new boards
    }

    emit(BoardSettingsInitial());
  }

  Future<void> resetSearch() async {
    searchMembers.clear();
    print('all members in original list is => ${currentBoard.members}');
    searchMembers = [...currentBoard.members, ...currentBoard.invitedUsers];
    print('all members in search list is => $searchMembers');
    searchController.clear();
    emit(BoardSettingsInitial());
  }

  // Future<void> search() async {
  //   searchMembers.clear();
  //   if (searchController.text.isEmpty) {
  //     await resetSearch();
  //     return;
  //   }
  //   searchMembers = currentBoard.members
  //       .where(
  //         (element) => '${element.firstName} ${element.lastName}'
  //             .toLowerCase()
  //             .contains(searchController.text.toLowerCase()),
  //       )
  //       .toList();
  //
  //   // searchMembers.addAll(invitations);
  //   emit(BoardSettingsInitial());
  // }
  Future<void> search({
    required BuildContext context,
    required String userName,
  }) async {
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    if (userName.isEmpty) {

      searchMembers = [];
      emit(BoardSettingsNoDataState());
      return;
    }

    // Start a new debounce timer for search
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () async {
      try {
        emit(BoardSettingsSearchLoadingState());

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

          List<Member> members =
          users.map((user) => Member.fromUserModel(user)).toList();

          searchMembers = members;

          emit(BoardSettingsSearchSuccessState());
        }
      } on DioException catch (e) {
        print('Dio Exception => ${e.response?.data}');
        if (!isClosed) {
          emit(BoardSettingsFailedState(
              errorMessage: e.response?.data['message'] ?? 'Unknown error'));
        }
      } catch (e) {
        print('Catch Exception => $e');
        if (!isClosed) {
          emit(BoardSettingsFailedState(errorMessage: 'Unexpected error'));
        }
      }
    });
  }


  Future<void> getBoardInfo(
      {required BuildContext context, required int groupId}) async {
    try {
      print("===============Group  INFO====================");
      emit(BoardSettingsSearchLoadingState());
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
        currentBoard.members = groupModel.members!
            .map((user) => Member.fromUserModel(user))
            .toList();



      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {

        print('Connection Error.');
        return;
      }
      errorHandlerWithoutInternet(e: e, context: context);

      print('The response is => ${e.response!.data}');
      print('The failed status code is ${e.response!.statusCode}');
      emit(BoardSettingsFailedState(
          errorMessage: e.response!.data['message']));
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(BoardSettingsFailedState(errorMessage: 'Catch exception'));
    }
  }
  Future<void> inviteUser({
    required BuildContext context,
    required int userId,
    required int groupId,
  }) async {
    try {
      emit(BoardSettingsInviteLoadingState());

      String? token = CashNetwork.getCashData(key: 'token');

      final invitationExpiryDate =
      DateTime.now().add(Duration(days: 2)).toString().split('.')[0];

      var requestData = {
        'group_id': groupId,
        'user_id': userId,
        'invitation_expires_at': invitationExpiryDate,
      };

      final response = await dio().post(
        'group-invitations/create',
        data: requestData,
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print("Invite has been Sent");

        // Send push notification to the user via Firebase
        // await _sendNotificationToUser(userId, groupId, invitationExpiryDate);

        emit(BoardSettingsInviteSuccessState());
      }
    } on DioException catch (e) {
      print('Dio Exception => ${e.response?.data}');
      if (!isClosed) {
        emit(BoardSettingsFailedState(
            errorMessage: e.response?.data['message'] ?? 'Unknown error'));
      }
    } catch (e) {
      print('Catch Exception => $e');
      if (!isClosed) {
        emit(BoardSettingsFailedState(errorMessage: 'Unexpected error'));
      }
    }
  }
  Future<void> kickUser({
    required BuildContext context,
    required int userId,
    required int groupId,
  }) async {
    try {
      emit(BoardSettingsKickLoadingState());

      String? token = CashNetwork.getCashData(key: 'token');



      final response = await dio().delete(
        'groups/$groupId/users/$userId/kick',

        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print("User Kicked ");


        emit(BoardSettingsKickedSuccessState());
      }
    } on DioException catch (e) {
      print('Dio Exception => ${e.response?.data}');
      if (!isClosed) {
        emit(BoardSettingsFailedState(
            errorMessage: e.response?.data['message'] ?? 'Unknown error'));
      }
    } catch (e) {
      print('Catch Exception => $e');
      if (!isClosed) {
        emit(BoardSettingsFailedState(errorMessage: 'Unexpected error'));
      }
    }
  }



  Future<void> selectLanguage(String newValue, LocaleCubit localCubit) async {
    if (newValue == 'default') {
      currentBoard.language.code = localCubit.locale.languageCode;
    } else {
      currentBoard.language.code = newValue;
    }
    emit(BoardSettingsInitial());
    await Future.delayed(const Duration(milliseconds: 5));
    emit(BoardSettingsInitial());
  }

  Future<void> refresh() async {
    emit(BoardSettingsInitial());
  }

  Future<void> showEmojiKeyboard() async {
    emojiKeyboard = !emojiKeyboard;
    emit(BoardSettingsInitial());
  }

  Future<void> selectEmoji(String newIcon) async {
    currentBoard.icon = newIcon;
    emit(BoardSettingsInitial());
  }

  Future<void> changeDescription() async {
    currentBoard.description = descriptionController.text;
    emit(BoardSettingsInitial());
  }

  Future<void> selectColor(int index) async {
    currentBoard.boardColorIndex = index;
    currentBoard.color = colorToHex(allColors[index]['real']!);
    emit(BoardSettingsInitial());
  }

  Future<void> changeTitle() async {
    currentBoard.title = boardTitleController.text;
    emit(BoardSettingsInitial());
  }

  Future<void> changePrivacy({required String value}) async {
    currentBoard.visibility = value;
    emit(BoardSettingsInitial());
  }

  Future<void> pickBoardImage({required CroppedFile? file}) async {
    currentBoard.imageFile = File(file!.path);
    currentBoard.hasImage = true;
    emit(BoardSettingsInitial());
  }

  Future<void> deleteBoardImage() async {
    currentBoard.imageFile = null;
    currentBoard.hasImage = false;
    emit(BoardSettingsInitial());
  }


  Future<void> updateBoard({
    required BuildContext context,
    required int groupId,
    required String title,
    required String description,
    required String color,
    required String lang,
  }) async {
    try {
      emit(BoardSettingsLoadingState());

      String? token = CashNetwork.getCashData(key: 'token');
      var requestData;
      if (title != currentBoard.title) {
        print("=============The Title Changed?!==============");
        print("title $title");
        print("currentBoard title ${currentBoard.title}");
        requestData = {
          'name': currentBoard.title,
          'description': description,
          'color': color,
          'lang': lang,
        };
      } else {
        requestData = {
          'description': description,
          'color': color,
          'lang': lang,
        };
      }

      final response = await dio().put(
        'groups/update/$groupId',
        data: requestData,
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print("Group has been updated");

        if (!isClosed) emit(BoardSettingsSuccessState());
        print("After BoardSettingsSuccessState");
      }
    } on DioException catch (e) {
      print('Dio Exception => ${e.response!.data}');
      if (!isClosed) {
        emit(BoardSettingsFailedState(
            errorMessage: e.response!.data['message']));
        print("After BoardSettingsFailedState (DioException)");
      }

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      print('Catch Exception => $e');
      if (!isClosed) {
        emit(BoardSettingsFailedState(errorMessage: 'Catch exception'));
        print("After BoardSettingsFailedState");
      }

      if (context.mounted) Navigator.pop(context);
    }
  }
}
