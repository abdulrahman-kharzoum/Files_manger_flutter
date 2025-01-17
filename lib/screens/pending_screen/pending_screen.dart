import 'dart:convert';

import 'package:files_manager/core/functions/snackbar_function.dart';

import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/models/Api_user.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:files_manager/core/shared/local_network.dart';

import 'package:files_manager/widgets/home/custom_appbar.dart';

import 'package:files_manager/widgets/notification/notification_card.dart';

import '../../core/animation/dialogs/dialogs.dart';

import 'package:files_manager/cubits/pending_cubit/pending_cubit.dart';

import '../../widgets/helper/no_data.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final cubit = context.read<PendingCubit>();
    return Scaffold(
      appBar: CustomAppBar(title: S.of(context).pending),
      backgroundColor: Theme.of(context).textTheme.headlineSmall!.color,
      body: Column(
        children: [
          BlocConsumer<PendingCubit, PendingState>(
            listener: (BuildContext context, PendingState state) {
              if (state is PendingLoading) {
                loadingDialog(context: context, mediaQuery: mediaQuery);
              }
              if (state is PendingNoData) {
                NoData(iconData: Icons.search, text: S.of(context).no_data);
              }
              if (state is PendingFailedState) {
                errorDialog(context: context, text: state.errorMessage);
              }
              if (state is PendingInviteAcceptedSuccessState) {
                Navigator.pop(context);
                showLightSnackBar(context, S.of(context).invite_accepted);
              }
              if (state is PendingInviteDeletedSuccessState) {
                Navigator.pop(context);
                showLightSnackBar(context, S.of(context).invite_deleted);
              }
            },
            builder: (context, state) {
              var userModelData = CashNetwork.getCashData(key: 'user_model');
              var user = UserModel.fromJson(jsonDecode(userModelData));

              if (state is PendingSuccessState) {
                final invitationResponse = state.invitationResponse;
                final invitations = invitationResponse.invitationsFromMe +
                    invitationResponse.invitationsToMe;

                if (invitations.isEmpty) {
                  return Center(child: NoData(iconData: Icons.search, text: S.of(context).no_data));
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: invitations.length,
                    itemBuilder: (context, index) {
                      final invitation = invitations[index];

                      return NotificationCard(
                        title:
                            'Invitation from ${invitation.inviter?.name == user.name ? 'me' : invitation.inviter?.name ?? 'Unknown'}',
                        content: invitation.inviter?.name == user.name
                            ? 'You invited ${invitation.user?.name ?? 'Unknown'} to join a group:'
                            : 'You have been invited to join a group: ${invitation.group?.name ?? 'Unknown Group'} ExpiresAt',
                        isRead: false,
                        time: invitation.invitationExpiresAt ??
                            'No expiration time',
                        showAcceptDeniedButtons:
                            invitation.inviter?.name == user.name
                                ? false
                                : true,
                        onAccept: invitation.inviter?.name == user.name
                            ? null
                            : () async {
                                await cubit.acceptInvite(
                                  context: context,
                                  inviteId: invitation.id,
                                );
                              },
                        onDenied: invitation.inviter?.name == user.name
                            ? null
                            : () async {
                                await cubit.deleteInvite(
                                  context: context,
                                  inviteId: invitation.id,
                                );
                              },
                        onDelete: () async {

                          invitations.removeAt(index);


                          if (invitation.inviter?.name == user.name) {
                            invitationResponse.invitationsFromMe.removeWhere((invite) => invite.id == invitation.id);

                            await cubit.deleteInvite(
                              context: context,
                              inviteId: invitation.id,
                            );
                          } else {
                            invitationResponse.invitationsToMe.removeWhere((invite) => invite.id == invitation.id);
                          }


                          cubit.emitUpdatedState(invitations);


                        },
                        // cubit.(invitations);
                      );
                    },
                  ),
                );
              }

              return Container();
            },
          ),
        ],
      ),
    );
  }
}
