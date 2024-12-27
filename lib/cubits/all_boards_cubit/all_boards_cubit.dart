import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:dio/dio.dart' as Dio;
import 'package:files_manager/models/folder_model.dart';
import 'package:files_manager/models/file_model.dart';
import 'package:files_manager/models/group.dart';
import 'package:flutter/material.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/models/board_model.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../core/functions/color_to_hex.dart';
import '../../core/shared/connect.dart';
import '../../core/shared/local_network.dart';
import '../../models/member_model.dart';
import '../../models/user_model.dart';

part 'all_boards_state.dart';

class AllBoardsCubit extends Cubit<AllBoardsState> {
  AllBoardsCubit() : super(AllBoardsInitial());
  List<Board> allBoards = [
    // Board(
    //     id: 1,
    //     uuid: '1',
    //     parentId: null,
    //     userId: 1,
    //     allFiles: [
    //       FileModel(
    //           id: 1,
    //           boardId: 1,
    //           title: 'File one',
    //           mode: 'open',
    //           createdAt: DateTime.now(),
    //           updatedAt: DateTime.now()),
    //       FileModel(
    //           id: 2,
    //           boardId: 1,
    //           title: 'File two',
    //           mode: 'open',
    //           createdAt: DateTime.now(),
    //           updatedAt: DateTime.now()),
    //       FolderModel(
    //         id: 1,
    //         boardId: 1,
    //         title: 'Folder one',
    //         mode: 'open',
    //         allFiles: [],
    //         createdAt: DateTime.now(),
    //         updatedAt: DateTime.now(),
    //       )
    //     ],
    //     language: Language(id: 1, name: 'english', code: 'en', direction: 'lr'),
    //     roleInBoard: 'admin',
    //     color: colorToHex(const Color.fromARGB(255, 27, 27, 27)),
    //     tasksCommentsCount: 0,
    //     shareLink: '',
    //     title: 'First Group',
    //     description: 'This group has many files to edit',
    //     icon: '\u{263A}',
    //     hasImage: false,
    //     isFavorite: false,
    //     image: '',
    //     visibility: '',
    //     createdAt: DateTime.now(),
    //     children: [],
    //     members: [
    //       Member(
    //           id: 1,
    //           country:
    //               Country(id: 1, name: 'damascus', iso3: '+963', code: '123'),
    //           language:
    //               Language(id: 1, name: 'english', code: 'en', direction: 'lr'),
    //           gender: Gender(id: 1, type: 'male'),
    //           firstName: 'Alaa',
    //           lastName: 'Shibany',
    //           mainRole: 'admin',
    //           role: 'admin',
    //           dateOfBirth: '2002-11-28',
    //           countryCode: '+963',
    //           phone: '981233473',
    //           email: 'alaashibany@gmail.com',
    //           image: '')
    //     ],
    //     invitedUsers: []),
    // Board(
    //     id: 2,
    //     uuid: '2',
    //     parentId: null,
    //     userId: 1,
    //     allFiles: [],
    //     language: Language(id: 1, name: 'english', code: 'en', direction: 'lr'),
    //     roleInBoard: 'admin',
    //     color: colorToHex(const Color.fromARGB(255, 27, 27, 27)),
    //     tasksCommentsCount: 0,
    //     shareLink: '',
    //     title: 'New Group',
    //     description: '',
    //     icon: '\u{263A}',
    //     hasImage: false,
    //     isFavorite: false,
    //     image: '',
    //     visibility: '',
    //     createdAt: DateTime.now(),
    //     children: [],
    //     members: [
    //       Member(
    //           id: 1,
    //           country:
    //               Country(id: 1, name: 'damascus', iso3: '+963', code: '123'),
    //           language:
    //               Language(id: 1, name: 'english', code: 'en', direction: 'lr'),
    //           gender: Gender(id: 1, type: 'male'),
    //           firstName: 'Alaa',
    //           lastName: 'Shibany',
    //           mainRole: 'admin',
    //           role: 'admin',
    //           dateOfBirth: '2002-11-28',
    //           countryCode: '+963',
    //           phone: '981233473',
    //           email: 'alaashibany@gmail.com',
    //           image: '')
    //     ],
    //     invitedUsers: []),
  ];
  List<int> groupsId=[];
  Future<void> addBoard() async {
    allBoards.add(
        Board(
        id: allBoards.last.id + 1,
        uuid: '2',
        parentId: null,
        userId: 1,
        allFiles: [],
        language: Language(id: 1, name: 'english', code: 'en', direction: 'lr'),
        roleInBoard: 'admin',
        color: colorToHex(const Color.fromARGB(255, 27, 27, 27)),
        tasksCommentsCount: 0,
        shareLink: '',
        title: 'New Group',
        description: '',
        icon: '\u{263A}',
        hasImage: false,
        isFavorite: false,
        image: '',
        visibility: '',
        createdAt: DateTime.now(),
        children: [],
        members: [
          Member(
              id: 1,
              country:
                  Country(id: 1, name: 'damascus', iso3: '+963', code: '123'),
              language:
                  Language(id: 1, name: 'english', code: 'en', direction: 'lr'),
              gender: Gender(id: 1, type: 'male'),
              firstName: 'Alaa',
              lastName: 'Shibany',
              mainRole: 'admin',
              role: 'admin',
              dateOfBirth: '2002-11-28',
              countryCode: '+963',
              phone: '981233473',
              email: 'alaashibany@gmail.com',
              image: '')
        ],
        invitedUsers: []));
    emit(AllBoardsInitial());
  }

