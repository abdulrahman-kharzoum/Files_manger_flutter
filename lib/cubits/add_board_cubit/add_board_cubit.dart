import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/models/board_model.dart';
import '../../models/Api_user.dart';
import '../../models/group.dart';
import '../../models/user_model.dart';

part 'add_board_state.dart';


class AddBoardCubit extends Cubit<AddBoardState> {
  AddBoardCubit() : super(AddBoardInitial());
  late Board createdBoard;

  Future<void> addBoard({
    required BuildContext context,
    required String title,
    required String description,
    required String color,
    required String lang,
  }) async {
    try {
      emit(AddBoardLoadingState());
      String? token = CashNetwork.getCashData(key: 'token');

      final response = await dio().post(
        'groups/create',
        data: {
          'name': title,
          'description': description,
          'color': color,
          'lang': lang,
        },
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('The status code is => ${response.statusCode}');
      print(response.data);
      if (response.statusCode == 200){
        GroupModel newGroup = GroupModel.fromJson(response.data);
        createdBoard = Board.fromGroup(newGroup);
        emit(AddBoardSuccessState(isSubBoard: false,createdBoard: createdBoard));
      }
    } on DioException catch (e) {
      Navigator.pop(context);
      errorHandler(e: e, context: context);

      print('The response is => ${e.response!.data}');
      emit(AddBoardFailedState(errorMessage: e.response!.data['message']));
    } catch (e) {
      Navigator.pop(context);
      print('================ catch exception =================');
      print(e);
      emit(AddBoardFailedState(errorMessage: 'Catch exception'));
    }
  }
}
