import 'package:files_manager/cubits/user_report_cubit/user_report_cubit.dart';
import 'package:files_manager/cubits/user_report_cubit/user_report_state.dart';
import 'package:files_manager/models/member_model.dart';
import 'package:files_manager/models/user_report_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/animation/dialogs/dialogs.dart';

class UserReportScreen extends StatefulWidget {
  const UserReportScreen({Key? key}) : super(key: key);

  @override
  _UserReportScreenState createState() => _UserReportScreenState();
}

class _UserReportScreenState extends State<UserReportScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Report', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              final userId = context.read<UserReportCubit>().userId;
              if (userId != null) {
                context.read<UserReportCubit>().getAllUserReports(
                      context: context,
                      userId: userId,
                      pdf: 1,
                    );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<UserReportCubit, UserReportState>(
        listener: (context, state) {
          if (state is UserReportLoadingState) {
            loadingDialog(context: context, mediaQuery: mediaQuery);
          } else if (state is UserReportSuccessState ||
              state is UserReportFailureState) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildFilterRow(context, state),
              Expanded(
                child: _buildContent(context, state, theme),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, UserReportState state) {
    final UserReportCubit userReportCubit = context.read<UserReportCubit>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    hintText: 'Enter user name',
                    fillColor: Theme.of(context).focusColor,
                    focusColor: Theme.of(context).focusColor,
                    hoverColor: Theme.of(context).hoverColor,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    userReportCubit.search(context: context, userName: value);
                  },
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  userReportCubit.applyFilter(context);
                },
                child: Text('Apply Filter'),
              ),
            ],
          ),
          if (state is UserReportSearchResultsState)
            _buildSearchResults(state.members),
        ],
      ),
    );
  }
  Widget _buildSearchResults(List<Member> members) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Scrollbar(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).hoverColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                focusColor: Theme.of(context).focusColor,
                title: Text(
                  member.firstName ?? 'No Name',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineSmall!.color,
                  ),
                ),
                subtitle: Text(
                  member.email ?? 'No Email',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineSmall!.color,
                  ),
                ),
                onTap: () {
                  context.read<UserReportCubit>().selectMember(member);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, UserReportState state, ThemeData theme) {
    if (state is UserReportLoadingState) {
      return Center(child: CircularProgressIndicator());
    } else if (state is UserReportFailureState) {
      return Center(child: Text(state.errorMessage));
    } else if (state is UserReportSuccessState) {
      return _buildReportTable(state.userReportModel, theme);
    } else if (state is UserReportMemberSelectedState) {
      return Center(child: Text('Selected User: ${state.member.firstName}'));
    }
    return Center(child: Text('Search for a user to view report'));
  }

  Widget _buildReportTable(UserReportModel report, ThemeData theme) {
    return Scrollbar(
      controller: _verticalScrollController,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        child: Scrollbar(
          controller: _horizontalScrollController,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Message')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Type')),
              ],
              rows: report.data
                  .map((entry) => DataRow(
                        cells: [
                          DataCell(Text(entry.message)),
                          DataCell(Text(entry.date)),
                          DataCell(Text(entry.type)),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
