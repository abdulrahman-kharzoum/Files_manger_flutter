import 'package:files_manager/core/functions/snackbar_function.dart';
import 'package:files_manager/models/file_model.dart';
import 'package:files_manager/models/folder_model.dart';
import 'package:files_manager/widgets/custom_text_fields/custom_text_field.dart';
import 'package:files_manager/widgets/custom_text_fields/custom_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/cubits/all_boards_cubit/all_boards_cubit.dart';
import 'package:files_manager/cubits/application_cubit/application_cubit.dart';
import 'package:files_manager/cubits/board_add_application_cubit/board_add_application_cubit.dart';
import 'package:files_manager/cubits/board_cubit/board_cubit.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/theme/color.dart';
import 'package:files_manager/widgets/all_applications_screen/application_widget.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/functions/statics.dart';

Future<void> showFolderNameDialog({
  required BuildContext context,
  bool isEdit=false,
  required Function(String folderName) onConfirm,
}) async {
  final TextEditingController folderNameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).textTheme.headlineSmall!.color!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          S.of(context).create_folder,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).enter_folder_name,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CustomFormTextField(
              controller: folderNameController,
              nameLabel: '',
              hintText: S.of(context).folder_name,
              fillColor: Colors.transparent,
              borderColor: Theme.of(context).textTheme.labelSmall!.color!,
              styleInput: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall!.color),
              maxLines: 5,
              borderRadius: 25.0,
              onChanged: (p0) async {
                // await boardSettingsCubit.changeDescription();
              },
              validator: (p0) {
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final folderName = folderNameController.text.trim();
              if (folderName.isNotEmpty) {
                await onConfirm(folderName);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).folder_name_not_empty),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              isEdit ? S.of(context).edit : S.of(context).create,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showFileNameDialog({
  required BuildContext context,
  bool isEdit = false,
  required Function(String fileName) onConfirm,
}) async {
  final TextEditingController fileNameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).textTheme.headlineSmall!.color!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          S.of(context).create_file,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).enter_file_name,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CustomFormTextField(
              controller: fileNameController,
              nameLabel: '',
              hintText: S.of(context).file_name,
              fillColor: Colors.transparent,
              borderColor: Theme.of(context).textTheme.labelSmall!.color!,
              styleInput: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall!.color),
              maxLines: 5,
              borderRadius: 25.0,
              onChanged: (p0) async {
                // await boardSettingsCubit.changeDescription();
              },
              validator: (p0) {
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final folderName = fileNameController.text.trim();
              if (folderName.isNotEmpty) {
                await onConfirm(folderName);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).folder_name_not_empty),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              isEdit ? S.of(context).edit : S.of(context).create,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class AllApplicationsScreen extends StatelessWidget {
  const AllApplicationsScreen({
    super.key,
    required this.boardCubit,
    required this.uuid,
    required this.allBoardsCubit,
    required this.applicationCubit,
  });

  final BoardCubit boardCubit;
  final String uuid;
  final AllBoardsCubit allBoardsCubit;
  final ApplicationCubit applicationCubit;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final boardAddApplicationCubit = context.read<BoardAddApplicationCubit>();
    return Scaffold(
      backgroundColor: AppColors.dark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.cancel_outlined,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        height: mediaQuery.height,
        width: mediaQuery.width,
        padding: EdgeInsets.symmetric(
          horizontal: mediaQuery.width / 30,
          vertical: mediaQuery.height / 15,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            S.of(context).applications,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: Statics.isPlatformDesktop
                  ? mediaQuery.width / 55
                  : mediaQuery.width / 18,
            ),
          ),
          Text(
            S.of(context).click_on_the_app_to_add_it_to_the_board,
            style: TextStyle(
              color: Colors.white30,
              fontSize: Statics.isPlatformDesktop
                  ? mediaQuery.width / 75
                  : mediaQuery.width / 25,
            ),
          ),
          SizedBox(
            height: mediaQuery.height / 80,
          ),
          BlocConsumer<BoardAddApplicationCubit, BoardAddApplicationState>(
            listener: (context, state) {
              if (state is BoardAddApplicationLoading) {
                loadingDialog(context: context, mediaQuery: mediaQuery);
              } else if (state is BoardAddApplicationSuccess) {
                showLightSnackBar(context, S.of(context).added);
                boardCubit.currentBoard.allFiles.add(state.addedApplication);

                applicationCubit.pagingController
                    .appendLastPage([state.addedApplication]);
                Navigator.of(context).pop();
              } else if (state is BoardAddApplicationSuccessNeedWaiting) {
                showLightSnackBar(context, S.of(context).waiting_admin);
                Navigator.pop(context);
              } else if (state is BoardAddApplicationFailure) {
                errorDialog(context: context, text: state.errorMessage);
              }
            },
            builder: (context, state) {
              return Wrap(
                alignment: WrapAlignment.end,
                children: [
                  ApplicationWidget(
                    mediaQuery: mediaQuery,
                    context: context,
                    asset: 'assets/images/new-file-icon.jpg',
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'txt',
                          'csv',
                          'json',
                          'xml',
                          'html',
                          'htm',
                          'css',
                          'js',
                          'bat',
                          'cmd',
                          'ini',
                          'log',
                          'reg',
                          'vbs',
                          'ps1',
                          'py',
                          'sh',
                          'yml',
                          'yaml',
                          'md',
                          'config',
                          'inf',
                          'nfo',
                          'rtf',
                          'srt',
                          'url',
                          'gitignore',
                          'env',
                          'properties',
                          'sql',
                          'ts',
                          'tsv',
                          'xaml',
                          'xsd',
                          'xsl',
                          'xslt',
                        ],
                      );

                      if (result != null) {
                        final imageExtensions = [
                          'jpg',
                          'jpeg',
                          'png',
                          'gif',
                          'bmp',
                          'webp'
                        ];
                        final videoExtensions = [
                          'mp4',
                          'mov',
                          'avi',
                          'mkv',
                          'webm'
                        ];

                        final selectedFile = result.files.first;
                        // Check if the file is an image or video
                        if (imageExtensions.contains(
                                selectedFile.extension?.toLowerCase()) ||
                            videoExtensions.contains(
                                selectedFile.extension?.toLowerCase())) {
                          // Show error if the file is an image or video
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  S.of(context).error_Images_video_not_allowed),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          await showFileNameDialog(
                            context: context,
                            onConfirm: (fileName) async {
                              await boardAddApplicationCubit
                                  .addApplicationFunction(
                                      context: context,
                                      fileName: fileName +
                                          '.${selectedFile.extension!}',
                                      file: selectedFile,
                                      parent_id: applicationCubit
                                              .folderHistory.isNotEmpty
                                          ? applicationCubit.folderHistory.last
                                          : 0,
                                      is_folder: false,
                                      group_id: boardCubit.currentBoard.id);
                            },
                          );
                        }

                        // boardCubit.currentBoard.allFiles.add(FileModel(
                        //     id: boardCubit.currentBoard.allFiles.isEmpty
                        //         ? 1
                        //         : boardCubit.currentBoard.allFiles.last
                        //                 .getApplicationId() +
                        //             1,
                        //     boardId: boardCubit.currentBoard.id,
                        //     title: 'New file',
                        //     mode: 'free',
                        //     createdAt: DateTime.now(),
                        //     updatedAt: DateTime.now()));
                        Navigator.pop(context);

                        await boardCubit.refresh();
                        await allBoardsCubit.refresh();
                        // Navigator.pop(context);
                      } else {
                        // User canceled the picker
                      }
                    },
                    title: 'New File',
                  ),
                  ApplicationWidget(
                      mediaQuery: mediaQuery,
                      context: context,
                      asset: 'assets/images/new-folder-icon.jpg',
                      onTap: () async {
                        // boardCubit.currentBoard.allFiles.add(FolderModel(
                        //     id: boardCubit.currentBoard.allFiles.isEmpty
                        //         ? 1
                        //         : boardCubit.currentBoard.allFiles.last
                        //         .getApplicationId() +
                        //         1,
                        //     boardId: boardCubit.currentBoard.id,
                        //     allFiles: [],
                        //     title: 'New folder',
                        //     mode: 'free',
                        //     createdAt: DateTime.now(),
                        //     updatedAt: DateTime.now()));
                        // await boardAddApplicationCubit.addApplicationFunction(
                        //     context: context,
                        //     fileName: 'new Folder',
                        //     parent_id: 0,
                        //     is_folder: true,
                        //     group_id: boardCubit.currentBoard.id);

                        await showFolderNameDialog(
                          context: context,
                          onConfirm: (folderName) async {
                            await boardAddApplicationCubit
                                .addApplicationFunction(
                                    context: context,
                                    fileName: folderName,
                                    parent_id: applicationCubit
                                            .folderHistory.isNotEmpty
                                        ? applicationCubit.folderHistory.last
                                        : 0,
                                    is_folder: true,
                                    group_id: boardCubit.currentBoard.id);
                          },
                        );
                        Navigator.pop(context);

                        await boardCubit.refresh();
                        await allBoardsCubit.refresh();
                      },
                      title: 'New Folder'),
                ],
              );
            },
          )
        ]),
      ),
    );
  }
}
