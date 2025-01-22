import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:files_manager/core/functions/snackbar_function.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/interfaces/applications_abstract.dart';
import 'package:files_manager/models/Api_user.dart';
import 'package:files_manager/models/file_model.dart';
import 'package:files_manager/models/folder_model.dart';
import 'package:files_manager/screens/all_applications_screen/all_applications_screen.dart';
import 'package:files_manager/screens/report_screen/file_report_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/core/animation/dialogs/expired_dialog.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/cubits/all_boards_cubit/all_boards_cubit.dart';
import 'package:files_manager/cubits/application_cubit/application_cubit.dart';
import 'package:files_manager/cubits/board_cubit/board_cubit.dart';
import 'package:intl/intl.dart';

import 'package:shimmer/shimmer.dart';

import '../../core/functions/statics.dart';
import '../../models/member_model.dart';
import '../../theme/color.dart';

class ShowApplicationsData extends StatefulWidget {
  const ShowApplicationsData({super.key, required this.allBoardsCubit});

  final AllBoardsCubit allBoardsCubit;

  @override
  State<ShowApplicationsData> createState() => _ShowApplicationsDataState();
}

class _ShowApplicationsDataState extends State<ShowApplicationsData> {
  final Set<String> selectedFiles = {};
  final Set<int> selectedIndexes = {};
  int currentIndex = -1;

