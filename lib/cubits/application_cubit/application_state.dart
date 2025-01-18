part of 'application_cubit.dart';

@immutable
sealed class ApplicationState {}

final class ApplicationInitial extends ApplicationState {}

final class GetAllApplicationsInBoardLoading extends ApplicationState {}
final class NavigationInProgress extends ApplicationState {}
final class NavigationCompleted extends ApplicationState {}
final class GetAllApplicationsInFolderLoading extends ApplicationState {}
final class BoardDeleteApplicationLoading extends ApplicationState {}
final class BoardCheckApplicationLoading extends ApplicationState {}
final class BoardMultiCheckApplicationLoading extends ApplicationState {}
final class BoardCheckOutApplicationLoading extends ApplicationState {}
final class BoardCheckApplicationSuccess extends ApplicationState {}
final class BoardCheckOutApplicationSuccess extends ApplicationState {}
final class BoardMultiCheckApplicationSuccess extends ApplicationState {}

final class BoardDeleteApplicationSuccess extends ApplicationState {}
final class GetAllApplicationsInBoardSuccess extends ApplicationState {
  final List<Application> newBoardsApp;
  final bool isReachMax;

  GetAllApplicationsInBoardSuccess(
      {required this.newBoardsApp, required this.isReachMax});
}

final class GetAllApplicationsInFolderSuccess extends ApplicationState {
  final List<Application> newBoardsApp;

  GetAllApplicationsInFolderSuccess({required this.newBoardsApp});
}


final class GetAllApplicationsInBoardFailure extends ApplicationState {
  final String errorMessage;

  GetAllApplicationsInBoardFailure({required this.errorMessage});
}

final class GetAllApplicationsInBoardExpiredToken extends ApplicationState {}

final class GetAllApplicationsInBoardServerError extends ApplicationState {}

final class GetAllApplicationsInBoardNoInternet extends ApplicationState {}
