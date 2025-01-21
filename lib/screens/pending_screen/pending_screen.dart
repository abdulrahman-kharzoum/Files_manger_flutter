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

import '../../models/invite_model.dart';
import '../../widgets/helper/no_data.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final cubit = context.read<PendingCubit>();
    List<Invite> invitations = [];
    return Scaffold(
      appBar: CustomAppBar(
        title: S.of(context).pending,
        autoLeading: false,
      ),
      backgroundColor: Theme.of(context).textTheme.headlineSmall!.color,
      body: Expanded(
        child: SingleChildScrollView(
          child: Column(
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
                  } else if (state is PendingInviteRejectedSuccessState) {
                    Navigator.pop(context);
                    showLightSnackBar(context, S.of(context).invite_rejected);
                  }
                  if (state is PendingInviteDeletedSuccessState) {
                    Navigator.pop(context);
                    showLightSnackBar(context, S.of(context).invite_deleted);
                  }
                  if (state is PendingInviteAcceptedSuccessState ||
                      state is PendingInviteRejectedSuccessState ||
                      state is PendingInviteDeletedSuccessState) {
                    invitations.clear();
                    cubit.getInvites(context: context);
                  }
                },
                builder: (context, state) {
                  var userModelData = CashNetwork.getCashData(key: 'user_model');
                  var user = UserModel.fromJson(jsonDecode(userModelData));
          
                  if (state is PendingSuccessState) {
                    final invitationResponse = state.invitationResponse;
                    final invitesFromMe = invitationResponse.invitationsFromMe;
                    final invitesToMe = invitationResponse.invitationsToMe;
          
                    if (invitesFromMe.isEmpty && invitesToMe.isEmpty) {
                      return Center(
                        child: NoData(
                            iconData: Icons.search, text: S.of(context).no_data),
                      );
                    }
          
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (invitesFromMe.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Invites From Me',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: invitesFromMe.length,
                            itemBuilder: (context, index) {
                              final invite = invitesFromMe[index];
                              return NotificationCard(
                                isThisNotificationToMe: false,
                                title:
                                    'Invitation to ${invite.user?.name ?? 'Unknown'}',
                                content:
                                    'You invited ${invite.user?.name ?? 'Unknown'} to join ${invite.group?.name ?? 'a group'}',
                                isRead: false,
                                time: invite.invitationExpiresAt ??
                                    'No expiration time',
                                showAcceptDeniedButtons: false,
                                onDelete: () async {
                                  await cubit.deleteInvite(
                                    context: context,
                                    inviteId: invite.id,
                                    isRejected: false,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                        if (invitesToMe.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Invites To Me',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: invitesToMe.length,
                            itemBuilder: (context, index) {
                              final invite = invitesToMe[index];
                              return NotificationCard(
                                isThisNotificationToMe: true,
                                title:
                                    'Invitation from ${invite.inviter?.name ?? 'Unknown'}',
                                content:
                                    'You have been invited to join ${invite.group?.name ?? 'a group'}',
                                isRead: false,
                                time: invite.invitationExpiresAt ??
                                    'No expiration time',
                                showAcceptDeniedButtons: true,
                                onAccept: () async {
                                  await cubit.acceptInvite(
                                    context: context,
                                    inviteId: invite.id,
                                  );
                                },
                                onDenied: () async {
                                  await cubit.deleteInvite(
                                    context: context,
                                    inviteId: invite.id,
                                    isRejected: true,
                                  );
                                },
                                onDelete: () async {
                                  await cubit.deleteInvite(
                                    context: context,
                                    inviteId: invite.id,
                                    isRejected: true,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  }
                  return Container();
                  // return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