  void toggleSelection(String fileId) {
    setState(() {
      if (selectedFiles.contains(fileId)) {
        selectedFiles.remove(fileId);
      } else {
        selectedFiles.add(fileId);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedFiles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final applicationCubit = context.read<ApplicationCubit>();
    final boardCubit = context.read<BoardCubit>();
    var user_model = CashNetwork.getCashData(key: 'user_model');
    var user = UserModel.fromJson(jsonDecode(user_model));
    return Localizations.override(
      context: context,
      child: BlocConsumer<ApplicationCubit, ApplicationState>(
        listener: (context, state) async {
          if (state is GetAllApplicationsInBoardLoading ||
              state is GetAllApplicationsInFolderLoading) {
            // loadingDialog(context: context, mediaQuery: mediaQuery);
          }

          if (state is GetAllApplicationsInBoardFailure) {
            Navigator.pop(context);

            errorDialog(context: context, text: state.errorMessage);
          } else if (state is AllBoardsExpiredState) {
            showExpiredDialog(
              context: context,
              onConfirmBtnTap: () async {
                await CashNetwork.clearCash();
                await Hive.box('main').clear();
                Phoenix.rebirth(context);
              },
            );
          } else if (state is AllBoardsNoInternetState) {
            internetDialog(context: context, mediaQuery: mediaQuery);
          } else if (state is GetAllApplicationsInBoardSuccess) {
            final isLastPage = state.isReachMax;
            print('Is the last page => $isLastPage');
            boardCubit.currentBoard.allFiles.clear();

            for (Application a in state.newBoardsApp) {
              boardCubit.currentBoard.allFiles.add(a);
            }
            // if(state is GetAllApplicationsInFolderLoading||state is GetAllApplicationsInBoardLoading){
            //   Navigator.pop(context);
            // }

            // // Use set to avoid duplicating items.
            // final existingItems =
            //     applicationCubit.pagingController.itemList ?? [];
            // // Check for new items and ignore duplicates
            // final newItems = state.newBoardsApp
            //     .where((app) => !existingItems.any((existingApp) =>
            //         existingApp.getApplicationId() == app.getApplicationId()))
            //     .toList();
            // if (isLastPage) {
            //   applicationCubit.pagingController.appendLastPage(newItems);
            // } else {
            //   if (applicationCubit.pagingController.itemList == null) {
            //     applicationCubit.pagingController.appendPage(newItems, 2);
            //     return;
            //   }
            //   final nextPageKey =
            //       (applicationCubit.pagingController.itemList!.length ~/
            //               applicationCubit.pageSize) +
            //           1;
            //   print('The next page is =>$nextPageKey');
            //   applicationCubit.pagingController
            //       .appendPage(newItems, nextPageKey);
            // }
          } else if (state is GetAllApplicationsInFolderSuccess) {
            boardCubit.currentBoard.allFiles.clear();

            boardCubit.currentBoard.allFiles.addAll(state.newBoardsApp);

            // Navigator.pop(context);
          } else if (state is BoardDeleteApplicationSuccess) {
            showLightSnackBar(context, S.of(context).delete);
            Navigator.of(context).pop();
          }
          if (state is BoardDeleteApplicationLoading ||
              state is BoardCheckApplicationLoading ||
              state is BoardMultiCheckApplicationLoading ||
              state is BoardCheckOutApplicationLoading) {
            loadingDialog(context: context, mediaQuery: mediaQuery);
          } else if (state is BoardCheckApplicationSuccess) {
            showLightSnackBar(context, S.of(context).checked);
            Navigator.of(context).pop();
          } else if (state is BoardMultiCheckApplicationSuccess) {
            showLightSnackBar(context, S.of(context).checked);
            Navigator.of(context).pop();

            setState(() {
              selectedFiles.clear();
            });
          } else if (state is BoardCheckOutApplicationSuccess) {
            showLightSnackBar(context, S.of(context).checkout);
            Navigator.of(context).pop();
          } else if (state is RenameAppSuccess) {
            showLightSnackBar(context, S.of(context).renamed);
            Navigator.of(context).pop();
          } else if (state is RenameAppLoading) {
            loadingDialog(context: context, mediaQuery: mediaQuery);
          }
          if (state is BoardCheckApplicationSuccess && currentIndex != -1) {
            await boardCubit.checkIn(
                m: Member.fromUserModel(user),
                file: boardCubit.currentBoard.allFiles[currentIndex]
                    as FileModel);
            await applicationCubit.getFileApplicationFunction(
                context: context,
                fileName: boardCubit.currentBoard.allFiles[currentIndex]
                    .getApplicationName(),
                filePath:
                    boardCubit.currentBoard.allFiles[currentIndex].getPath());
          } else if (state is BoardCheckOutApplicationSuccess &&
              currentIndex != -1) {
            await boardCubit.checkOut(
                file: boardCubit.currentBoard.allFiles[currentIndex]
                    as FileModel);

            boardCubit.currentBoard.allFiles[currentIndex]
                .setApplicationOwner(null);

            print(
                "Check out ${boardCubit.currentBoard.allFiles[currentIndex].getApplicationOwner()?.email ?? 'No Owner'}");
          } else if (state is BoardMultiCheckApplicationSuccess &&
              selectedIndexes.isNotEmpty) {
            for (int indexx in selectedIndexes) {
              await boardCubit.checkIn(
                  m: Member.fromUserModel(user),
                  file: boardCubit.currentBoard.allFiles[indexx] as FileModel);

              await applicationCubit.getFileApplicationFunction(
                  context: context,
                  fileName: boardCubit.currentBoard.allFiles[indexx]
                      .getApplicationName(),
                  filePath: boardCubit.currentBoard.allFiles[indexx].getPath());
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (applicationCubit.folderHistory.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          applicationCubit.navigateBack(
                              context: context,
                              groupId: boardCubit.currentBoard.id);
                        },
                      ),
                    Expanded(
                      child: Text(
                        applicationCubit.folderHistory.isNotEmpty
                            ? applicationCubit.folderNames.join(' / ')
                            : 'Root',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selectedFiles.isNotEmpty)
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: clearSelection,
                            child: Text(
                              "Unselect",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await applicationCubit
                                  .checkMultiApplicationFunction(
                                      context: context,
                                      filesId: selectedFiles,
                                      groupId: boardCubit.currentBoard.id);

                              print("Check In: $selectedFiles");
                            },
                            child: Text(
                              "Check In",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                    onRefresh: () async {
                      applicationCubit.refreshData();
                    },
                    child: ListView(
                      children: List.generate(
                        boardCubit.currentBoard.allFiles.length,
                        (index) {
                          print(
                              'File ID: ${boardCubit.currentBoard.allFiles[index].getApplicationId()}, '
                              'Owner: ${boardCubit.currentBoard.allFiles[index].getApplicationOwner()}, '
                              'CheckinInfo: ${boardCubit.currentBoard.allFiles[index].getCheckinInfo()}');

                          return boardCubit.currentBoard.allFiles[index]
                                  .isFolder()
                              ? Card(
                                  color: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .color,
                                  child: ListTile(
                                    onTap: () async {
                                      applicationCubit.folderHistory.add(
                                          boardCubit
                                              .currentBoard.allFiles[index]
                                              .getApplicationId());
                                      applicationCubit.folderNames.add(
                                          boardCubit
                                              .currentBoard.allFiles[index]
                                              .getApplicationName());
                                      await applicationCubit.getAllFilesFolder(
                                          context: context,
                                          groupId: boardCubit.currentBoard.id,
                                          folderId: boardCubit
                                              .currentBoard.allFiles[index]
                                              .getApplicationId());
                                    },
                                    leading: Icon(Icons.folder),
                                    trailing: PopupMenuButton(
                                      icon: const Icon(Icons.more_vert),
                                      // onSelected: (value) {
                                      //   if (value == 'settings') {
                                      //   } else if (value == 'share') {
                                      //     print('Share');
                                      //     // share();
                                      //   }
                                      // },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'Edit Name',
                                          child: ListTile(
                                            leading: const Icon(Icons.edit),
                                            title: Text('Edit'),
                                            onTap: () {
                                              showFolderNameDialog(
                                                  context: context,
                                                  isEdit: true,
                                                  onConfirm: (folderNa) async {
                                                    // boardCubit.changeFolderName(
                                                    //     folderName: folderNa,
                                                    //     folder: boardCubit
                                                    //             .currentBoard
                                                    //             .allFiles[index]
                                                    //         as FolderModel);
                                                    await applicationCubit
                                                        .renameApplicationName(
                                                            isFolder: true,
                                                            appName: folderNa,
                                                            app: boardCubit
                                                                .currentBoard
                                                                .allFiles[index],
                                                            context: context);
                                                  });
                                            },
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'Delete',
                                          child: ListTile(
                                            onTap: () async {
                                              await applicationCubit
                                                  .deleteApplicationFunction(
                                                      context: context,
                                                      fileId: boardCubit
                                                          .currentBoard
                                                          .allFiles[index]
                                                          .getApplicationId(),
                                                      groupId: boardCubit
                                                          .currentBoard.id);
                                            },
                                            leading: const Icon(Icons.delete),
                                            title: Text('Delete'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: SizedBox(
                                            width: Statics.isPlatformDesktop
                                                ? mediaQuery.width / 2.5
                                                : mediaQuery.width / 1.5,
                                            child: Text(
                                              boardCubit.currentBoard
                                                      .allFiles[index]
                                                      .getApplicationName() +
                                                  '.${boardCubit.currentBoard.allFiles[index].getApplicationExtension()}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall!
                                                    .color,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Statics.isPlatformDesktop
                                            ? Flexible(
                                                child: Text(
                                                  DateFormat(
                                                          'yyyy-MM-d HH:mm:ss')
                                                      .format(
                                                    boardCubit.currentBoard
                                                        .allFiles[index]
                                                        .getApplicationCreateDate(),
                                                  ),
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall!
                                                        .color,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    subtitle: Text(
                                      'Count of file ${boardCubit.currentBoard.allFiles[index].getApplicationFilesCount()}',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .color),
                                    ),
                                  ),
                                ).animate().fade(
                                    duration: const Duration(milliseconds: 500),
                                  )
                              : Card(
                                  color: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .color,
                                  child: ListTile(
                                    leading: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: selectedFiles.contains(
                                              boardCubit
                                                  .currentBoard.allFiles[index]
                                                  .getApplicationId()
                                                  .toString()),
                                          onChanged: (isSelected) {
                                            selectedIndexes.add(index);
                                            toggleSelection(boardCubit
                                                .currentBoard.allFiles[index]
                                                .getApplicationId()
                                                .toString());
                                          },
                                        ),
                                        Icon(boardCubit
                                            .currentBoard.allFiles[index]
                                            .getIcon()),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (boardCubit
                                                .currentBoard.allFiles[index]
                                                .getApplicationOwner() !=
                                            null)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Booked by ${boardCubit.currentBoard.allFiles[index].getCheckinInfo()?.user?.name ?? 'Unknown'}',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Statics.isPlatformDesktop
                                                  ? Text(
                                                      'Check At ${boardCubit.currentBoard.allFiles[index].getCheckinInfo()?.checkedInAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(boardCubit.currentBoard.allFiles[index].getCheckinInfo()!.checkedInAt!) : 'No Check-in Info'}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.redAccent),
                                                    )
                                                  : SizedBox(),

                                            ],
                                          )
                                        else if (boardCubit
                                                .currentBoard.allFiles[index]
                                                .getApplicationOwner() ==
                                            null)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Free for editing',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                           
                                            ],
                                          ),
                                        if (boardCubit
                                                .currentBoard.allFiles[index]
                                                .getApplicationOwner() !=
                                            null)
                                          memberWidget(
                                            member: boardCubit
                                                .currentBoard.allFiles[index]
                                                .getApplicationOwner()!,
                                            mediaQuery: mediaQuery,
                                          )
                                        else
                                          const SizedBox(),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: S.of(context).file_report,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FileReportScreen(
                                                  fileId: boardCubit.currentBoard.allFiles[index].getApplicationId(),
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.history,
                                            color: Theme.of(context).popupMenuTheme.iconColor,
                                          ),
                                        ),

                                        PopupMenuButton(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (value) async {
                                            if (value == 'checkout') {
                                              FilePickerResult? result =
                                                  await FilePicker.platform
                                                      .pickFiles();

                                              if (result != null) {
                                                final selectedFile =
                                                    result.files.first;

                                                await applicationCubit
                                                    .checkOutApplicationFunction(
                                                        groupId: boardCubit
                                                            .currentBoard.id,
                                                        context: context,
                                                        fileId: boardCubit
                                                            .currentBoard
                                                            .allFiles[index]
                                                            .getApplicationId(),
                                                        file: selectedFile);
                                                currentIndex = index;
                                              } else {
                                                await applicationCubit
                                                    .checkOutApplicationFunction(
                                                        groupId: boardCubit
                                                            .currentBoard.id,
                                                        context: context,
                                                        fileId: boardCubit
                                                            .currentBoard
                                                            .allFiles[index]
                                                            .getApplicationId(),
                                                        file: null);
                                                currentIndex = index;
                                              }
                                            } else if (value == 'checkIn') {
                                              print(
                                                  "===========File Path==============");
                                              print(boardCubit
                                                  .currentBoard.allFiles[index]
                                                  .getPath());
                                              await applicationCubit
                                                  .checkApplicationFunction(
                                                      index: index,
                                                      context: context,
                                                      fileId: boardCubit
                                                          .currentBoard
                                                          .allFiles[index]
                                                          .getApplicationId(),
                                                      groupId: boardCubit
                                                          .currentBoard.id);
                                              currentIndex = index;
                                            } else if (value == 'share') {
                                              print('Share');
                                              // share();
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: boardCubit.currentBoard
                                                          .allFiles[index]
                                                          .getApplicationOwner() !=
                                                      null
                                                  ? 'checkout'
                                                  : 'checkIn',
                                              child: ListTile(
                                                leading: Icon(boardCubit
                                                            .currentBoard
                                                            .allFiles[index]
                                                            .getApplicationOwner() !=
                                                        null
                                                    ? Icons.done_all
                                                    : Icons.check_circle_rounded),
                                                title: boardCubit.currentBoard
                                                            .allFiles[index]
                                                            .getApplicationOwner() !=
                                                        null
                                                    ? Text('Check out')
                                                    : Text('Check in'),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'Edit Name',
                                              child: ListTile(
                                                leading: const Icon(Icons.edit),
                                                title: Text('Edit'),
                                                onTap: () {
                                                  showFileNameDialog(
                                                      context: context,
                                                      isEdit: true,
                                                      onConfirm: (fileName) async {
                                                        await applicationCubit
                                                            .renameApplicationName(
                                                                isFolder: true,
                                                                appName: fileName +
                                                                    '.${boardCubit.currentBoard.allFiles[index].getApplicationExtension()}',
                                                                app: boardCubit
                                                                    .currentBoard
                                                                    .allFiles[index],
                                                                context: context);
                                                      });
                                                },
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'Download',
                                              child: ListTile(
                                                leading: const Icon(
                                                    Icons.download_rounded),
                                                title: Text('Download'),
                                                onTap: () async {
                                                  await applicationCubit
                                                      .getFileApplicationFunction(
                                                          context: context,
                                                          fileName: boardCubit
                                                              .currentBoard
                                                              .allFiles[index]
                                                              .getApplicationName(),
                                                          filePath: boardCubit
                                                              .currentBoard
                                                              .allFiles[index]
                                                              .getPath());
                                                  currentIndex = index;
                                                },
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'Delete',
                                              child: ListTile(
                                                onTap: () async {
                                                  if (boardCubit.currentBoard
                                                          .allFiles[index]
                                                          .getApplicationOwner() !=
                                                      null) {
                                                    showLightSnackBar(
                                                        context,
                                                        S
                                                            .of(context)
                                                            .error_cant_delete_file);
                                                  } else {
                                                    await applicationCubit
                                                        .deleteApplicationFunction(
                                                            context: context,
                                                            fileId: boardCubit
                                                                .currentBoard
                                                                .allFiles[index]
                                                                .getApplicationId(),
                                                            groupId: boardCubit
                                                                .currentBoard.id);
                                                  }
                                                },
                                                leading: const Icon(Icons.delete),
                                                title: Text('Delete'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    title: Row(
                                      children: [
                                        Flexible(
                                          child: SizedBox(
                                            width: Statics.isPlatformDesktop
                                                ? mediaQuery.width / 2.5
                                                : mediaQuery.width / 1.5,
                                            child: Text(
                                              boardCubit
                                                  .currentBoard.allFiles[index]
                                                  .getApplicationName()+ '.${boardCubit.currentBoard.allFiles[index].getApplicationExtension()}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall!
                                                    .color,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Statics.isPlatformDesktop
                                            ? Text(
                                                DateFormat('yyyy-MM-d HH:mm:ss')
                                                    .format(boardCubit
                                                        .currentBoard
                                                        .allFiles[index]
                                                        .getApplicationCreateDate()),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall!
                                                      .color,
                                                ),
                                              )
                                            : const SizedBox()
                                      ],
                                    ),
                                  ),
                                ).animate().fade(
                                    duration: const Duration(milliseconds: 500),
                                  );
                        },
                      ),
                    )),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget memberWidget({required Member member, required Size mediaQuery}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        (member.image.isEmpty || member.image == '')
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Statics.isPlatformDesktop
                      ? mediaQuery.width / 150
                      : mediaQuery.width / 50,
                  vertical: Statics.isPlatformDesktop
                      ? mediaQuery.width / 100
                      : mediaQuery.height / 60,
                ),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                child: Text(
                  member.firstName[0],
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Statics.isPlatformDesktop
                          ? mediaQuery.width / 90
                          : mediaQuery.width / 40),
                ),
              )
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: member.image,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: mediaQuery.width / 8, // Adjust the size as needed
                      height: mediaQuery.width / 8, // Adjust the size as needed
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: mediaQuery.width / 8,
                  // Adjust the size as needed
                  height: mediaQuery.width / 8, // Adjust the size as needed
                ),
              ),
        if (member.role == 'admin')
          Positioned(
            bottom: 10,
            right: -mediaQuery.width / 90,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: mediaQuery.width / 170,
                  vertical: mediaQuery.height / 150),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: Statics.isPlatformDesktop
                    ? mediaQuery.width / 150
                    : mediaQuery.width / 40,
              ),
            ),
          ),
      ],
    );
  }
}
