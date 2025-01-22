import 'package:files_manager/models/member_model.dart';
import 'package:files_manager/models/user_report_model.dart';
import 'package:meta/meta.dart';
@immutable
abstract class UserReportState {}

class UserReportInitial extends UserReportState {}
class UserReportLoadingState extends UserReportState {}
class UserReportLoadingUserState extends UserReportState {}
class UserReportSearchResultsState extends UserReportState {
  final List<Member> members;
  UserReportSearchResultsState(this.members);
}
class UserReportMemberSelectedState extends UserReportState {
  final Member member;
  UserReportMemberSelectedState(this.member);
}
class UserReportNoDataState extends UserReportState {}
class UserReportSuccessState extends UserReportState {
  final UserReportModel userReportModel;
  UserReportSuccessState({required this.userReportModel});
}
class UserReportFailureState extends UserReportState {
  final String errorMessage;
  UserReportFailureState({required this.errorMessage});
}