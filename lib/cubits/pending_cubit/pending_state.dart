part of 'pending_cubit.dart';

@immutable
sealed class PendingState {}

final class PendingInitial extends PendingState {}
final class PendingLoading extends PendingState {}
final class PendingNoData extends PendingState {}
final class PendingFailedServerError extends PendingState {}
final class PendingFailedNoInternet extends PendingState {}
final class PendingInviteAcceptedSuccessState extends PendingState {}
final class PendingFileAcceptedOrRejectedSuccessState extends PendingState {}
final class PendingInviteRejectedSuccessState extends PendingState {}
final class PendingInviteDeletedSuccessState extends PendingState {}
class PendingSuccessState extends PendingState {
  final InvitationResponse invitationResponse;

  PendingSuccessState({required this.invitationResponse});
}
final class PendingFailedState extends PendingState {
  final String errorMessage;
  PendingFailedState({required this.errorMessage});

}
final class PendingToAprroveFilesSucces extends PendingState {
  final List<Application> applicationsToApprove;
  PendingToAprroveFilesSucces({required this.applicationsToApprove});

}

