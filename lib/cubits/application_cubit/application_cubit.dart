import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:html' as html; // For web-specific operations
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // For fetching file content
import 'package:file_picker/file_picker.dart'; // For file save path on mobile/desktop
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // For default paths on mobile/desktop

import 'package:dio/dio.dart' as Dio;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:files_manager/core/server/file_server.dart';
import 'package:files_manager/models/folder_model.dart';
import 'package:files_manager/models/file_model.dart';
import 'package:files_manager/models/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:files_manager/core/functions/apis_error_handler.dart';
import 'package:files_manager/core/server/dio_settings.dart';
import 'package:files_manager/core/shared/connect.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/interfaces/applications_abstract.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  ApplicationCubit() : super(ApplicationInitial());
  final int pageSize = 10;
  final List<int> folderHistory = [];
  final List<String> folderNames = [];
  Map<int, int> folderFileCount = {};

  PagingController<int, Application> pagingController =
      PagingController(firstPageKey: 1);
  final List<Application> newBoardsApp = [];

  Future<void> initState({
    required BuildContext context,
    required int groupId,
  }) async {
    newBoardsApp.clear();
    getAllFilesBoard(context: context, groupId: groupId);
    // pagingController.addPageRequestListener(
    //   (pageKey) async {
    //     getApplicationsInBoards(context: context, uuid: uuid, pageKey: pageKey);
    //   },
    // );
    emit(ApplicationInitial());
  }

  Future<void> refresh() async {
    emit(ApplicationInitial());
  }

  Future<void> refreshData() async {
    newBoardsApp.clear();
    pagingController.itemList!.clear();
    pagingController.refresh();
  }

  // Future<void> getApplicationsInBoards({
  //   required BuildContext context,
  //   required String uuid,
  //   required int pageKey,
  // }) async {
  //   try {
  //     emit(GetAllApplicationsInBoardLoading());
  //     if (pageKey == 1) {
  //       newBoardsApp.clear();
  //     }
  //     String? token = CashNetwork.getCashData(key: 'token');
  //     print('The page we will get is => $pageKey');
  //     final response = await dio().get(
  //       'board-applications/get-applications-in-board/$uuid',
  //       queryParameters: {'page': pageKey},
  //       options: Dio.Options(
  //         headers: {'Authorization': 'Bearer $token'},
  //       ),
  //     );
  //     print('The status code is => ${response.statusCode}');
  //     print(response.data);
  //     if (response.statusCode == 200) {
  //       final List jsonData =
  //           await response.data['board_applications']['data'] as List;
  //
  //       for (var i = 0; i < jsonData.length; i++) {
  //         if (jsonData[i]['application']['id'] == 1) {
  //           FileModel todoModel = FileModel.fromJson(jsonData[i]);
  //           newBoardsApp.add(todoModel);
  //         } else if (jsonData[i]['application']['id'] == 2) {
  //           FolderModel chatModel = FolderModel.fromJson(jsonData[i]);
  //           newBoardsApp.add(chatModel);
  //         }
  //       }
  //
  //       print('we will emit success');
  //       emit(GetAllApplicationsInBoardSuccess(
  //           newBoardsApp: newBoardsApp,
  //           isReachMax:
  //               response.data['board_applications']['links']['next'] == null));
  //     }
  //     if (response.statusCode == 204) {
  //       emit(GetAllApplicationsInBoardSuccess(
  //           newBoardsApp: const [], isReachMax: false));
  //     }
  //   } on DioException catch (e) {
  //     if (e.type == DioExceptionType.connectionTimeout ||
  //         e.type == DioExceptionType.receiveTimeout ||
  //         e.type == DioExceptionType.connectionError) {
  //       await checkInternet()
  //           ? emit(GetAllApplicationsInBoardServerError())
  //           : emit(GetAllApplicationsInBoardNoInternet());
  //       print('Connection Error.');
  //       return;
  //     }
  //     errorHandlerWithoutInternet(e: e, context: context);
  //     if (e.response!.statusCode == 401) {
  //       emit(GetAllApplicationsInBoardExpiredToken());
  //       return;
  //     }
  //     print('The response is => ${e.response!.data}');
  //     print('The failed status code is ${e.response!.statusCode}');
  //     emit(GetAllApplicationsInBoardFailure(
  //         errorMessage: e.response!.data['message']));
  //   } catch (e) {
  //     print('================ catch exception =================');
  //     print(e);
  //     emit(GetAllApplicationsInBoardFailure(errorMessage: 'Catch exception'));
  //     print(e);
  //   }
  // }
  void navigateBack({required BuildContext context, required int groupId}) {
    if (folderHistory.isNotEmpty) {
      final previousFolderId = folderHistory.removeLast();
      folderNames.removeLast();
      if (folderHistory.isNotEmpty) {
        getAllFilesFolder(
            context: context, groupId: groupId, folderId: folderHistory.last);
      } else {
        getAllFilesBoard(context: context, groupId: groupId);
      }
    } else {
      getAllFilesBoard(context: context, groupId: groupId);
    }
  }

  Future<void> deleteApplicationFunction({
    required BuildContext context,
    required int fileId,
    required int groupId,
  }) async {
    emit(BoardDeleteApplicationLoading());
    try {
      String? token = CashNetwork.getCashData(key: 'token');
      print("=========================Delete file=======================");
      final response = await dio().delete(
        'groups/$groupId/files/$fileId/remove',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print(
            "=========================Delete file 200=======================");
        print(response.data);
        print("===========message ====================");
        print(response.data['message']);
        emit(BoardDeleteApplicationSuccess());
      }
    } on DioException catch (e) {
      errorHandler(e: e, context: context);

      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response?.data['message']));
    } catch (e) {
      emit(GetAllApplicationsInBoardFailure(errorMessage: e.toString()));
    }
  }

  //
  // void downloadFile(String fileUrl, {String? customFileName}) {
  //   final anchor = html.AnchorElement(href: fileUrl)
  //     ..download = customFileName ??
  //         fileUrl.split('/').last // Use custom filename if provided
  //     ..target = '_self'; // Ensure it triggers download in the same window
  //   anchor.click();
  //   anchor.remove(); // Clean up after download
  // }

  Future<String> getFilePath(String filename) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    return join(appDocPath, filename);
  }

  Future<void> saveFileLocally(String filename, List<int> bytes) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, filename);
    File file = File(path);
    await file.writeAsBytes(bytes);
    print("File saved at $path");
  }

  Future<void> attemptSaveFile(String filename, List<int> bytes) async {
    bool hasPermission = await checkAndRequestStoragePermission();
    if (hasPermission) {
      try {
        await saveFileLocally(filename, bytes);
        print("File download and save completed.");
      } catch (e) {
        print("An error occurred while saving the file: $e");
      }
    } else {
      print("Storage permission not granted. Cannot save the file.");
    }
  }

  Future<bool> checkAndRequestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<void> saveFile(String filename, Uint8List bytes) async {
    final xFile = XFile.fromData(
      bytes,
      name: filename,
      // mimeType: 'application/octet-stream', // Adjust MIME type as needed
    );

    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = filename;
      anchor.click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      await file.writeAsBytes(bytes);
      print('File saved at $path');
    }
  }

  Future<void> downloadFile() async {
    final url =
        'http://127.0.0.1:8000/storage/files/2hIJtYXM6a48h13EJLyv6Zm0e7bses.txt';

    // Fetch the file
    final response = await http.get(Uri.parse(url));

    print('respose $response');
    if (response.statusCode == 200) {
      // Create a blob from the response data
      final blob = html.Blob([Uint8List.fromList(response.bodyBytes)]);

      // Create an anchor element and simulate a click to trigger the download
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'downloaded_file.txt';

      // Trigger the download
      anchor.click();

      // Revoke the URL object after download
      html.Url.revokeObjectUrl(url);
    } else {
      print('Failed to download file: ${response.statusCode}');
    }
  }

  Future<void> getFileApplicationFunction({
    required BuildContext context,
    required String filePath,
    required String fileName,
  }) async {
    // emit(BoardCheckApplicationLoading());
    try {
      String? token = CashNetwork.getCashData(key: 'token');
      print("=========================Get file=======================");
      print("===========File Path==============");
      print(filePath);

      print("===========Downlaod File ==============");
      // await downloadFile();
      if (filePath != null) {

        var client = dio();
        client.options.baseUrl = FileUrl.fileUrl+filePath;
        final response = await client.get(
          '',

        );

        if (response.statusCode == 200) {

          final bytes = response.data is String
              ? utf8.encode(response.data) // Convert String to List<int>
              : response.data;

          // Encode as base64
          final content = base64Encode(bytes);

          // Create a download link and trigger a download
          final anchor = html.AnchorElement(
            href: 'data:application/octet-stream;base64,$content',
          )
            ..target = 'blank'
            ..download = fileName; // File name for the download
          anchor.click();
          print('File downloaded successfully as $fileName');


        }

        // String content = await rootBundle.loadString('assets/texts/abood.txt');
        // ByteData byteData = await rootBundle.load('assets/texts/abood.txt');
        // Uint8List fileBytes = byteData.buffer.asUint8List();
        // await FileSaver.instance.saveFile(name: 'test', bytes: fileBytes, ext: 'txt');
        // // Convert the file content to bytes (you can also directly pass bytes if you have them)
        // Uint8List fileBytes = Uint8List.fromList(fileContent.codeUnits);
        // // Pick a location to save the file using FilePicker
        // String? outputFile = await FilePicker.platform.saveFile(
        //   dialogTitle: 'Please select an output file:',
        //   fileName: 'output-file.pdf',
        // );

        // final response = await http.get(Uri.parse(FileUrl.fileUrl+filePath));
        // var client = dio();
        // client.options.baseUrl = FileUrl.fileUrl+filePath;
        // client.options.responseType = ResponseType.bytes;
        // print(client.options.baseUrl);
        // final response = await client.get('');
        // // final bytes = response.data as Uint8List;
        // print("resposne $response");
        //
        // if (response.statusCode == 200) {
        //
        //   print('File downloaded successfully: ${response}');
        // } else {
        //   print('Failed with status code: ${response.statusCode}');
        // }
        // if (response.statusCode != 200) {
        //   // throw Exception('Failed to download file: ${response.statusCode}');
        //   emit(GetAllApplicationsInBoardFailure(
        //       errorMessage: response.toString()));
        // }


        //
        // // Step 2: Save the file
        // if (kIsWeb) {
        //   // Web: Trigger a download
        //   final blob = html.Blob([[]]);
        //   final downloadUrl = html.Url.createObjectUrlFromBlob(blob);
        //   final anchor = html.AnchorElement(href: downloadUrl)
        //     ..target = 'blank'
        //     ..download = fileName;
        //   anchor.click();
        //   html.Url.revokeObjectUrl(downloadUrl);
        // } else {
        //   // Mobile/Desktop: Let the user choose a save path
        //   final result = await FilePicker.platform.saveFile(
        //     dialogTitle: 'Save File As',
        //     fileName: fileName,
        //   );
        //
        //   if (result != null) {
        //     // Save the file at the chosen path
        //     final file = File(result);
        //     await file.writeAsBytes([]);
        //     print('File saved at: $result');
        //   } else {
        //     print('File save operation canceled.');
        //   }
        // }
        // emit(BoardCheckApplicationSuccess());
      }
    } on DioException catch (e) {
      print(e);

      errorHandler(e: e, context: context);
      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response?.data['message']));
    } catch (e) {
      print(e);

      emit(GetAllApplicationsInBoardFailure(errorMessage: e.toString()));
    }
  }


  Future<void> checkApplicationFunction({
    required BuildContext context,
    required int fileId,
    required int groupId,
    required int index,


  }) async {
    emit(BoardCheckApplicationLoading());
    try {
      String? token = CashNetwork.getCashData(key: 'token');
      print("=========================Check file=======================");
      final response = await dio().post(
        'files/$fileId/check-in',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print("=========================Check file 200=======================");
        print(response.data);
        newBoardsApp.clear();
        if(folderHistory.isEmpty){
          await  getAllFilesBoard(context: context, groupId: groupId);

        }else{
          await getAllFilesFolder(context: context, groupId: groupId, folderId: folderHistory.last);
        }
       // await initState(context:context,groupId: groupId);
      emit(BoardCheckApplicationSuccess());
       //  await showApplicationFunction(context: context,index: index,fileId: fileId,group_id: groupId);
      }else{
        emit(GetAllApplicationsInBoardFailure(
            errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      // errorHandler(e: e, context: context);

      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response?.data['message']));
    } catch (e) {
      emit(GetAllApplicationsInBoardFailure(errorMessage: e.toString()));
    }
  }

  Future<void> showApplicationFunction({
    required BuildContext context,
    required int fileId,
    required int group_id,
    required int index,

  }) async {
    // emit(BoardCheckApplicationLoading());
    try {
      String? token = CashNetwork.getCashData(key: 'token');
      print("=========================Show file=======================");
      final response = await dio().get(
        'files/show/$fileId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print("=========================Show file 200=======================");
        FileApiModel fileApiModel = FileApiModel.fromJson(response.data);
        // print(response);
        print(fileApiModel.activeCheckin!.checkedInAt);
        // newBoardsApp[index] = FileModel.fromFileApi(fileApiModel, group_id);
        // emit(BoardCheckApplicationSuccess(file: newBoardsApp[index]));

        // emit(BoardCheckApplicationSuccess());
      }else{
        emit(GetAllApplicationsInBoardFailure(
            errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      errorHandler(e: e, context: context);

      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response?.data['message']));
    } catch (e) {
      emit(GetAllApplicationsInBoardFailure(errorMessage: e.toString()));
    }
  }

  Future<void> checkMultiApplicationFunction({
    required BuildContext context,
    required Set<String> filesId,
    required int groupId,
  }) async {
    emit(BoardMultiCheckApplicationLoading());
    try {
      String? token = CashNetwork.getCashData(key: 'token');
      print("=========================Check Multi=======================");
      String result = 'files/${filesId.join(',')}/bulk-check-in';
      print(result);
      final response = await dio().post(
        '$result',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print(
            "=========================Check Multi 200=======================");
        print(response.data);
        newBoardsApp.clear();
        if(folderHistory.isEmpty){
          await  getAllFilesBoard(context: context, groupId: groupId);

        }else{
          await getAllFilesFolder(context: context, groupId: groupId, folderId: folderHistory.last);
        }
        emit(BoardMultiCheckApplicationSuccess());
      }else{
        emit(GetAllApplicationsInBoardFailure(
            errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      // errorHandler(e: e, context: context);

      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response?.data['message']));
    } catch (e) {
      emit(GetAllApplicationsInBoardFailure(errorMessage: e.toString()));
    }
  }

  Future<void> checkOutApplicationFunction({
    required BuildContext context,
    required int fileId,
    required int groupId,
    required PlatformFile? file,
  }) async {
    emit(BoardCheckOutApplicationLoading());

    try {
      String? token = CashNetwork.getCashData(key: 'token');
      Map<String, dynamic> data = {};

      if (file != null) {
        String content = await file.xFile.readAsString();
        print("==========================content=======================");
        print(content);

        if (file.bytes != null) {

          data['file'] = MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          );
        } else if (file.path != null) {
          // Use the path for other platforms
          data['file'] = await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          );
        } else {
          throw Exception('File is invalid. Both path and bytes are null.');
        }
      }

      final formData = FormData.fromMap(data);

      final response = await dio().post(
        '/files/$fileId/check-out',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print("==========Check OUT 200====================");
        print(response.data);
        newBoardsApp.clear();
        if(folderHistory.isEmpty){
          await  getAllFilesBoard(context: context, groupId: groupId);

        }else{
          await getAllFilesFolder(context: context, groupId: groupId, folderId: folderHistory.last);
        }
        emit(BoardCheckOutApplicationSuccess());
      } else {
        emit(GetAllApplicationsInBoardFailure(
            errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      errorHandler(e: e, context: context);
      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response?.data['message']));
    } catch (e) {
      emit(GetAllApplicationsInBoardFailure(errorMessage: e.toString()));
    }
  }

  Future<void> getAllFilesFolder(
      {required BuildContext context,
      required int groupId,
      required int folderId}) async {
    try {
      print("===============Folder FILES====================");
      print("===============Folder $folderId====================");
      emit(GetAllApplicationsInFolderLoading());
      String? token = CashNetwork.getCashData(key: 'token');

      print("token get boards: $token");
      final response = await dio().get(
        'files/$folderId/children',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('The status code is => ${response.statusCode}');
      print(response.data);

      if (response.statusCode == 200) {
        final FilesList = response.data['data'] as List;
        newBoardsApp.clear();

        for (int i = 0; i < FilesList.length; i++) {
          FileApiModel file = FileApiModel.fromJson(FilesList[i]);

          if (file.extension == null) {
            FolderModel folderModel = FolderModel.fromFileApi(file, groupId);

            if (folderFileCount.containsKey(file.id)) {
              folderModel.filesCount = folderFileCount[file.id].toString();
            }
            newBoardsApp.add(folderModel);
          } else {
            FileModel fileModel = FileModel.fromFileApi(file, groupId);
            newBoardsApp.add(fileModel);
          }
        }
        print('we will emit success');

        emit(GetAllApplicationsInFolderSuccess(newBoardsApp: newBoardsApp));
      } else {
        print('Failed to fetch boards: ${response.statusCode}');
        emit(GetAllApplicationsInBoardFailure(
            errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        await checkInternet()
            ? emit(GetAllApplicationsInBoardServerError())
            : emit(GetAllApplicationsInBoardNoInternet());
        print('Connection Error.');
        return;
      }
      errorHandlerWithoutInternet(e: e, context: context);

      print('The response is => ${e.response!.data}');
      print('The failed status code is ${e.response!.statusCode}');
      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response!.data['message']));
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(GetAllApplicationsInBoardFailure(errorMessage: 'Catch exception'));
    }
  }

  Future<void> getAllFilesBoard(
      {required BuildContext context, required int groupId}) async {
    try {
      print("===============Boards FILES====================");
      emit(GetAllApplicationsInBoardLoading());
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
        newBoardsApp.clear();
        for (int i = 0; i < groupModel.files.length; i++) {
          FileApiModel file = groupModel.files[i];
          int targetParentId = file.id;

          List<FileApiModel> filesInFolder = groupModel.files
              .where((file) => file.parentId == targetParentId)
              .toList();
          int numberOfFilesInFolder = filesInFolder.length;
          folderFileCount[targetParentId] = numberOfFilesInFolder;
          if (file.parentId == 0 || file.parentId == null) {
            if (file.extension == null) {
              FolderModel folderModel = FolderModel.fromFileApi(
                file,
                groupId,
              );
              folderModel.filesCount = numberOfFilesInFolder.toString();
              newBoardsApp.add(folderModel);
            } else {
              FileModel fileModel = FileModel.fromFileApi(file, groupId);
              newBoardsApp.add(fileModel);
            }
          }
        }
        print('we will emit success');

        emit(GetAllApplicationsInBoardSuccess(
            newBoardsApp: newBoardsApp, isReachMax: true));
      } else {
        print('Failed to fetch boards: ${response.statusCode}');
        emit(GetAllApplicationsInBoardFailure(
            errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        await checkInternet()
            ? emit(GetAllApplicationsInBoardServerError())
            : emit(GetAllApplicationsInBoardNoInternet());
        print('Connection Error.');
        return;
      }
      errorHandlerWithoutInternet(e: e, context: context);

      print('The response is => ${e.response!.data}');
      print('The failed status code is ${e.response!.statusCode}');
      emit(GetAllApplicationsInBoardFailure(
          errorMessage: e.response!.data['message']));
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(GetAllApplicationsInBoardFailure(errorMessage: 'Catch exception'));
    }
  }

  Future<void> renameApplicationName({
    required bool isFolder,
    required String appName,
    required Application app,
    required BuildContext context,
  }) async {
    try {
      print("=============Rename Folder====================");
      emit(RenameAppLoading());
      String? token = CashNetwork.getCashData(key: 'token');

      print("token get boards: $token");
      final response = await dio().post(
        'files/${app.getApplicationId()}/rename',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('The status code is => ${response.statusCode}');
      print(response.data);

      if (response.statusCode == 200) {
        if(isFolder){
          var a = app as FolderModel;
          a.title = appName;

        }else{
          var a = app as FileModel;
          a.title = appName;
        }

        emit(RenameAppSuccess());
      } else {
        print('Failed to fetch boards: ${response.statusCode}');
        emit(GetAllApplicationsInBoardFailure(errorMessage: response.data['message']));
      }
    } on DioException catch (e) {
      Navigator.pop(context);
      errorHandler(e: e, context: context);

      print('The response is => ${e.response!.data}');
      print('The failed status code is ${e.response!.statusCode}');
      emit(
          GetAllApplicationsInBoardFailure(errorMessage: e.response!.data['message']));
    } catch (e) {
      print('================ catch exception =================');
      print(e);
      emit(GetAllApplicationsInBoardFailure(errorMessage: 'Catch exception'));
    }
  }
}
