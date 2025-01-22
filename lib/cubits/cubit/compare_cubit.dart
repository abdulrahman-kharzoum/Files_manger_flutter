import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:js' as js;

import 'package:webview_flutter_plus/webview_flutter_plus.dart';
part 'compare_state.dart';

class CompareCubit extends Cubit<CompareState> {
  CompareCubit({required this.diffData}) : super(CompareInitial());
  String html = '';
  final String diffData;
  late WebViewControllerPlus controler;

  Future<void> setHtml() async {
    emit(CompareLoading());
    html = js.context.callMethod('getHtml', [diffData]) as String;
    print('the html is => $html');
    emit(CompareSuccess());
  }
}
