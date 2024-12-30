import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/core/shared/connect.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/theme/color.dart';
import 'package:photo_view/photo_view.dart';

import '../../models/Api_user.dart';

part 'profile_state.dart';

//
// String countryId = CashNetwork.getCashData(key: 'country_id');
// String genderId = CashNetwork.getCashData(key: 'gender_id');
// String languageId = CashNetwork.getCashData(key: 'language_id');
// String imageUserCache = CashNetwork.getCashData(key: 'image');

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  final formKey = GlobalKey<FormState>();

  Future<void> init(BuildContext context) async {
    // await fetchCountry(context);
    // await fetchLanguageFunction(context);
    // await fetchGenderFunction(context);
    //
    // String? countryIdFromCash = CashNetwork.getCashData(key: 'country_id');
    // String? languageIdFromCash = CashNetwork.getCashData(key: 'language_id');
    // String? genderIdFromCash = CashNetwork.getCashData(key: 'gender_id');
    // selectedCountry = countries.firstWhere(
    //   (country) => country.id == countryIdFromCash,
    //   orElse: () => countries.first,
    // );
    //
    // selectedLanguage = languages.firstWhere(
    //   (language) => language.id == languageIdFromCash,
    //   orElse: () => languages.first,
    // );
    //
    // selectedGender = genders.firstWhere(
    //   (gender) => gender.id == genderIdFromCash,
    //   orElse: () => genders.first,
    // );

    var result = await CashNetwork.getCashData(key: 'user_model');
    userModel = UserModel.fromJson(jsonDecode(result));
    print("=================");
    print("Name From Profile ${userModel.name}");
    nameController = TextEditingController(text: userModel.name);
    userNameController = TextEditingController(text: userModel.name);
    emailController = TextEditingController(text: userModel.email);
    emit(SetProfileDetailsLoading());
    emit(SetProfileDetailsSuccess());

  }

  //Data User From Cache
  late TextEditingController nameController;

  late TextEditingController userNameController;

  late TextEditingController emailController;

 late UserModel userModel;

  //
  // String country = CashNetwork.getCashData(key: 'country');
  //
  // String gender = CashNetwork.getCashData(key: 'gender');
  // String countryCode = CashNetwork.getCashData(key: 'country_code');
  // String dateOfBirth = CashNetwork.getCashData(key: 'date_of_birth');
  // String languageName = CashNetwork.getCashData(key: 'language_name');
  // String languageCode = CashNetwork.getCashData(key: 'language_code');
  //
  // // String imagePicked = imageUserCache;
  //
  // XFile? selectedImagePath;
  // List<Country> countries = [];
  // List<Language> languages = [];
  // List<Gender> genders = [];
  //
  // Country? selectedCountry;
  // Language? selectedLanguage;
  // Gender? selectedGender;
  // //Var for Select
  // String? selectGenderId = genderId;
  // String? selectLanguageId = languageId;
  // String? selectCountryId = countryId;
  // DateTime? selectedDate;
  // void pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     selectedImagePath = pickedFile;
  //     emit(ProfileImageUpdated(pickedFile: pickedFile));
  //   } else {
  //     emit(ProfileImageUpdated(pickedFile: XFile('')));
  //   }
  // }

  // Future<void> pickDate(BuildContext context) async {
  //   DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime.now(),
  //   );
  //
  //   if (pickedDate != null) {
  //     selectedDate = pickedDate;
  //     dateOfBirth = "${pickedDate.toLocal()}".split(' ')[0];
  //     CashNetwork.insertToCash(key: 'date_of_birth', value: dateOfBirth);
  //     emit(ProfileUpdated());
  //   }
  // }
  //
  // void showImageDialog(BuildContext context, ImageProvider imageProvider) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       backgroundColor: Colors.transparent,
  //       child: Stack(
  //         alignment: Alignment.center,
  //         children: [
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(20),
  //             child: PhotoView(
  //               enableRotation: true,
  //               imageProvider: imageProvider,
  //               backgroundDecoration: const BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 color: Colors.transparent,
  //               ),
  //               minScale: PhotoViewComputedScale.contained,
  //               maxScale: PhotoViewComputedScale.covered * 2.0,
  //               heroAttributes:
  //                   const PhotoViewHeroAttributes(tag: "profile_image"),
  //             ),
  //           ),
  //           Positioned(
  //             top: 10,
  //             right: 10,
  //             child: Container(
  //               decoration: const BoxDecoration(
  //                 color: Colors.white,
  //                 shape: BoxShape.circle,
  //               ),
  //               child: IconButton(
  //                 tooltip: S.of(context).close,
  //                 icon: const Icon(Icons.close, color: AppColors.primaryColor),
  //                 onPressed: () => Navigator.of(context).pop(),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

