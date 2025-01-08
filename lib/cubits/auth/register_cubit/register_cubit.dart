import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:files_manager/models/Api_user.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/core/shared/connect.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'dart:convert';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  bool showPassword = false;
  final emailController = TextEditingController();

  final userNameController = TextEditingController();
  final reEnterPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final whatsappNumberController = TextEditingController();
  String? countryCode;

  String? selectedLanguage;

  DateTime? selectedDateOfBirth = DateTime.now();
  List<Country> countries = [];
  List<Language> languages = [];
  List<Gender> genders = [];

  final formKey = GlobalKey<FormState>();

  void toggleShowPassword(bool show) {
    emit(ShowPassword(show: show));
  }

  // final firebaseMessaging = FirebaseMessaging.instance;
  final box = Hive.box('main');

  Future<void> register({required BuildContext context}) async {
    print('step1');
    try {
      String? fcmToken = "jsdklfjsdklfjsdklfjsdklfjsdkljsdffffffffffffffffffffffffffffdsfffffffffjsdklfjsdklfjsdklfjsdklfjsdkljsdffffffffffffffffffffffffffffdsfffffffffjsdklfjsdklfjsdklfjsdklfjsdkljsdfffffffffffffffffffffffffffffffffffffffffffdsfffffffff";
      // if (!await checkInternet()) {
      //   internetToast(context: context);
      //   return;
      // }
      emit(RegisterLoadingState());
      print('step2');
      // await FirebaseMessaging.instance.deleteToken().then(
      //   (value) async {
      //     fcmToken = await firebaseMessaging.getToken();
      //   },
      // );
      print('step3');

      Map<String, dynamic> data = {

        'name': userNameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'fcm_token': fcmToken,
      };

      String jsonData = jsonEncode(data);

      print('Data Before Send Register is $jsonData');


      print('FCM Token To Send Is :=>  $fcmToken');
      final response = await dio().post('auth/register', data: jsonData);

      if ( response.statusCode == 200) {
      print(response.data['message']);

      final responseData = response.data['data'];
      UserResponse userResponse = UserResponse.fromJson(response.data);


      final userModel = responseData['user'];
      final token = responseData['token'];

      print('User ID: ${userModel['id']}');
      print('Token: $token');


      await CashNetwork.insertToCash(key: 'token', value: token);
      await CashNetwork.insertToCash(key: 'userId', value: userModel['id'].toString());


      await CashNetwork.insertToCash(key: 'user_model', value:jsonEncode(userResponse.user));
      var user_model = await CashNetwork.getCashData(key: 'user_model');
     var uu=  UserModel.fromJson(jsonDecode(user_model));
     print("email :${uu.email}");
     print("username  :${uu.name}");
      String tokenuser = userResponse.token.type;

      print('Token : ${ userResponse.token.token}');
      print('Token type: $tokenuser');


      emit(RegisterSuccessState());

        print('------register response');
        print(response.data);
        print('------------------------------------------------');
        emit(RegisterSuccessState());
      }
    } on DioException catch (e) {
      Navigator.pop(context);
      print(e.toString());
      errorHandler(e: e, context: context);
      print('================dio exception ====================');
      if (e.response!.statusCode! > 400) {
        print('The response code is => ${e.response!.statusCode!}');
        print('The Message response code is => ${e.response!.data['message']}');
        emit(
          RegisterFailureState(errorMessage: e.response!.data['message']),
        );
        return;
      }
      emit(RegisterFailureState(errorMessage: e.response!.data.toString()));
    } catch (e) {
      print('General error is : $e');
      print('=============catch exception =========================');
      Navigator.of(context).pop;
      emit(RegisterFailureState(errorMessage: e.toString()));
    }
  }



  void setSelectedLanguage(String? language) {
    selectedLanguage = language;
    emit(RegisterLanguageChanged());
  }



  void setDateOfBirth(DateTime date) {
    selectedDateOfBirth = date;
    emit(RegisterDateOfBirthChanged());
  }


// Fetch Language Function
  Future<void> fetchLanguageFunction(BuildContext context) async {
    emit(FetchDataLoading());
    try {
      String? token = CashNetwork.getCashData(key: 'token');
      final response = await dio().get(
        'languages/get-all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data['languages']['data'];
        print(data);

        languages = List<Language>.from(
            data.map((item) => Language(item['id'].toString(), item['name'])));
        emit(FetchDataSuccess());
      } else {
        emit(FetchDataFailure(errorMessage: response.data));
      }
    } catch (e) {
      emit(FetchDataFailure(errorMessage: e.toString()));
    }
  }


}

class Country {
  final String id;
  final String name;

  Country(this.id, this.name);
}

class Language {
  final String id;
  final String name;

  Language(this.id, this.name);
}

class Gender {
  final String id;
  final String name;

  Gender(this.id, this.name);
}
