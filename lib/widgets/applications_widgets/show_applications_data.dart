import 'package:cached_network_image/cached_network_image.dart';
import 'package:files_manager/core/functions/snackbar_function.dart';
import 'package:files_manager/cubits/board_add_application_cubit/board_add_application_cubit.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/interfaces/applications_abstract.dart';
import 'package:files_manager/models/file_model.dart';

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

class ShowApplicationsData extends StatelessWidget {
  const ShowApplicationsData({super.key, required this.allBoardsCubit});

  final AllBoardsCubit allBoardsCubit;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final applicationCubit = context.read<ApplicationCubit>();
    final boardCubit = context.read<BoardCubit>();


    return Localizations.override(
      context: context,
      child: BlocConsumer<ApplicationCubit, ApplicationState>(
        listener: (context, state) {
          if (state is GetAllApplicationsInBoardLoading ||
              state is GetAllApplicationsInFolderLoading) {
            // loadingDialog(context: context, mediaQuery: mediaQuery);
          }

          if (state is GetAllApplicationsInBoardFailure) {
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
          }else if (state is BoardDeleteApplicationSuccess){
            showLightSnackBar(context, S.of(context).delete);
            Navigator.of(context).pop();

          }if (state is BoardDeleteApplicationLoading) {
            loadingDialog(context: context, mediaQuery: mediaQuery);
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
                            color: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .color,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                          return boardCubit.currentBoard.allFiles[index]
                                  .isFolder()
                              ? Card(
                                  color: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .color,
                                  child: ListTile(
                                    onTap: () {
                                      applicationCubit.folderHistory.add(
                                          boardCubit
                                              .currentBoard.allFiles[index]
                                              .getApplicationId());
                                      applicationCubit.folderNames.add(
                                          boardCubit
                                              .currentBoard.allFiles[index]
                                              .getApplicationName());
                                      applicationCubit.getAllFilesFolder(
                                          context: context,
                                          groupId: boardCubit.currentBoard.id,
                                          folderId: boardCubit
                                              .currentBoard.allFiles[index]
                                              .getApplicationId());
                                    },
                                    leading: Icon(Icons.folder),
                                    trailing: PopupMenuButton(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'settings') {
                                        } else if (value == 'share') {
                                          print('Share');
                                          // share();
                                        }
                                      },
                                      itemBuilder: (context) => [
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
                                              boardCubit
                                                  .currentBoard.allFiles[index]
                                                  .getApplicationName(),
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
                                    leading: Icon(boardCubit
                                        .currentBoard.allFiles[index]
                                        .getIcon()),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        boardCubit.currentBoard.allFiles[index]
                                                    .getApplicationOwner() !=
                                                null
                                            ? Text('Booked by',
                                                style: TextStyle(
                                                    color: Colors.red))
                                            : Text(
                                                'Free for editing',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                        boardCubit.currentBoard.allFiles[index]
                                                    .getApplicationOwner() !=
                                                null
                                            ? memberWidget(
                                                member: boardCubit.currentBoard
                                                    .allFiles[index]
                                                    .getApplicationOwner()!,
                                                mediaQuery: mediaQuery)
                                            : const SizedBox()
                                      ],
                                    ),
                                    trailing: PopupMenuButton(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) async {
                                        if (value == 'checkout') {
                                          await boardCubit.checkOut(
                                              file: boardCubit.currentBoard
                                                      .allFiles[index]
                                                  as FileModel);
                                        } else if (value == 'checkIn') {
                                          await boardCubit.checkIn(
                                              file: boardCubit.currentBoard
                                                      .allFiles[index]
                                                  as FileModel);
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
                                          value: 'Edit',
                                          child: ListTile(
                                            leading: const Icon(Icons.edit),
                                            title: Text('Edit'),
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
                                      children: [
                                        Flexible(
                                          child: SizedBox(
                                            width: Statics.isPlatformDesktop
                                                ? mediaQuery.width / 2.5
                                                : mediaQuery.width / 1.5,
                                            child: Text(
                                              boardCubit
                                                  .currentBoard.allFiles[index]
                                                  .getApplicationName(),
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
