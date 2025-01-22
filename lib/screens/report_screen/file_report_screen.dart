import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/theme/color.dart';
import 'package:files_manager/widgets/helper/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:files_manager/cubits/file_report_cubit/file_report_cubit.dart';
import 'package:files_manager/core/functions/statics.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FileReportScreen extends StatefulWidget {
  final int fileId;

  const FileReportScreen({Key? key, required this.fileId}) : super(key: key);

  @override
  _FileReportScreenState createState() => _FileReportScreenState();
}

class _FileReportScreenState extends State<FileReportScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch file reports when the screen is loaded
    context.read<FileReportCubit>().getAllFileReports(
      context: context,
      fileId: widget.fileId,
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Statics.isPlatformDesktop;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context).size;
    final fileReportCubit = context.read<FileReportCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).file_report, style: theme.textTheme.titleLarge),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: theme.iconTheme.color),
            onPressed: () async  {
              await fileReportCubit.getAllFileReportsPdf(context: context, fileId: widget.fileId);

            },
          ),
        ],
      ),
      body: BlocConsumer<FileReportCubit, FileReportState>(
        listener: (context,state){
          if (state is FileReportLoadingState) {
          loadingDialog(context: context, mediaQuery: mediaQuery);
          } else if (state is FileReportFailureState) {
            // Return an error message widget
           errorDialog(context: context, text: state.errorMessage);
          }
        },
        builder: (context, state) {
          if (state is FileReportLoadingState) {
            // Return a loading indicator widget
            return Center(
              child: SpinKitFadingCircle(
                color: AppColors.primaryColor,
                size: mediaQuery.width / 8,
              ),
            );
          } else if (state is FileReportFailureState) {
            // Return an error message widget
            return Center(
              child: Text(
                state.errorMessage,
                style: TextStyle(
                  color: theme.textTheme.headlineSmall!.color,
                  fontSize: isDesktop ? 20 : 16,
                ),
              ),
            );
          } else if (state is FileReportSuccessState) {
            final report = state.fileReportModel;
            if (report.data.isEmpty) {

              return NoData(iconData: Icons.search, text: S.of(context).no_data);
            }


            return Align(
              alignment: Alignment.topCenter, // Align to the top center
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0), // Add some top padding
                child: Scrollbar(
                  controller: _verticalScrollController,

                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.primaryColor),
                            borderRadius: BorderRadius.circular(8),
                            color: theme.cardTheme.color,
                          ),
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                    (states) => theme.primaryColor),
                            columns: [
                              DataColumn(
                                  label: Text('Message',
                                      style: theme.textTheme.titleMedium)),
                              DataColumn(
                                  label: Text('Date',
                                      style: theme.textTheme.titleMedium)),
                              DataColumn(
                                  label: Text('Operation',
                                      style: theme.textTheme.titleMedium)),
                              DataColumn(
                                  label: Text('User',
                                      style: theme.textTheme.titleMedium)),
                            ],
                            rows: report.data.map((operation) {
                              return DataRow(cells: [
                                DataCell(Text(operation.message,
                                    style: TextStyle(
                                        color: theme.textTheme.headlineSmall!.color,
                                        fontSize: isDesktop ? 20 : 16))),
                                DataCell(Text(operation.date,
                                    style: TextStyle(
                                        color: theme.textTheme.headlineSmall!.color,
                                        fontSize: isDesktop ? 20 : 16))),
                                DataCell(Text(operation.operation,
                                    style: TextStyle(
                                        color: theme.textTheme.headlineSmall!.color,
                                        fontSize: isDesktop ? 20 : 16))),
                                DataCell(Text(operation.user,
                                    style: TextStyle(
                                        color: theme.textTheme.headlineSmall!.color,
                                        fontSize: isDesktop ? 20 : 16))),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            // Handle the initial state or any other state
            return NoData(iconData: Icons.search, text: S.of(context).no_data);
          }
        },
      ),
    );
  }
}