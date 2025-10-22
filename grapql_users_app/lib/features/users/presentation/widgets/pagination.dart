import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/user_list/user_list_cubit.dart';
import '../cubit/user_list/user_list_state.dart';

class PaginationControls extends StatelessWidget {
  final UserListLoaded state;

  const PaginationControls({super.key, required this.state});


  List<Widget> _buildPageNumbers(BuildContext context) {
    final List<Widget> widgets = [];
    final currentPage = state.currentPage;
    final totalPages = state.totalPages;

    widgets.add(
      _PageNumber(
        number: 1,
        isActive: currentPage == 1,
        onTap: () => context.read<UserListCubit>().goToPage(1),
      ),
    );

    if (currentPage > 3) {
      widgets.add(const _Dots());
    }

    List<int> middlePages = [];

    if (currentPage <= 3) {
      middlePages = [2, 3];
    } else if (currentPage >= totalPages - 2) {
      middlePages = [totalPages - 2, totalPages - 1];
    } else {
      middlePages = [currentPage];
    }

    for (final page in middlePages) {
      if (page > 1 && page < totalPages) {
        widgets.add(
          _PageNumber(
            number: page,
            isActive: currentPage == page,
            onTap: () => context.read<UserListCubit>().goToPage(page),
          ),
        );
      }
    }

    if (currentPage < totalPages - 2) {
      widgets.add(const _Dots());
    }

    if (totalPages > 1) {
      widgets.add(
        _PageNumber(
          number: totalPages,
          isActive: currentPage == totalPages,
          onTap: () => context.read<UserListCubit>().goToPage(totalPages),
        ),
      );
    }

    return widgets;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PaginationButton(
            icon: Icons.chevron_left,
            onPressed: state.hasPreviousPage
                ? () => context.read<UserListCubit>().previousPage()
                : null,
          ),

          SizedBox(width: 12.w),

          ..._buildPageNumbers(context),

          SizedBox(width: 12.w),

          _PaginationButton(
            icon: Icons.chevron_right,
            onPressed: state.hasNextPage
                ? () => context.read<UserListCubit>().nextPage()
                : null,
          ),
        ],
      ),
    );
  }
}
class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: AppTheme.bodyMedium,
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PaginationButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.h,
      height: 40.h,
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.white : Colors.grey[200],
        borderRadius: AppTheme.borderRadiusSmall,
      ),
      child: IconButton(
        highlightColor: Colors.transparent,
        icon: Icon(
          icon,
          size: 20.sp,
          color: onPressed != null ? AppColors.purple600 : AppColors.textHint,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool isActive;
  final VoidCallback onTap;

  const _PageNumber({
    required this.number,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          )
              : null,
          color: isActive ? null : AppColors.backgroundLight,
          borderRadius: AppTheme.borderRadiusSmall,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: isActive
                ? AppTheme.paginationActive
                : AppTheme.paginationInactive,
          ),
        ),
      ),
    );
  }
}