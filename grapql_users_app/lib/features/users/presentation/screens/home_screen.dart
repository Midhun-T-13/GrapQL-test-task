import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grapql_users_app/app_di.dart';
import 'package:grapql_users_app/core/routing/app_router.dart';
import 'package:grapql_users_app/features/users/domain/usecases/get_user_by_id.dart';
import 'package:grapql_users_app/features/users/presentation/widgets/custom_header.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/user_list/user_list_cubit.dart';
import '../cubit/user_list/user_list_state.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/pagination.dart';
import '../widgets/user_card_shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: AppTheme.primaryGradientDecoration,
          child: Column(
            children: [
              CustomHeader(title: 'User List'),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: AppTheme.topRoundedBorder,
                  ),
                  child: BlocBuilder<UserListCubit, UserListState>(
                    builder: (context, state) {
                      if (state is UserListInitial) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          AppDi.userListCubit.loadPage(1);
                        });
                        return const UserListShimmer();
                      }
                      if (state is UserListLoading) {
                        return const UserListShimmer();
                      }
                      if (state is UserListError) {
                        return ErrorDisplayWidget(
                          message: state.message,
                          onRetry: () =>
                             AppDi.userListCubit.loadPage(1, forceRefresh: true),
                        );
                      }
                      if (state is UserListLoaded) {
                        if (state.users.isEmpty) {
                          return const EmptyStateWidget(
                            message: 'No users found',
                            icon: Icons.people_outline,
                          );
                        }
                        return Column(
                          children: [
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () => AppDi.userListCubit
                                    .refreshUsers(),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(20.w),
                                  itemCount: state.users.length,
                                  itemBuilder: (context, index) {
                                    final user = state.users[index];
                                    return GestureDetector(
                                      onTap: () {
                                        context.push(
                                          '${AppRouter.userDetail}/${user.id}',
                                        );
                                        AppDi.userDetailCubit.loadUser(user.id);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          bottom: 16.h,
                                        ),
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: AppTheme.borderRadiusLarge,
                                          boxShadow: AppTheme.cardShadow,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 56.w,
                                              height: 56.h,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: AppColors.primaryGradient,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14.r),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  user.name.isNotEmpty
                                                      ? user.name
                                                            .substring(0, 2)
                                                            .toUpperCase()
                                                      : '??',
                                                  style: AppTheme.avatarText,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user.name,
                                                    style: AppTheme.cardTitle,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    '@${user.username}',
                                                    style: AppTheme.cardSubtitle,
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.email_outlined,
                                                        size: 14.sp,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                      SizedBox(width: 6.w),
                                                      Expanded(
                                                        child: Text(
                                                          user.email,
                                                          style: AppTheme.cardBody,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (user.phone != null) ...[
                                                    SizedBox(height: 4.h),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.phone_outlined,
                                                          size: 14.sp,
                                                          color: AppColors.textSecondary,
                                                        ),
                                                        SizedBox(
                                                          width: 6.w,
                                                        ),
                                                        Text(
                                                          user.phone!,
                                                          style: AppTheme.cardBody,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            PaginationControls(state: state,)
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<UserListCubit, UserListState>(
        builder: (context, state) {
          if(state is UserListError){
            return SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: FloatingActionButton(
                splashColor: Colors.transparent,
                onPressed: ()async{
                  final result = await context.push(AppRouter.addUser);
                  if (result == true && context.mounted) {
                    AppDi.userListCubit.refreshUsers();
                  }
                },
                backgroundColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightElevation: 0,
                elevation: 0,
                child: const Icon(Icons.add, color: AppColors.textWhite),
              ),
            ),
          );
        }
      ),
    );
  }
}



