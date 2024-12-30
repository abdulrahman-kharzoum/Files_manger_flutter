import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:dio/dio.dart' as Dio;
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
  }) async {
    try {
      print("=============get Boards====================");
      emit(AllBoardsLoadingState());
      String? token = CashNetwork.getCashData(key: 'token');

      print("token get boards: $token");
      final response = await dio().get(
        'groups/all',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('The status code is => ${response.statusCode}');
      print(response.data);

      if (response.statusCode == 200) {
        final groupData = response.data['data'];

        if (groupData == null || groupData is! List) {
          print("Unexpected 'data' format");
          emit(AllBoardsFailedState(errorMessage: "Unexpected data format"));
          return;
        }

        // Map the list of groups into `GroupModel`
        List<GroupModel> allGroups = groupData
            .map<GroupModel>((item) => GroupModel.fromJson(item))
            .toList();

        print('Total groups fetched: ${allGroups.length}');


        List<Board> newBoards = allGroups.map((group) {
          final Board newBoard = Board.fromGroup(group);
          allBoards.add(newBoard);
          print('Fetched board for group ${group.name}');
          return newBoard;
        }).toList();

        emit(AllBoardsSuccessState(newBoards: newBoards, isReachMax: true));
      } else {
        print('Failed to fetch boards: ${response.statusCode}');
        emit(AllBoardsFailedState(errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
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
      print('================ catch exception =================');
      print(e);
      emit(AllBoardsFailedState(errorMessage: 'Catch exception'));
    }
  }




}
