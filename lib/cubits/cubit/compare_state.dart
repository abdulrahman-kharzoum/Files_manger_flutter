part of 'compare_cubit.dart';

@immutable
sealed class CompareState {}

final class CompareInitial extends CompareState {}

final class CompareLoading extends CompareState {}

final class CompareSuccess extends CompareState {}
