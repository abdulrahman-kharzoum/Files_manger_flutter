part of 'file_versions_cubit.dart';

@immutable
sealed class FileVersionsState {}

final class FileVersionsInitial extends FileVersionsState {}

final class FileVersionsLoadingState extends FileVersionsState {}

final class FileVersionsDownloadLoadingState extends FileVersionsState {}

final class FileVersionsDownloadSuccessState extends FileVersionsState {}

final class FileVersionsSuccessState extends FileVersionsState {}

final class FileVersionsExpiredState extends FileVersionsState {}

final class FileVersionsErrorState extends FileVersionsState {
  final String errorMessage;
  FileVersionsErrorState({required this.errorMessage});
}
