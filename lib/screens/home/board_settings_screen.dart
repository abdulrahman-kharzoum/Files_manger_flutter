import 'dart:convert';
import 'dart:math';

import 'package:files_manager/core/functions/snackbar_function.dart';
import 'package:files_manager/core/functions/statics.dart';
import 'package:files_manager/cubits/add_board_cubit/add_board_cubit.dart';
import 'package:files_manager/models/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/core/animation/dialogs/expired_dialog.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/cubits/all_boards_cubit/all_boards_cubit.dart';
import 'package:files_manager/cubits/board_settings_cubit/board_settings_cubit.dart';
import 'package:files_manager/cubits/locale_cubit/locale_cubit.dart';
import 'package:files_manager/generated/l10n.dart';

import 'package:files_manager/theme/color.dart';
import 'package:files_manager/widgets/board_settings/board_privacy_section.dart';
import 'package:files_manager/widgets/board_settings/board_settings_section.dart';
import 'package:files_manager/widgets/board_settings/board_users_section.dart';
import 'package:files_manager/widgets/custom_text_fields/custom_text_fields.dart';

import '../../cubits/theme_cubit/app_theme_cubit.dart';


class BoardSettingsScreen extends StatefulWidget {
  const BoardSettingsScreen({super.key, required this.allBoardCubit});

  final AllBoardsCubit allBoardCubit;

  @override
  State<BoardSettingsScreen> createState() => _BoardSettingsScreenState();
}

