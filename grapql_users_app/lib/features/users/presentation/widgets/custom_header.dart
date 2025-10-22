import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool? isBack;
   const CustomHeader({super.key, required this.title, this.isBack = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isBack! ?
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textWhite,
              size: 24.sp,
            ),
            onPressed: () => context.pop(),
          ) : SizedBox(width: 40.w,),
          Text(
            title,
            style: AppTheme.heading1,
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}
