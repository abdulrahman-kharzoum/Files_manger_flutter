import 'package:files_manager/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/cubit/compare_cubit.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compareCubit = context.read<CompareCubit>();
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<CompareCubit, CompareState>(
        listener: (context, state) {},
        builder: (context, state) {
          return state is CompareSuccess
              ? Container(
                  // height: mediaQuery.height,
                  margin: EdgeInsets.symmetric(
                      horizontal: mediaQuery.width / 130,
                      vertical: mediaQuery.height / 50),

                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InAppWebView(
                    initialData: InAppWebViewInitialData(data: '''
                    <!DOCTYPE html>
                    <html lang="en">
                    <head>
                      <meta name="viewport" content="width=device-width, initial-scale=1.0">
                      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/diff2html/bundles/css/diff2html.min.css">
                    </head>
                    <body>
                     ${compareCubit.html}
                    </body>
                    </html>
                  '''),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        supportZoom: false,
                        javaScriptEnabled: true,
                        disableHorizontalScroll: false,
                        disableVerticalScroll: true,
                      ),
                    ),
                    onLoadError: (controller, url, code, message) =>
                        print("onLoadError: $url, $code, $message"),
                    onLoadHttpError:
                        (controller, url, statusCode, description) => print(
                            "onLoadHttpError: $url, $statusCode, $description"),
                    onConsoleMessage: (controller, consoleMessage) {},
                  ),
                )
              : Text('no data');
        },
      ),
    );
  }
}
