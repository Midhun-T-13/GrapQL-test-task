import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grapql_users_app/app_di.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../cubit/add_user/add_user_cubit.dart';
import '../cubit/add_user/add_user_state.dart';
import '../widgets/custom_header.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CustomHeader(title: 'Add New User', isBack: true,),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: AppTheme.topRoundedBorder,
                  ),
                  child: const _AddUserForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddUserForm extends StatelessWidget {
  const _AddUserForm();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    return BlocConsumer<AddUserCubit, AddUserState>(
      bloc: AppDi.addUserCubit,
      listener: (context, state) {
        if (state is AddUserSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            AppTheme.successSnackBar(
              'User ${state.user.name} created successfully!',
            ),
          );
            if (context.mounted) context.pop(true);
        }

        if (state is AddUserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            AppTheme.errorSnackBar(state.message),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AddUserLoading;

        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),

                CustomTextField(
                  controller: nameController,
                  label: 'Full Name',
                  hintText: 'John Doe',
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  validator: (value) => Validators.combine(value, [
                    (val) => Validators.required(val, 'Name'),
                    (val) => Validators.minLength(val, 3, 'Name'),
                  ]),
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  controller: usernameController,
                  label: 'Username',
                  hintText: 'johndoe',
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  validator: (value) => Validators.combine(value, [
                    (val) => Validators.required(val, 'Username'),
                    (val) => Validators.minLength(val, 3, 'Username'),
                    (val) => Validators.alphanumericWithUnderscore(val, 'Username'),
                  ]),
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  controller: emailController,
                  label: 'Email Address',
                  hintText: 'john.doe@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  validator: (value) => Validators.combine(value, [
                    (val) => Validators.required(val, 'Email'),
                    Validators.email,
                  ]),
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  hintText: '+1-234-567-8900',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  validator: (value) => Validators.combine(value, [
                        (val) => Validators.required(val, 'Phone'),
                    (val) => Validators.minLength(value, 10, "Phone Number"),
                    Validators.phone,

                  ]),
                ),

                SizedBox(height: 40.h),

                GradientButton(
                  text: 'Create User',
                  isLoading: isLoading,
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      AppDi.addUserCubit.createUser(
                        name: nameController.text.trim(),
                        username: usernameController.text.trim(),
                        email: emailController.text.trim(),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
