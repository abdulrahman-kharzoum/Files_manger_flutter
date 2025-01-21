import 'package:files_manager/core/functions/statics.dart';
import 'package:files_manager/cubits/auth/register_cubit/register_cubit.dart';

import 'package:files_manager/screens/auth/register_screen/register_mobile_widget.dart';
import 'package:files_manager/screens/auth/register_screen/register_web_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:files_manager/core/animation/dialogs/dialogs.dart';
import 'package:files_manager/core/functions/validate_input.dart';

import 'package:files_manager/cubits/locale_cubit/locale_cubit.dart';
import 'package:files_manager/theme/color.dart';

import '../../../core/functions/snackbar_function.dart';
import '../../../generated/l10n.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  void _closeLoadingDialog(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final validator = Validate(context: context);
    final localeCubit = context.read<LocaleCubit>();
    final registerCubit = context.read<RegisterCubit>();
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterLoadingState) {
          loadingDialog(context: context, mediaQuery: mediaQuery);
        } else if (state is RegisterSuccessState) {
          showLightSnackBar(context, S.of(context).register_success_message);

          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login_screen',
                (route) => false,
          );

        } else if (state is RegisterFailureState) {
          errorDialog(context: context, text: state.errorMessage);
        }
      },
      builder: (context, state) {
        bool showPassword = state is ShowPassword ? state.show : true;
        return Scaffold(
          backgroundColor: AppColors.dark,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.dark,
            toolbarHeight: 1,
          ),
          body: Stack(
            children: [
              Positioned(
                right: mediaQuery.width / 30,
                top: 3,
                child: Opacity(
                  opacity: 0.08,
                  child: const Image(
                    image: AssetImage('assets/images/circles.png'),
                  ),
                ),
              ),
              Positioned(
                left: mediaQuery.width / 30,
                bottom: mediaQuery.height / 20,
                child: Opacity(
                  opacity: 0.08,
                  child: const Image(
                    image: AssetImage('assets/images/circles.png'),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding:
                EdgeInsets.symmetric(horizontal: mediaQuery.height / 20),
                child: Statics.isPlatformDesktop
                    ? RegisterWebWidget(
                    localeCubit: localeCubit,
                    registerCubit: registerCubit,
                    validator: validator,
                    showPassword: showPassword)
                    : RegisterMobileWidget(
                    localeCubit: localeCubit,
                    registerCubit: registerCubit,
                    validator: validator,
                    showPassword: showPassword),
              ).animate().fade(
                duration: const Duration(milliseconds: 500),
              ),
            ],
          ),
        );
      },
    );
  }
}
