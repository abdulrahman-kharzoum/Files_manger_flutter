import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'pending_state.dart';

class PendingCubit extends Cubit<PendingState> {
  PendingCubit() : super(PendingInitial());
}