class _BoardSettingsScreenState extends State<BoardSettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BoardSettingsCubit>().initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final boardSettingsCubit = context.read<BoardSettingsCubit>();
    final localeCubit = context.read<LocaleCubit>();

    return BlocConsumer<AddBoardCubit, AddBoardState>(
      listener: (context, addBoardState) {
        if (addBoardState is AddBoardLoadingState) {
          loadingDialog(
            context: context,
            mediaQuery: mediaQuery,
            title: S.of(context).saving,
          );
        } else if (addBoardState is AddBoardSuccessState) {
          Navigator.pop(context);
          showLightSnackBar(context, S.of(context).adding_board);
        } else if (addBoardState is AddBoardFailedState) {
          errorDialog(context: context, text: addBoardState.errorMessage);
        }
      },
      builder: (context, addBoardState) {
        return BlocConsumer<BoardSettingsCubit, BoardSettingsState>(
          listener: (context, boardState) {
            if (boardState is BoardSettingsLoadingState) {
              loadingDialog(
                context: context,
                mediaQuery: mediaQuery,
                title: S.of(context).saving,
              );
            } else if (boardState is BoardSettingsSuccessState) {
              Navigator.pop(context);
            } else if (boardState is BoardSettingsFailedState) {
              errorDialog(context: context, text: boardState.errorMessage);
            } else if (boardState is BoardSettingsExpiredState) {
              showExpiredDialog(
                context: context,
                onConfirmBtnTap: () async {
                  await CashNetwork.clearCash();
                  await Hive.box('main').clear();
                  await Phoenix.rebirth(context);
                },
              );
            }
          },
          builder: (context, boardState) {
            return Localizations.override(
              locale: boardSettingsCubit.currentBoard.language.code == 'default'
                  ? localeCubit.locale
                  : Locale(boardSettingsCubit.currentBoard.language.code),
              context: context,
              child: DefaultTabController(
                length:
                    boardSettingsCubit.currentBoard.parentId != null ? 1 : 3,
                child: BlocBuilder<AppThemeCubit, AppThemeState>(
                  builder: (context, state) {
                    final isDarkTheme = state is AppThemeDark;

                    return Scaffold(
                      appBar: AppBar(
                        backgroundColor:
                            isDarkTheme ? AppColors.darkGray : Colors.grey,
                        flexibleSpace: SizedBox(height: mediaQuery.height / 3),
                        toolbarHeight: Statics.isPlatformDesktop
                            ? mediaQuery.height / 8
                            : mediaQuery.height / 12,
                        title: CustomTextFields(
                          textAlign: TextAlign.end,
                          hintText: S.of(context).enterBoardTitle,

                          styleInput: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodySmall!.color!,
                            fontWeight: FontWeight.bold,
                            fontSize: Statics.isPlatformDesktop
                                ? mediaQuery.width / 60
                                : mediaQuery.width / 15,
                          ),
                          controller: boardSettingsCubit.boardTitleController,
                          onChanged: (p0) async {
                            await boardSettingsCubit.changeTitle();
                          },
                        ),
                        centerTitle: true,
                        leading: IconButton(
                          onPressed: () async {
                            final newBoard = boardSettingsCubit.currentBoard;

                            if (boardSettingsCubit.boardTitleController.text.isEmpty ) {

                              showLightSnackBar(context, S.of(context).enterBoardTitle);
                              return;
                            }else if(boardSettingsCubit.descriptionController.text.isEmpty){
                              showLightSnackBar(context, S.of(context).enterBoardDes);
                              return;
                            }
                            final exists = widget.allBoardCubit.allBoards
                                .any((board) => board.id == newBoard.id);

                            if (exists) {
                              final cachedData = await CashNetwork.getCashData(
                                  key: 'my_groups');
                              if (cachedData != null && cachedData is String) {
                                List<dynamic> groupJsonList =
                                    jsonDecode(cachedData);

                                List<GroupModel> allGroups = groupJsonList
                                    .map<GroupModel>(
                                        (json) => GroupModel.fromJson(json))
                                    .toList();

                                int groupIdToFind =
                                    boardSettingsCubit.currentBoard.id;
                                GroupModel specificGroup = allGroups.firstWhere(
                                  (group) => group.id == groupIdToFind,
                                  orElse: () => GroupModel(
                                    id: 0,
                                    name: '',
                                    description: '',
                                    color: '',
                                    lang: '',
                                    creatorId: 0,
                                    files: [],
                                  ),
                                );
                                print(
                                    'Group ID: ${specificGroup.id}, Files: ${specificGroup.files}');

                                await boardSettingsCubit.updateBoard(
                                  groupId: boardSettingsCubit.currentBoard.id,
                                  context: context,
                                  title: specificGroup.name,
                                  description: newBoard.description,
                                  color: newBoard.color,
                                  lang: newBoard.language.code,
                                );
                              }
                            } else {


                              int id =
                                  await context.read<AddBoardCubit>().addBoard(
                                        context: context,
                                        title: newBoard.title,
                                        description: newBoard.description,
                                        color: newBoard.color,
                                        lang: newBoard.language.code,
                                      );
                              newBoard.id = id;
                              widget.allBoardCubit
                                  .addNewBoard(newBoard: newBoard);
                            }

                            widget.allBoardCubit.refresh();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                        ),
                        bottom: TabBar(
                          labelColor: isDarkTheme ? Colors.white : Colors.black,
                          unselectedLabelColor:
                              Theme.of(context).textTheme.bodySmall!.color,
                          indicator: BoxDecoration(
                            color:
                                isDarkTheme ? AppColors.dark : AppColors.gray,
                          ),
                          labelStyle: TextStyle(
                            fontSize: Statics.isPlatformDesktop
                                ? mediaQuery.width / 90
                                : mediaQuery.width / 30,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: Statics.isPlatformDesktop
                                ? mediaQuery.width / 90
                                : mediaQuery.width / 30,
                          ),
                          tabs: boardSettingsCubit.currentBoard.parentId != null
                              ? [
                                  Tab(
                                    text: S.of(context).settings,
                                    icon: const Icon(Icons.settings),
                                  ),
                                ]
                              : [
                                  Tab(
                                    text: S.of(context).settings,
                                    icon: Icon(
                                      Icons.settings,
                                      size: mediaQuery.width / 30,
                                    ),
                                  ),
                                  Tab(
                                    text: S.of(context).users,
                                    icon: Icon(
                                      Icons.person,
                                      size: mediaQuery.width / 30,
                                    ),
                                  ),
                                  Tab(
                                    text: S.of(context).privacy,
                                    icon: Icon(
                                      Icons.visibility,
                                      size: mediaQuery.width / 30,
                                    ),
                                  ),
                                ],
                        ),
                      ),
                      body: boardSettingsCubit.currentBoard.parentId != null
                          ? TabBarView(
                              children: [
                                BoardSettingsSection(
                                  boardSettingsCubit: boardSettingsCubit,
                                  mediaQuery: mediaQuery,
                                ),
                              ],
                            )
                          : TabBarView(
                              children: [
                                BoardSettingsSection(
                                  boardSettingsCubit: boardSettingsCubit,
                                  mediaQuery: mediaQuery,
                                ),
                                BoardUsersSection(
                                  mediaQuery: mediaQuery,
                                  boardSettingsCubit: boardSettingsCubit,
                                ),
                                BoardPrivacySection(
                                  boardSettingsCubit: boardSettingsCubit,
                                  mediaQuery: mediaQuery,
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
