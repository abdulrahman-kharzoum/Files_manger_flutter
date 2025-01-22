import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/core/animation/dialogs/expired_dialog.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/core/shimmer/board_shimmer.dart';
import 'package:files_manager/cubits/file_versions_cubit/file_versions_cubit.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/screens/file_profile_screen/compare_screen.dart';
import 'package:files_manager/theme/color.dart';
import 'package:files_manager/widgets/helper/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/functions/statics.dart';
import '../../cubits/cubit/compare_cubit.dart';

class FileProfileScreen extends StatelessWidget {
  const FileProfileScreen({super.key, required this.fileName});
  final String fileName;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final fileVersionsCubit = context.read<FileVersionsCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text('$fileName profile'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: mediaQuery.height / 90),
        width: mediaQuery.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: mediaQuery.height / 80),
              alignment: Alignment.center,
              width: mediaQuery.width / 2,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Text(
                S.of(context).all_versions,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: mediaQuery.height / 100,
            ),
            Container(
              height: mediaQuery.height / 1.2,
              width: mediaQuery.width / 1.6,
              child: BlocConsumer<FileVersionsCubit, FileVersionsState>(
                listener: (context, state) {
                  if (state is FileVersionsDownloadLoadingState) {
                    loadingDialog(context: context, mediaQuery: mediaQuery);
                  }
                  if (state is FileVersionsErrorState) {
                    errorDialog(context: context, text: state.errorMessage);
                  } else if (state is FileVersionsExpiredState) {
                    showExpiredDialog(
                      context: context,
                      onConfirmBtnTap: () async {
                        CashNetwork.clearCash();
                        await Hive.box('main').clear();
                        Phoenix.rebirth(context);
                      },
                    );
                  }
                },
                builder: (context, state) {
                  return state is FileVersionsLoadingState
                      ? BoardShimmer()
                      : fileVersionsCubit.allVersions.isEmpty
                          ? NoData(
                              iconData: Icons.file_copy,
                              text: S.of(context).no_data)
                          : ListView.builder(
                              itemCount: fileVersionsCubit.allVersions.length,
                              itemBuilder: (context, index) {
                                return Card(
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
                                        Icon(Icons.file_copy),
                                      ],
                                    ),
                                    subtitle: Text(
                                      fileVersionsCubit
                                          .allVersions[index].dateTime,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    trailing: fileVersionsCubit
                                            .allVersions[index]
                                            .comparison
                                            .isEmpty
                                        ? PopupMenuButton(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) async {
                                              if (value == 'download') {
                                                fileVersionsCubit
                                                    .downloadComparisonFile(
                                                        file: fileVersionsCubit
                                                            .allVersions[index],
                                                        fileName: fileName,
                                                        context: context);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'download',
                                                child: ListTile(
                                                  leading: const Icon(
                                                      Icons.download),
                                                  title: Text(
                                                      S.of(context).download),
                                                ),
                                              ),
                                            ],
                                          )
                                        : PopupMenuButton(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) async {
                                              if (value == 'download') {
                                                fileVersionsCubit
                                                    .downloadComparisonFile(
                                                        file: fileVersionsCubit
                                                            .allVersions[index],
                                                        fileName: fileName,
                                                        context: context);
                                              } else if (value == 'compare') {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BlocProvider(
                                                      create: (context) => CompareCubit(
                                                          diffData:
                                                              fileVersionsCubit
                                                                  .allVersions[
                                                                      index]
                                                                  .comparison)
                                                        ..setHtml(),
                                                      child: CompareScreen(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'compare',
                                                child: ListTile(
                                                  leading: const Icon(Icons
                                                      .compare_arrows_rounded),
                                                  title: Text(
                                                      S.of(context).compare),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'download',
                                                child: ListTile(
                                                  leading: const Icon(
                                                      Icons.download),
                                                  title: Text(
                                                      S.of(context).download),
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
                                              '$fileName-${fileVersionsCubit.allVersions[index].version.toString()}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall!
                                                    .color,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fade(
                                      duration:
                                          const Duration(milliseconds: 500),
                                    );
                              },
                            );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
