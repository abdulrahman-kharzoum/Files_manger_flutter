part of 'board_settings_cubit.dart';

@immutable
sealed class BoardSettingsState {}

final class BoardSettingsInitial extends BoardSettingsState {}

final class BoardSettingsLoadingState extends BoardSettingsState {}
final class BoardSettingsSaved extends BoardSettingsState {
  final Board newBoard;
  BoardSettingsSaved({required this.newBoard});
}


final class BoardSettingsSuccessState extends BoardSettingsState {}

final class BoardSettingsFailedState extends BoardSettingsState {
  final String errorMessage;
  BoardSettingsFailedState({required this.errorMessage});
}

final class BoardSettingsExpiredState extends BoardSettingsState {}

final class BoardSettingsChangeLanguage extends BoardSettingsState {}

