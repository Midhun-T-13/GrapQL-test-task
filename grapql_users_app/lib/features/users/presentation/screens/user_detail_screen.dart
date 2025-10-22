import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grapql_users_app/features/users/presentation/widgets/user_details_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/user_detail/user_detail_cubit.dart';
import '../cubit/user_detail/user_detail_state.dart';
import '../widgets/custom_header.dart';
import '../widgets/error_widget.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          child: BlocConsumer<UserDetailCubit, UserDetailState>(
            listener: (context, state) {
              if (state is UserDetailUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  AppTheme.successSnackBar('User updated successfully!'),
                );
              }

              if (state is UserDetailUpdateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  AppTheme.errorSnackBar(state.message),
                );
              }
            },
            builder: (context, state) {
              Widget content;

              if (state is UserDetailLoading) {
                content = const Center(child: CircularProgressIndicator());
              } else if (state is UserDetailError) {
                content = ErrorDisplayWidget(message: state.message,);
              } else {
                final user = state is UserDetailDisplay
                    ? state.user
                    : state is UserDetailEditing
                        ? state.user
                        : state is UserDetailUpdateError
                            ? state.user
                            : state is UserDetailUpdating
                                ? state.user
                                : (state as UserDetailUpdateSuccess).user;

                content = UserDetailsWidget(user: user);
              }

              return Column(
                children: [
                  const CustomHeader(title: 'User Details',isBack:  true,),
                  Expanded(
                    child: _ContentContainer(child: content),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


class _ContentContainer extends StatelessWidget {
  final Widget child;

  const _ContentContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: AppTheme.topRoundedBorder,
      ),
      child: child,
    );
  }
}


