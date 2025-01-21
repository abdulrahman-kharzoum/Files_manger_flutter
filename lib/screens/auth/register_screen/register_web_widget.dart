import 'package:files_manager/core/functions/snackbar_function.dart';
import 'package:files_manager/core/functions/validate_input.dart';
import 'package:files_manager/cubits/auth/register_cubit/register_cubit.dart';
import 'package:files_manager/cubits/locale_cubit/locale_cubit.dart';
import 'package:files_manager/generated/l10n.dart';
import 'package:files_manager/theme/color.dart';
import 'package:files_manager/widgets/custom_text_fields/custom_button_widget.dart';
import 'package:files_manager/widgets/custom_text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterWebWidget extends StatelessWidget {
  const RegisterWebWidget(
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
          child: SizedBox(
            width: mediaQuery.width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: mediaQuery.height / 90),
                  Container(
                    // height: mediaQuery.height / 1.3,
                    width: mediaQuery.width / 3,
                    padding: EdgeInsets.symmetric(
                      horizontal: mediaQuery.width / 50,
                      vertical: mediaQuery.height / 90,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 44, 51, 55),
                      border:
                          Border.all(color: AppColors.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: mediaQuery.height / 90),
                        // Logo
                        SizedBox(
                          child: Image.asset(
                            'assets/icons/logo.png',
                            height: mediaQuery.height / 6,
                            // width: mediaQuery.width / 1.5,
                            // fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          S.of(context).sign_up,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: mediaQuery.width / 25,
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
                          height: mediaQuery.height / 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: const Duration(milliseconds: 300),
                )
                .fade(),
          ),
        ),
      ),
    );
  }
}
