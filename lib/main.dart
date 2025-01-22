import 'package:files_manager/core/notification/notification_web.dart';
import 'package:files_manager/core/shared/local_network.dart';
import 'package:files_manager/core/functions/statics.dart';
import 'package:files_manager/cubits/notification_cubit/notification_cubit.dart';

import 'package:files_manager/cubits/theme_cubit/app_theme_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../cubits/all_boards_cubit/all_boards_cubit.dart';
import '../cubits/board_favorite_cubit/board_favorite_cubit.dart';
import '../cubits/locale_cubit/locale_cubit.dart';
import '../generated/l10n.dart';
import '../simple_bloc_observer.dart';
import '../theme/theme.dart';
import 'cubits/file_report_cubit/file_report_cubit.dart';

import 'cubits/user_report_cubit/user_report_cubit.dart';
import 'routes/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CashNetwork.cashInitialization();
  await Hive.initFlutter();
  await Hive.openBox('main');
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAAIBojjbALrA0QcbWuNU7c6mHbdy6noiU",
        authDomain: "flutter-1cda7.firebaseapp.com",
        databaseURL: "https://flutter-1cda7-default-rtdb.firebaseio.com",
        projectId: "flutter-1cda7",
        storageBucket: "flutter-1cda7.firebasestorage.app",
        messagingSenderId: "838693518963",
        appId: "1:838693518963:web:0f5a0eee9a2a64803eb406",
        measurementId: "G-JY8BYQKVCK"),
  );
  final notificationCubit = NotificationCubit();
  final notificationService = NotificationService(notificationCubit);
  notificationService.initialize();
  // final notificationService = NotificationService();
  // // await notificationService.listenNotifications();
  print("==========fcm==========");
  print(await notificationService.getToken());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Bloc.observer = SimpleBlocObserver();
  runApp(
    Phoenix(child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (context) => LocaleCubit()..initializeLocale(),
        ),
        BlocProvider<AppThemeCubit>(
          create: (context) => AppThemeCubit(),
        ),
        BlocProvider<AllBoardsCubit>(
          create: (context) => AllBoardsCubit(),
        ),
        BlocProvider<AllBoardsCubit>(
          create: (context) => AllBoardsCubit(),
        ),
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(),
        ),
        BlocProvider<BoardFavoriteCubit>(
          create: (context) => BoardFavoriteCubit(),
        ),
        BlocProvider(create: (context) => FileReportCubit()),
        BlocProvider(create: (context) => UserReportCubit()),
      ],
      child: BlocConsumer<LocaleCubit, LocaleState>(
        listener: (context, state) {
          if (state is ChangeLocaleState) {}
        },
        builder: (context, state) {
          final localCubit = context.read<LocaleCubit>();
          final mediaQuery = MediaQuery.of(context).size;
          Statics.isPlatformDesktop = mediaQuery.width > 700;
          return BlocBuilder<AppThemeCubit, AppThemeState>(
            builder: (themeContext, themeState) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Files Manager App',
                initialRoute: '/',
                routes: routes,
                theme:
                    themeState is AppThemeDark ? DarkThemeData : LightThemeData,
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                locale: localCubit.locale,
                navigatorKey: navigatorKey,
              );
            },
          );
        },
      ),
    );
  }
}
