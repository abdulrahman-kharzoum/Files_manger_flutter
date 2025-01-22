// group_report_state.dart
part of 'group_report_cubit.dart';

@immutable
abstract class GroupReportState {}

class GroupReportInitial extends GroupReportState {}

class GroupReportLoadingState extends GroupReportState {}

class GroupReportSuccessState extends GroupReportState {
  final GroupReportModel groupReportModel;
  GroupReportSuccessState({required this.groupReportModel});
}

class GroupReportFailureState extends GroupReportState {
  final String errorMessage;
  GroupReportFailureState({required this.errorMessage});
}