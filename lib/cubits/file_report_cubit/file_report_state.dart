part of 'file_report_cubit.dart';

@immutable
sealed class FileReportState {}

final class FileReportInitial extends FileReportState {}
final class FileReportLoadingState extends FileReportState {}
final class FileReportFailureState extends FileReportState {
  final String errorMessage;

  FileReportFailureState({required this.errorMessage});
}
final class FileReportSuccessState extends FileReportState {
  final FileReportModel fileReportModel;

  FileReportSuccessState({required this.fileReportModel});
}
