import 'dart:convert';

import 'package:files_manager/cubits/group_report_cubit/group_report_cubit.dart';
import 'package:files_manager/cubits/pending_cubit/pending_cubit.dart';
import 'package:files_manager/models/Api_user.dart';
import 'package:files_manager/screens/report_screen/group_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/core/functions/color_to_hex.dart';
import 'package:files_manager/cubits/add_board_cubit/add_board_cubit.dart';
import 'package:files_manager/cubits/all_boards_cubit/all_boards_cubit.dart';
import 'package:files_manager/cubits/application_cubit/application_cubit.dart';
import 'package:files_manager/cubits/board_add_application_cubit/board_add_application_cubit.dart';
import 'package:files_manager/cubits/board_cubit/board_cubit.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/screens/add_board_screen/sub_board_screen.dart';
import 'package:files_manager/screens/all_applications_screen/all_applications_screen.dart';
import 'package:files_manager/widgets/applications_widgets/show_applications_data.dart';
import '../../core/animation/dialogs/expired_dialog.dart';
import '../../core/shared/local_network.dart';
import '../../cubits/board_settings_cubit/board_settings_cubit.dart';
import '../../cubits/leave_from_board_cubit/leave_from_board_cubit.dart';
import '../home/board_settings_screen.dart';
import '../pending_screen/pending_files_screen.dart';

class AddBoardScreen extends StatelessWidget {
  const AddBoardScreen({
    super.key,
    required this.allBoardsCubit,
    required this.uuid,
  });

  final AllBoardsCubit allBoardsCubit;
  final String uuid;

  @override
  Widget build(BuildContext context) {
    final boardCubit = context.read<BoardCubit>();
    final mediaQuery = MediaQuery.of(context).size;

    final applicationCubit = context.read<ApplicationCubit>();
    print(
        'Language Code In ${boardCubit.currentBoard.title} is \n ${boardCubit.currentBoard.language.code}');
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocConsumer<AddBoardCubit, AddBoardState>(
        listener: (context, state) {
          if (state is AddBoardFailedState) {
            errorDialog(context: context, text: state.errorMessage);
          } else if (state is AddBoardExpiredState) {
            showExpiredDialog(
              context: context,
              onConfirmBtnTap: () async {
                await CashNetwork.clearCash();
                await Hive.box('main').clear();
                Phoenix.rebirth(context);
              },
            );
          } else if (state is AddBoardSuccessState) {
            // Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) =>
                          BoardCubit(currentBoard: state.createdBoard)
                            ..initState(
                              context: context,
                              uuid: state.createdBoard.uuid,
                            ),
                    ),
                    BlocProvider(
                      create: (context) => AddBoardCubit(),
                    ),
                    BlocProvider(
                      create: (context) => LeaveFromBoardCubit(),
                    ),
                    BlocProvider(
                      create: (context) => ApplicationCubit()
                        ..initState(
                            context: context, groupId: state.createdBoard.id),
                    ),
                  ],
                  child: AddBoardScreen(
                    uuid: state.createdBoard.uuid,
                    allBoardsCubit: allBoardsCubit,
                  ),
                ),
              ),
            );
          } else if (state is AddBoardLoadingState) {
            loadingDialog(
                context: context,
                mediaQuery: mediaQuery,
                title: S.of(context).adding_board);
          }
        },
        builder: (context, state) {
          return BlocConsumer<BoardCubit, BoardState>(
            listener: (context, state) {},
            builder: (context, state) {
              var user_model = CashNetwork.getCashData(key: 'user_model');
              var user = UserModel.fromJson(jsonDecode(user_model));

              return boardCubit.currentBoard.parentId != null
                  ? SubBoardScreen(
                      allBoardsCubit: allBoardsCubit,
                      board: boardCubit.currentBoard,
                    )
                  : Localizations.override(
                      locale: Locale(boardCubit.currentBoard.language.code),
                      context: context,
                      child: DefaultTabController(
                        length: 1,
                        child: Scaffold(
                          backgroundColor:
                              hexToColor(boardCubit.currentBoard.color),
                          appBar: AppBar(
                            leading: IconButton(
                              tooltip: S.of(context).back,
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                boardCubit.currentBoard.allFiles.clear();
                                boardCubit.close();

                                Navigator.of(context).pop();
                              },
                            ),
                            title: Text(
                              boardCubit.boardTitleController.text,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            centerTitle: true,
                            actions: [
                              user.id.toString() == boardCubit.currentBoard.CreatorId?
                              IconButton(
                                tooltip: S.of(context).group_report,
                                icon:  Icon(Icons.group),
                                onPressed: () async {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (context) =>
                                                GroupReportCubit(),
                                          ),
                                          // Add other BlocProviders if needed
                                        ],
                                        child: GroupReportScreen(
                                          members:
                                              boardCubit.currentBoard.members,
                                          groupId: boardCubit.currentBoard.id,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ):SizedBox(),
                              IconButton(
                                tooltip: S.of(context).add_application,
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (context) =>
                                                BoardAddApplicationCubit(),
                                          ),
                                        ],
                                        child: AllApplicationsScreen(
                                          applicationCubit: applicationCubit,
                                          boardCubit: boardCubit,
                                          allBoardsCubit: allBoardsCubit,
                                          uuid: uuid,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: S.of(context).settings_board,
                                icon: const Icon(Icons.sort),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (context) =>
                                                BoardSettingsCubit(
                                                    currentBoard:
                                                        boardCubit.currentBoard)
                                                  ..initState(),
                                          ),
                                          BlocProvider(
                                              create: (context) =>
                                                  AddBoardCubit()),
                                        ],
                                        child: BoardSettingsScreen(
                                          allBoardCubit: allBoardsCubit,
                                        ),
                                      ),
                                    ),
                                  )
                                      .then((_) {
                                    boardCubit.initState(
                                        context: context, uuid: uuid);
                                  });
                                },
                              ),
                              user.id.toString() ==
                                      boardCubit.currentBoard.CreatorId
                                  ? IconButton(
                                      tooltip: S.of(context).files_to_approve,
                                      icon: const Icon(Icons.pending),
                                      onPressed: () async {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MultiBlocProvider(
                                                    providers: [
                                                  BlocProvider(
                                                    create: (context) =>
                                                        PendingCubit()
                                                          ..getAllFilesToApprove(
                                                              context: context,
                                                              groupId: boardCubit
                                                                  .currentBoard
                                                                  .id),
                                                  ),
                                                ],
                                                    child: PendingFilesScreen(
                                                      applicationCubit:
                                                          applicationCubit,
                                                      groupId: boardCubit
                                                          .currentBoard.id,
                                                    )),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                          body: TabBarView(
                            children: [
                              //Applications Data
                              ShowApplicationsData(
                                allBoardsCubit: allBoardsCubit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
            },
          );
        },
      ),
    );
  }
}