  final int pageSize = 10;
  PagingController<int, Board> pagingController =
      PagingController(firstPageKey: 1);

  Future<void> initState({
    required BuildContext context,
  }) async {
    getAllBoards(context: context);
    // pagingController.addPageRequestListener((pageKey) {
    //   getAllBoards(
    //     context: context,
    //     pageKey: pageKey,
    //   );
    // });
  }

  Future<void> refresh() async {
    emit(AllBoardsInitial());
  }

  Future<void> refreshData() async {
    allBoards.clear();
    pagingController.itemList!.clear();
    pagingController.refresh();
  }

  Future<void> addNewBoard({required Board newBoard}) async {
    if (pagingController.itemList == null) {
    pagingController.itemList = [];
    }

    pagingController.itemList!.add(newBoard);
    allBoards.add(newBoard);

    emit(AllBoardsInitial());
  }



  Future<void> removeBoard({required int index, required int id}) async {
    if (pagingController.itemList != null) {
      pagingController.itemList!.removeAt(index);
    }
    allBoards.removeWhere((e) => e.id == id);
    refresh();
  }
  Future<void> getAllBoards({
    required BuildContext context,
    bool goodResponse = true,
    int groupId = 1,
  }) async {
    try {
      print("=============get Boards====================");
      emit(AllBoardsLoadingState());
      String? token = CashNetwork.getCashData(key: 'token');

      List<Group> allGroups = [];

      // Loop to fetch all groups
      while (goodResponse) {
        final response = await dio().get(
          'group/$groupId',
          options: Dio.Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );

        print('The status code is => ${response.statusCode}');
        print(response.data);

        if (response.statusCode == 200) {
          final groupData = response.data['data']; // The group data in the response
          final Group newGroup = Group.fromJson(groupData);
          allGroups.add(newGroup); // Add the group to the list

          // Check if we have reached the last page
          if (response.data['message'] != 'Success' || response.data['data'] == null) {
            goodResponse = false; // Stop the loop if there's no data
          }

          print('New group fetched: ${newGroup.name}');
          groupId++; // Move to the next group ID
        } else if (response.statusCode == 404) {
          goodResponse = false;
          // Handle the 404 error gracefully: skip this group and continue with the next one
          print('Error: Group not found for group ID $groupId. Skipping to next group.');
        } else {
          // If the response status is not 200 or 404, stop the loop
          goodResponse = false;
          print('Error: Non-200 response, stopping pagination');
        }

        // Optional: Small delay between requests to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Now all groups are fetched, you can work with the list `allGroups`
      print('Total groups fetched: ${allGroups.length}');

      // After fetching groups, you can proceed to fetch the boards
      List<Board> allBoards = [];
      for (Group group in allGroups) {
        final Board newBoard = Board.fromGroup(group);
        allBoards.add(newBoard);
        print('Fetched board for group ${group.name}');
      }

      // Emit success with the boards
      emit(AllBoardsSuccessState(newBoards: allBoards, isReachMax: true));

    } on DioException catch (e) {
      goodResponse = false;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        await checkInternet()
            ? emit(AllBoardsServerState())
            : emit(AllBoardsNoInternetState());
        print('Connection Error.');
        return;
      }
      errorHandlerWithoutInternet(e: e, context: context);

      print('The response is => ${e.response!.data}');
      print('The failed status code is ${e.response!.statusCode}');
      emit(AllBoardsFailedState(errorMessage: e.response!.data['message']));
    } catch (e) {
      goodResponse = false;
      print('================ catch exception =================');
      print(e);
      emit(AllBoardsFailedState(errorMessage: 'Catch exception'));
    }
  }


}
