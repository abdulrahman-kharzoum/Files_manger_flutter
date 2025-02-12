import 'dart:convert';

import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/core/functions/snackbar_function.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/models/Api_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:files_manager/cubits/add_member_cubit/add_member_cubit.dart';
import 'package:files_manager/cubits/board_settings_cubit/board_settings_cubit.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/models/invited_user_model.dart';
import 'package:files_manager/screens/add_member_screen/add_member_screen.dart';
import 'package:files_manager/screens/add_member_screen/update_member_screen.dart';
import 'package:files_manager/theme/color.dart';
import 'package:files_manager/widgets/custom_text_fields/custom_text_field.dart';
import 'package:files_manager/widgets/helper/no_data.dart';

import '../../core/functions/statics.dart';
import '../../cubits/theme_cubit/app_theme_cubit.dart';

class BoardUsersSection extends StatelessWidget {
  BoardUsersSection(
      {super.key, required this.mediaQuery, required this.boardSettingsCubit});

  final Size mediaQuery;
  final BoardSettingsCubit boardSettingsCubit;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BoardSettingsCubit, BoardSettingsState>(
      listener: (context, state) {
        if (state is BoardSettingsSearchLoadingState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            loadingDialog(
              context: context,
              mediaQuery: mediaQuery,
            );
            _searchFocusNode.unfocus();
          });
        } else if (state is BoardSettingsInviteLoadingState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            loadingDialog(
                context: context,
                mediaQuery: mediaQuery,
                title: S.of(context).inviting);
          });
        } else if (state is BoardSettingsKickLoadingState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            loadingDialog(
                context: context,
                mediaQuery: mediaQuery,
                title: S.of(context).Kicking);
          });
        } else if (state is BoardSettingsInviteSuccessState) {
          if (context.mounted) Navigator.pop(context);
          showLightSnackBar(context, S.of(context).user_invited);
        }else if (state is BoardSettingsKickedSuccessState) {
          if (context.mounted) Navigator.pop(context);
          showLightSnackBar(context, S.of(context).user_kicked);
        }
        else if (state is BoardSettingsNoDataState) {
          NoData(iconData: Icons.search, text: S.of(context).no_data);
        } else if (state is BoardSettingsSearchSuccessState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.pop(context);
            if (context.mounted) Navigator.pop(context);
          });
        } else if (state is BoardSettingsFailedState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            errorDialog(context: context, text: state.errorMessage);
          });
        }
      },
      builder: (context, state) {
        return BlocBuilder<AppThemeCubit, AppThemeState>(
          builder: (context, state) {
            final isDarkTheme = state is AppThemeDark;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: mediaQuery.width / 30,
                vertical: mediaQuery.height / 90,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: mediaQuery.width / 1.3,
                        child: CustomFormTextField(
                          fillColor: Colors.transparent,
                          controller: boardSettingsCubit.searchController,
                          focusNode: _searchFocusNode,
                          borderRadius: 15,
                          borderColor:
                              Theme.of(context).textTheme.labelSmall!.color!,
                          hintText: S.of(context).search_about_user,
                          nameLabel: '',
                          onChanged: (p0) async {
                            await boardSettingsCubit.search(
                                context: context,
                                userName:
                                    boardSettingsCubit.searchController.text);
                            await boardSettingsCubit.getBoardInfo(
                                context: context,
                                groupId: boardSettingsCubit.currentBoard.id);
                          },
                          styleInput: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color!),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: IconButton(
                          onPressed: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => MultiBlocProvider(
                            //       providers: [
                            //         BlocProvider(
                            //           create: (context) => AddMemberCubit(),
                            //         ),
                            //       ],
                            //       child: AddMemberScreen(
                            //         boardSettingsCubit: boardSettingsCubit,
                            //       ),
                            //     ),
                            //   ),
                            // );
                          },
                          icon: const Icon(
                            Icons.add_circle,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  boardSettingsCubit.searchMembers.isEmpty
                      ? NoData(
                          iconData: Icons.search, text: S.of(context).no_data)
                      : Expanded(
                          child: ListView(
                            children: List.generate(
                              boardSettingsCubit.searchMembers.length,
                              (index) {
                                var user_model =
                                    CashNetwork.getCashData(key: 'user_model');
                                var user =
                                    UserModel.fromJson(jsonDecode(user_model));

                                bool isThisMe = user.id ==  boardSettingsCubit.searchMembers[index].id;
                                bool isTheMemberAdmin = boardSettingsCubit.searchMembers[index].id.toString() ==
                                    boardSettingsCubit.currentBoard.CreatorId
                                        .toString();
                                bool isAdmin = user.id.toString() ==
                                    boardSettingsCubit.currentBoard.CreatorId
                                        .toString();
                                bool isMember = boardSettingsCubit
                                    .currentBoard.members
                                    .any((member) =>
                                        member.id ==
                                        boardSettingsCubit
                                            .searchMembers[index].id);
                                return Row(
                                  children: [
                                    Expanded(
                                      child: boardSettingsCubit
                                                  .searchMembers[index]
                                              is InvitedUser
                                          ? ListTile(
                                              leading: memberWidget(
                                                  memberName: boardSettingsCubit
                                                      .searchMembers[index]
                                                      .invitedEmail,
                                                  role: null,
                                                  mediaQuery: mediaQuery,
                                                  userImage: boardSettingsCubit
                                                      .searchMembers[index]
                                                      .image),
                                              title: Text(
                                                '${boardSettingsCubit.searchMembers[index].invitedEmail}',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .color,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                '${S.of(context).status}: ${boardSettingsCubit.searchMembers[index].status}',
                                                style: TextStyle(
                                                    color: isDarkTheme
                                                        ? Colors.white54
                                                        : Colors.black54,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          : ListTile(
                                              leading: memberWidget(
                                                memberName: boardSettingsCubit
                                                    .searchMembers[index]
                                                    .firstName,
                                                role: boardSettingsCubit
                                                        .currentBoard.members
                                                        .any((member) =>
                                                            member.id ==
                                                            boardSettingsCubit
                                                                .searchMembers[
                                                                    index]
                                                                .id)
                                                    ? 'Member'
                                                    : boardSettingsCubit
                                                        .searchMembers[index]
                                                        .role,
                                                mediaQuery: mediaQuery,
                                                userImage: boardSettingsCubit
                                                    .searchMembers[index].image,
                                              ),
                                              title: Text(
                                                '${boardSettingsCubit.searchMembers[index].firstName} ${boardSettingsCubit.searchMembers[index].lastName}',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .color,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                '${(isTheMemberAdmin && isMember)? 'Admin':isMember ? 'Member' :boardSettingsCubit.searchMembers[index].role}',
                                                style: TextStyle(
                                                    color: isDarkTheme
                                                        ? Colors.white54
                                                        : Colors.black54,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),

                                            ),
                                    ),
                                    isAdmin && !isThisMe
                                        ? ElevatedButton(
                                            onPressed: isMember
                                                ? () async {
                                                    boardSettingsCubit.kickUser(
                                                        context: context,
                                                        userId:
                                                            boardSettingsCubit
                                                                .searchMembers[
                                                                    index]
                                                                .id,
                                                        groupId:
                                                            boardSettingsCubit
                                                                .currentBoard
                                                                .id);
                                                    await boardSettingsCubit
                                                        .resetSearch();
                                                    await boardSettingsCubit
                                                        .refresh();
                                                  }
                                                : () async {
                                                    boardSettingsCubit.inviteUser(
                                                        context: context,
                                                        userId:
                                                            boardSettingsCubit
                                                                .searchMembers[
                                                                    index]
                                                                .id,
                                                        groupId:
                                                            boardSettingsCubit
                                                                .currentBoard
                                                                .id);
                                                    await boardSettingsCubit
                                                        .resetSearch();
                                                    await boardSettingsCubit
                                                        .refresh();
                                                  },
                                            style: isMember
                                                ? ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  )
                                                : ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blueAccent,
                                                  ),
                                            child: Text(
                                              isMember
                                                  ? S.of(context).kick
                                                  : S.of(context).invite,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .color,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget memberWidget({
    required String memberName,
    required String? role,
    required Size mediaQuery,
    String? userImage,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Statics.isPlatformDesktop
                ? mediaQuery.width / 100
                : mediaQuery.width / 30,
            vertical: Statics.isPlatformDesktop
                ? mediaQuery.width / 150
                : mediaQuery.height / 80,
          ),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent,
          ),
          child: Text(
            memberName[0],
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: Statics.isPlatformDesktop
                    ? mediaQuery.width / 60
                    : mediaQuery.width / 30),
          ),
        ),
        if (role == 'admin')
          Positioned(
            bottom: Statics.isPlatformDesktop ? 10 : -5,
            right: -mediaQuery.width / 90,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: mediaQuery.width / 120,
                  vertical: mediaQuery.height / 130),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: Statics.isPlatformDesktop
                    ? mediaQuery.width / 120
                    : mediaQuery.width / 30,
              ),
            ),
          ),
      ],
    );
  }
}
