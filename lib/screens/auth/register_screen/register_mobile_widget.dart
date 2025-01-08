import 'package:files_manager/core/functions/snackbar_function.dart';
import 'package:files_manager/core/functions/validate_input.dart';
import 'package:files_manager/cubits/auth/login/login_cubit.dart';
import 'package:files_manager/cubits/auth/register_cubit/register_cubit.dart';
import 'package:files_manager/cubits/locale_cubit/locale_cubit.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/custom_text_fields/custom_button_widget.dart';
import '../../../widgets/custom_text_fields/custom_text_field.dart';


class RegisterMobileWidget extends StatelessWidget {
  const RegisterMobileWidget(
      {super.key,
        required this.localeCubit,
        required this.registerCubit,
        required this.validator,
        required this.showPassword});
  final RegisterCubit registerCubit;
  final Validate validator;
  final bool showPassword;
  final LocaleCubit localeCubit;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: mediaQuery.height,
      ),
      child: IntrinsicHeight(
        child: Form(
          key: registerCubit.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: mediaQuery.height / 9),
              // Logo
              SizedBox(
                child: Image.asset(
                  'assets/icons/logo.png',
                  height: mediaQuery.height / 5,
                  // width: mediaQuery.width / 1.5,
                  // fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: mediaQuery.height / 50),
              Text(
                S.of(context).sign_up,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: mediaQuery.width / 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: mediaQuery.height / 50),
              CustomFormTextField(
                keyboardType: TextInputType.text,
                controller: registerCubit.userNameController,
                colorIcon: Colors.grey,
                hintText: '',
                nameLabel: S.of(context).last_name,
                validator: validator.validateUsername,
              ),
              SizedBox(height: mediaQuery.height / 50),
              CustomFormTextField(
                keyboardType: TextInputType.emailAddress,
                controller: registerCubit.emailController,
                colorIcon: Colors.grey,
                hintText: 'email@example.com',
                nameLabel: S.of(context).email,
                validator: validator.validateEmail,
              ),
              SizedBox(height: mediaQuery.height / 50),
              CustomFormTextField(
                obscureText: showPassword,
                keyboardType: TextInputType.text,
                controller: registerCubit.passwordController,
                icon: showPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                colorIcon: Colors.grey,
                hintText: '******',
                nameLabel: S.of(context).password,
                onPressedIcon: () {
                  BlocProvider.of<RegisterCubit>(context)
                      .toggleShowPassword(!showPassword);
                },
                validator: validator.validatePassword,
              ),
              SizedBox(height: mediaQuery.height / 50),
              //ReEnter Password
              CustomFormTextField(
                obscureText: showPassword,
                keyboardType: TextInputType.text,
                controller: registerCubit.reEnterPasswordController,
                icon: showPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                colorIcon: Colors.grey,
                hintText: '******',
                nameLabel: S.of(context).re_password,
                onPressedIcon: () {
                  BlocProvider.of<RegisterCubit>(context)
                      .toggleShowPassword(!showPassword);
                },
                validator: validator.validateRePassword,
              ),
              SizedBox(height: mediaQuery.height / 50),
              SizedBox(
                width: mediaQuery.width / 3,
                height: mediaQuery.height / 15,
                child: ElevatedButton(
                  onPressed: () {
                    if (registerCubit.formKey.currentState!
                        .validate()) {
                      if (registerCubit
                          .reEnterPasswordController.text !=
                          registerCubit.passwordController.text) {
                        return showLightSnackBar(
                            context, S.of(context).password_must_match);
                      }
                      registerCubit.register(context: context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    S.of(context).sign_up,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: mediaQuery.width / 80,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: mediaQuery.height / 20,
              ),
              ElevatedButton(
                onPressed: () {
                  localeCubit.showLanguageDialog(context);
                },
                child: Text(
                  S.of(context).change_language,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(
                height: mediaQuery.height / 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
