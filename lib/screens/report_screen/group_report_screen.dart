import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/cubits/board_settings_cubit/board_settings_cubit.dart';
import 'package:files_manager/cubits/group_report_cubit/group_report_cubit.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/models/member_model.dart';
import 'package:files_manager/theme/color.dart';
import 'package:files_manager/widgets/helper/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:files_manager/core/functions/statics.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class GroupReportScreen extends StatefulWidget {
  final int groupId;
  final List<Member> members;

  const GroupReportScreen(
      {Key? key, required this.groupId, required this.members})
      : super(key: key);

  @override
  _GroupReportScreenState createState() => _GroupReportScreenState();
}

class _GroupReportScreenState extends State<GroupReportScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingFirst = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    context.read<GroupReportCubit>().getAllGroupReports(
          context: context,
          groupId: widget.groupId,
      pdf:0
        );
  }

  Widget _buildFilterRow(BuildContext context) {
    final cubit = context.read<GroupReportCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              FilterChip(
                label: Text('Creation'),
                selected: cubit.includeCreation,
                onSelected: (v) {
                  cubit.updateFilters(creation: v);
                  _loadReports();
                },
              ),
              SizedBox(width: 8),
              FilterChip(
                label: Text('File Management'),
                selected: cubit.includeFileManagement,
                onSelected: (v) {
                  cubit.updateFilters(fileManagement: v);
                  _loadReports();
                },
              ),
              SizedBox(width: 8),
              FilterChip(
                label: Text('Check In/Out'),
                selected: cubit.includeCheckInOut,
                onSelected: (v) {
                  cubit.updateFilters(checkInOut: v);
                  _loadReports();
                },
              ),
              SizedBox(width: 8),
              FilterChip(
                label: Text('Member Management'),
                selected: cubit.includeMemberManagement,
                onSelected: (v) {
                  cubit.updateFilters(memberManagement: v);
                  _loadReports();
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userIdController,

                  decoration: InputDecoration(
                      focusColor: Theme.of(context).focusColor,
                      labelText: 'User Name',
                      hintText: 'Enter user Name',
                      border: OutlineInputBorder(),
                      fillColor: Theme.of(context).focusColor,

                      hoverColor: Theme.of(context).hoverColor),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final userName = _userIdController.text;
                  for (Member m in widget.members)
                    if (userName == m.firstName) {
                      context
                          .read<GroupReportCubit>()
                          .updateFilters(userId: m.id != null ? m.id : null);
                    }
                  _loadReports();
                },
                child: Text('Apply User Filter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Statics.isPlatformDesktop;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(S.of(context).group_report, style: theme.textTheme.titleLarge),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: theme.iconTheme.color),
            onPressed: () async {
              context.read<GroupReportCubit>().getAllGroupReports(
                  context: context,
                  groupId: widget.groupId,
                  pdf:1
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<GroupReportCubit, GroupReportState>(
        listener: (context, state) {
          if (state is GroupReportLoadingState) {
            loadingDialog(context: context, mediaQuery: mediaQuery);
            _isLoading = true;
          } else if (state is GroupReportSuccessState ||
              state is GroupReportFailureState) {
            if (_isLoading) {
              Navigator.of(context, rootNavigator: true).pop();
              _isLoading = false;
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Always show the filters
              _buildFilterRow(context),
              // Show content based on the state
              Expanded(
                child:
                    _buildContent(context, state, theme, isDesktop, mediaQuery),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GroupReportState state,
    ThemeData theme,
    bool isDesktop,
    Size mediaQuery,
  ) {
    if (state is GroupReportLoadingState) {
      if (_isLoadingFirst) {
        _isLoadingFirst = false;
        return Center(
          child: SpinKitFadingCircle(
            color: AppColors.primaryColor,
            size: mediaQuery.width / 8,
          ),
        );
      } else {
        return SizedBox();
      }
    } else if (state is GroupReportFailureState) {
      return Center(
        child: Text(
          state.errorMessage,
          style: TextStyle(
            color: theme.textTheme.headlineSmall!.color,
            fontSize: isDesktop ? 20 : 16,
          ),
        ),
      );
    } else if (state is GroupReportSuccessState) {
      _isLoading = false;
      final report = state.groupReportModel;
      if (report.data.isEmpty) {
        return Center(
          child: NoData(iconData: Icons.search, text: S.of(context).no_data),
        );
      }

      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
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
                        (states) => theme.primaryColor,
                      ),
                      columns: [
                        DataColumn(
                          label: Text('Message',
                              style: theme.textTheme.titleMedium),
                        ),
                        DataColumn(
                          label:
                              Text('Date', style: theme.textTheme.titleMedium),
                        ),
                        DataColumn(
                          label: Text('Operation',
                              style: theme.textTheme.titleMedium),
                        ),
                        DataColumn(
                          label:
                              Text('User', style: theme.textTheme.titleMedium),
                        ),
                      ],
                      rows: report.data.map((operation) {
                        return DataRow(cells: [
                          DataCell(Text(
                            operation.message,
                            style: TextStyle(
                              color: theme.textTheme.headlineSmall!.color,
                              fontSize: isDesktop ? 20 : 16,
                            ),
                          )),
                          DataCell(Text(
                            operation.date,
                            style: TextStyle(
                              color: theme.textTheme.headlineSmall!.color,
                              fontSize: isDesktop ? 20 : 16,
                            ),
                          )),
                          DataCell(Text(
                            operation.operation ?? '-',
                            style: TextStyle(
                              color: theme.textTheme.headlineSmall!.color,
                              fontSize: isDesktop ? 20 : 16,
                            ),
                          )),
                          DataCell(Text(
                            operation.user ?? '-',
                            style: TextStyle(
                              color: theme.textTheme.headlineSmall!.color,
                              fontSize: isDesktop ? 20 : 16,
                            ),
                          )),
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
      return NoData(iconData: Icons.search, text: S.of(context).no_data);
    }
  }
}
