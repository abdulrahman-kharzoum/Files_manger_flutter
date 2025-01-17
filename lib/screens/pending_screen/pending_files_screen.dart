import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/widgets/helper/no_data.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:files_manager/widgets/home/custom_appbar.dart';

import 'package:intl/intl.dart';

import '../../core/animation/dialogs/dialogs.dart';

import 'package:files_manager/cubits/pending_cubit/pending_cubit.dart';

import '../../core/functions/snackbar_function.dart';
import '../../core/functions/statics.dart';

class PendingFilesScreen extends StatelessWidget {
  const PendingFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool accepted = false;
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
              } else if (state is PendingFileAcceptedOrRejectedSuccessState) {
                Navigator.pop(context);
                Navigator.pop(context);
                accepted
                    ? showLightSnackBar(context, S.of(context).accepted)
                    : showLightSnackBar(context, S.of(context).rejected);
              } else if (state is PendingNoData) {
                NoData(iconData: Icons.search, text: S.of(context).no_data);
              } else if (state is PendingFailedState) {
                errorDialog(context: context, text: state.errorMessage);
              }
            },
            builder: (context, state) {
              if (state is PendingToAprroveFilesSucces) {
                return Expanded(
                  child: ListView.builder(
                      itemCount: state.applicationsToApprove.length,
                      itemBuilder: (context, index) {
                        final file = state.applicationsToApprove[index];
                        return file.isFolder()
                            ? Card(
                                color: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .color,
                                child: ListTile(
                                  leading: Icon(Icons.folder),
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: SizedBox(
                                          width: Statics.isPlatformDesktop
                                              ? mediaQuery.width / 2.5
                                              : mediaQuery.width / 1.5,
                                          child: Text(
                                            file.getApplicationName(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      Statics.isPlatformDesktop
                                          ? Flexible(
                                              child: Text(
                                                DateFormat('yyyy-MM-d HH:mm:ss')
                                                    .format(
                                                  file.getApplicationCreateDate(),
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
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          print(
                                              "===========group Id ==========");
                                          print(
                                              "===========${cubit.group_id} ==========");

                                          await cubit.acceptOrRejectFile(
                                              context: context,
                                              status: "accepted",
                                              groupId: cubit.group_id!,
                                              fileId: file.getApplicationId());
                                          accepted = true;
                                        },
                                        child: const Text('Accept',
                                            style:
                                                TextStyle(color: Colors.green)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await cubit.acceptOrRejectFile(
                                              context: context,
                                              status: "rejected",
                                              groupId: cubit.group_id!,
                                              fileId: file.getApplicationId());
                                          accepted = false;
                                        },
                                        child: const Text('Denied',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
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
                                  leading: Icon(file.getIcon()),
                                  title: Row(
                                    children: [
                                      Flexible(
                                        child: SizedBox(
                                          width: Statics.isPlatformDesktop
                                              ? mediaQuery.width / 2.5
                                              : mediaQuery.width / 1.5,
                                          child:
                                              Text(file.getApplicationName()),
                                        ),
                                      ),
                                      Statics.isPlatformDesktop
                                          ? Text(
                                              DateFormat('yyyy-MM-d HH:mm:ss')
                                                  .format(file
                                                      .getApplicationCreateDate()),
                                              style: TextStyle(
                                                  color: Colors.black38),
                                            )
                                          : const SizedBox()
                                    ],
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          print(
                                              "===========group Id ==========");
                                          print(
                                              "===========${cubit.group_id} ==========");

                                          await cubit.acceptOrRejectFile(
                                              context: context,
                                              status: "accepted",
                                              groupId: cubit.group_id!,
                                              fileId: file.getApplicationId());
                                        },
                                        child: const Text('Accept',
                                            style:
                                                TextStyle(color: Colors.green)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await cubit.acceptOrRejectFile(
                                              context: context,
                                              status: "rejected",
                                              groupId: cubit.group_id!,
                                              fileId: file.getApplicationId());
                                        },
                                        child: const Text('Denied',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fade(
                                  duration: const Duration(milliseconds: 500),
                                );
                      }),
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
