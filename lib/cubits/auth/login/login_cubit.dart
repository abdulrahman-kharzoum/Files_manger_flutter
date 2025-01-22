import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:files_manager/core/functions/statics.dart';
import 'package:files_manager/cubits/notification_cubit/notification_cubit.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/core/shared/local_network.dart';

import '../../../core/animation/dialogs/dialogs.dart';
import '../../../core/notification/notification_web.dart';
import '../../../core/shared/connect.dart';


import '../../../generated/l10n.dart';
import '../../../models/Api_user.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  bool showPassword = false;

  // final firebaseMessaging = FirebaseMessaging.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      emit(LoginLoading());
      final notificationCubit = NotificationCubit();
      final notificationService = NotificationService(notificationCubit);

      notificationService.initialize();
      String? fcmToken =
          "jsdklfjsdklfjsdklfjsdklfjsdkljsdffffffffffffffffffffffffffffdsfffffffffjsdklfjsdklfjsdklfjsdklfjsdkljsdffffffffffffffffffffffffffffdsfffffffffjsdklfjsdklfjsdklfjsdklfjsdkljsdfffffffffffffffffffffffffffffffffffffffffffdsfffffffff";
      fcmToken  =  await notificationService.getToken();
      print("=============Check Internet===========");
      // if (!Statics.isPlatformDesktop) {

        if (!await checkInternet()) {
          internetToast(context: context);

          // Navigator.of(context).;
          return;
        // }
      // } else {
      //   print("=============Check Internet For web===========");
      //   if (!await hasNetwork()!) {
      //     internetToast(context: context);
      //     Navigator.of(context);
      //     return;
      //   }
      }
      print("==========fcm==========");
      print(await notificationService.getToken());
      print("=============Internet Found===========");
      // print('The fcm token we will send to back => ${fcmToken.toString()}');
      // await FirebaseMessaging.instance.deleteToken().then(
      //   (value) async {
      //     firebaseMessaging.subscribeToTopic('mosh_task_topic');
      //     fcmToken = await firebaseMessaging.getToken();
      //     await CashNetwork.insertToCash(
      //         key: 'fcm_token', value: fcmToken.toString());
      //   },
      // );

      print('The fcm token is => $fcmToken');
      final response = await dio().post('/auth/login', data: {
        'email': email,
        'password': password,
        'fcm_token': fcmToken,
      });
      if (response.statusCode == 200) {
        print('success');
        final responseData = response.data['data'];
        String token = responseData['token']['token'];
        await CashNetwork.insertToCash(key: 'token', value: token);
        final userModel = responseData['user'];
        await CashNetwork.insertToCash(
            key: 'userId', value: userModel['id'].toString());
        UserResponse userResponse = UserResponse.fromJson(response.data);

        await CashNetwork.insertToCash(
            key: 'user_model', value: jsonEncode(userResponse.user));
        var user_model = await CashNetwork.getCashData(key: 'user_model');
        var uu = UserModel.fromJson(jsonDecode(user_model));
        print("email :${uu.email}");
        print("username  :${uu.name}");

        print('------login response');
        print(response.data);
        print('------------------------------------------------');
        emit(LoginSuccess());
      }

    } on DioException catch (e) {
      print('Dio Error is ${e.message}');
      print('Type Dio Error is ${e.type}');
      Navigator.pop(context);
      errorHandler(e: e, context: context);
      print('==============dio exception ====================');
      if (e.response!.statusCode! > 400) {
        print('The response code is => ${e.response!.statusCode!}');
        emit(LoginFailure(errorMessage: S.of(context).login_faild));
       return;
      }
      print('The response code is => ${e.response!.statusCode!}');
      print(e.response);
      emit(LoginFailure(errorMessage: S.of(context).login_faild));
      return;
    } catch (e) {
      print('General Error is $e');

      print('================catch exception ======================');
      emit(LoginFailure(errorMessage: S.of(context).login_faild));
      return;
    }
  }

  void toggleShowPassword(bool show) {
    emit(ShowPassword(show: show));
  }
}
