import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/functions/color_to_hex.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/cubits/locale_cubit/locale_cubit.dart';
import 'package:files_manager/models/board_model.dart';

import '../../core/shared/local_network.dart';

import '../../models/user_model.dart';

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

    emit(BoardSettingsInitial());
  }

  Future<void> search() async {
    searchMembers.clear();
    if (searchController.text.isEmpty) {
      await resetSearch();
      return;
    }
    searchMembers = currentBoard.members
        .where(
          (element) => '${element.firstName} ${element.lastName}'
              .toLowerCase()
              .contains(searchController.text.toLowerCase()),
        )
        .toList();

    // searchMembers.addAll(invitations);
    emit(BoardSettingsInitial());
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

  void saveBoard() {
    if (boardTitleController.text.isNotEmpty) {
      final newBoard = Board(
        language: Language(id: 1, name: 'english', code: 'en', direction: 'lr'),
        id: 0,
        // Will be assigned by backend after creation
        uuid: currentBoard?.uuid ?? 'new-board-uuid',
        // UUID for new or existing board
        parentId: currentBoard?.parentId ?? null,
        userId: 1,
        // Example user ID, this should be dynamically set
        roleInBoard: currentBoard?.roleInBoard ?? 'Member',
        // Default role
        color: selectedColor,
        allFiles: [],
        tasksCommentsCount: 0,
        shareLink: '',
        title: boardTitleController.text,
        description: '',
        icon: '',
        hasImage: false,
        isFavorite: false,
        image: '',
        visibility: 'Public',
        createdAt: DateTime.now(),
        children: [],
        members: [],
        invitedUsers: [],
      );

      emit(BoardSettingsSaved(newBoard: newBoard));
    } else {
      emit(BoardSettingsFailedState(errorMessage: 'Board title is required!'));
    }
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

      final response = await dio().put(
        'groups/update/$groupId',
        data: {
          // 'name',
          'description': description,
          'color': color,
          'lang': lang,
        },
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print("group has been updated");

        emit(BoardSettingsSuccessState());
        print("after BoardSettingsSuccessState ");

      }
    } on DioException catch (e) {
      errorHandler(e: e, context: context);

      print('The response is => ${e.response!.data}');
      emit(BoardSettingsFailedState(errorMessage: e.response!.data['message']));
      print("after BoardSettingsFailedState dioEx");

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(BoardSettingsFailedState(errorMessage: 'Catch exception'));
      print("after BoardSettingsFailedState ");

      if (context.mounted) {
        Navigator.pop(context);
      }
      print(e);
    }
  }
}
