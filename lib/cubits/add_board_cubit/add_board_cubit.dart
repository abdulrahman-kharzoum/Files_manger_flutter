import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/models/board_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/Api_user.dart';
import '../../models/group.dart';
import '../../models/user_model.dart';
import '../board_settings_cubit/board_settings_cubit.dart';

part 'add_board_state.dart';

class AddBoardCubit extends Cubit<AddBoardState> {
  AddBoardCubit() : super(AddBoardInitial());
  late Board createdBoard;
  int group_id = 0;

  Future<int> addBoard({
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
      if (response.statusCode == 200) {
        GroupModel newGroup = GroupModel.fromJson(response.data['data']);

        createdBoard = Board.fromGroup(newGroup);
        group_id = newGroup.id;

        emit(AddBoardSuccessState(
            isSubBoard: false, createdBoard: createdBoard));
        return group_id;
      }
    } on DioException catch (e) {
      errorHandler(e: e, context: context);

      print('The response is => ${e.response!.data}');
      emit(AddBoardFailedState(errorMessage: e.response!.data['message']));
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(AddBoardFailedState(errorMessage: 'Catch exception'));
    }
    return -1;
  }
}