//Update Profile Info
  Future<void> setProfileDetailsFun({
    required BuildContext context,
    required String userName,
    required String name,
    required String email,

  }) async {
    if (!await checkInternet()) {
      internetDialog(context: context, mediaQuery: MediaQuery.of(context).size);
      return;
    }
    emit(SetProfileDetailsLoading());

    try {
      String? token = CashNetwork.getCashData(key: 'token');
      print('The token is => $token');

      final Map<String, dynamic> data = {
        'username': userName,
        'name': name,
        'email': email,

      };

      // if (image != null) {
      //   data['image'] = await MultipartFile.fromFile(image.path);
      //

      final response = await dio().put(
        'user/${userModel.id}',
        data: jsonEncode(data),
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('--------Set profile Details response ${response.statusCode}');
      print('Response data: ${response.data}');
      if (response.statusCode == 200) {
        print('Profile updated successfully.');
        print('===================================================');
        print(response.data);
        print('=====================================================');
        CashNetwork.deleteCashItem(key: 'user_model');
        print('=====================================================');
        final jsonData = response.data['data'];

        /////////////////////////////////////

        await CashNetwork.insertToCash(
            key: 'user_model', value: jsonEncode(jsonData));
        var result = await CashNetwork.getCashData(key: 'user_model');
        userModel = UserModel.fromJson(jsonDecode(result));

        nameController.text = userModel.name;
        userNameController.text = userModel.name;
        emailController.text = userModel.email;

        emit(SetProfileDetailsSuccess());
      } else if (response.statusCode == 401) {
        emit(SetProfileDetailsExpiredToken());
      } else {
        print('Failed to update profile. Status code: ${response.statusCode}');
        emit(
            SetProfileDetailsFailure(errorMessage: 'Failed to update profile'));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print(e.response!.statusCode ?? 'No response status code');
        Navigator.pop(context);
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          await checkInternet()
              ? emit(SetProfileDetailsServerError())
              : emit(SetProfileDetailsNoInternet());
          print('Connection Error.');
          return;
        }
        errorHandler(e: e, context: context);
        print('==================dio exception ======================');
        print('Status Code: ${e.response!.statusCode}');
        print('Response Data: ${e.response!.data}');
        emit(SetProfileDetailsFailure(errorMessage: e.toString()));
      } else {
        print(
            '==================DioException without response ======================');
        emit(SetProfileDetailsFailure(
            errorMessage: 'DioException without response'));
      }
    } catch (e) {
      print(
          '=============================catch exception ===============================');
      print(e);
      emit(SetProfileDetailsFailure(errorMessage: e.toString()));
    }
  }

//   // Fetch Country Function
//   Future<void> fetchCountry(BuildContext context) async {
//     emit(FetchCountryLoading());
//     try {
//       String? token = CashNetwork.getCashData(key: 'token');
//       final response = await dio().get(
//         'countries/get-all',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         final data = response.data['countries']['data'];
//         countries = List<Country>.from(
//             data.map((item) => Country(item['id'].toString(), item['name'])));
//         emit(FetchCountrySuccess());
//       } else {
//         emit(FetchCountryFailure(errorMessage: response.data));
//       }
//     } catch (e) {
//       emit(FetchCountryFailure(errorMessage: e.toString()));
//     }
//   }
//
//   //Update Country Value Function on Screen and Cash
//   void updateCity(String cityId, String cityName) {
//     CashNetwork.deleteCashItem(key: 'country_id');
//     CashNetwork.insertToCash(key: 'country_id', value: cityId);
//     CashNetwork.deleteCashItem(key: 'country');
//     CashNetwork.insertToCash(key: 'country', value: country);
//     countryId = cityId;
//     country = cityName;
//     selectedCountry = countries.firstWhere((country) => country.id == cityId);
//     selectCountryId = cityId;
//     emit(ProfileUpdated());
//   }
//
// // Fetch Language Function
//   Future<void> fetchLanguageFunction(BuildContext context) async {
//     emit(FetchCountryLoading());
//     try {
//       String? token = CashNetwork.getCashData(key: 'token');
//       final response = await dio().get(
//         'languages/get-all',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//       if (response.statusCode == 200) {
//         final data = response.data['languages']['data'];
//         languages = List<Language>.from(
//             data.map((item) => Language(item['id'].toString(), item['name'])));
//         emit(FetchCountrySuccess());
//       } else {
//         emit(FetchCountryFailure(errorMessage: response.data));
//       }
//     } catch (e) {
//       emit(FetchCountryFailure(errorMessage: e.toString()));
//     }
//   }
//
//   //Update Language Value Function on Screen and Cash
//   void updateLanguage(String languageId, String languageName) {
//     CashNetwork.deleteCashItem(key: 'language_id');
//     CashNetwork.insertToCash(key: 'language_id', value: languageId);
//     CashNetwork.deleteCashItem(key: 'language_name');
//     CashNetwork.insertToCash(key: 'language_name', value: languageName);
//     languageId = languageId;
//     languageName = languageId;
//     selectedLanguage =
//         languages.firstWhere((language) => language.id == languageId);
//     selectLanguageId = languageId;
//     emit(ProfileUpdated());
//   }
//
// // Fetch Gender Function
//   Future<void> fetchGenderFunction(BuildContext context) async {
//     emit(FetchCountryLoading());
//     try {
//       String? token = CashNetwork.getCashData(key: 'token');
//       final response = await dio().get(
//         'genders/get-all',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         final data = response.data['genders']['data'];
//         genders = List<Gender>.from(
//             data.map((item) => Gender(item['id'].toString(), item['type'])));
//         emit(FetchCountrySuccess());
//       } else {
//         print(response.data);
//         emit(FetchCountryFailure(errorMessage: response.data));
//       }
//     } catch (e) {
//       print(e);
//       emit(FetchCountryFailure(errorMessage: e.toString()));
//     }
//   }
//
//   //Update Language Value Function on Screen and Cash
//   void updateGender(String genderId, String genderType) {
//     CashNetwork.deleteCashItem(key: 'gender_id');
//     CashNetwork.insertToCash(key: 'gender_id', value: genderId);
//     CashNetwork.deleteCashItem(key: 'gender');
//     CashNetwork.insertToCash(key: 'gender', value: genderType);
//
//     genderId = genderId;
//     gender = genderType;
//     selectedGender = genders.firstWhere((gender) => gender.id == genderId);
//     selectGenderId = genderId;
//     emit(ProfileUpdated());
//   }

// void updateBirthDate(DateTime? pickedDate) {
//   dateOfBirth = pickedDate;
//   CashNetwork.insertToCash(
//       key: 'date_of_birth', value: pickedDate.toString());
//   emit(ProfileUpdated());
// }
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
