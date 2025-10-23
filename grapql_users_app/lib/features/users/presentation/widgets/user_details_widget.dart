import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grapql_users_app/core/theme/app_colors.dart';
import 'package:grapql_users_app/core/theme/app_theme.dart';
import 'package:grapql_users_app/features/users/domain/entities/user_entity.dart';


class UserDetailsWidget extends StatelessWidget {
  final UserEntity user;

  const UserDetailsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple600.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name.substring(0, 2).toUpperCase() : '??',
                style: AppTheme.avatarTextLarge,
              ),
            ),
          ),

           SizedBox(height: 20.h),

          Text(
            user.name,
            style: AppTheme.detailTitle,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          Text(
            '@${user.username}',
            style: AppTheme.detailSubtitle,
          ),

           SizedBox(height: 15.h),

          _InfoCard(
            icon: Icons.email_outlined,
            label: 'EMAIL',
            value: user.email,
          ),

          if (user.phone != null) ...[
             SizedBox(height: 12.h),
            _InfoCard(
              icon: Icons.phone_outlined,
              label: 'PHONE',
              value: user.phone!,
            ),
          ],

          if (user.website != null) ...[
             SizedBox(height: 12.h),
            _InfoCard(
              icon: Icons.language_outlined,
              label: 'WEBSITE',
              value: user.website!,
            ),
          ],

          if (user.companyName != null) ...[
             SizedBox(height: 12.h),
            _InfoCard(
              icon: Icons.business_outlined,
              label: 'COMPANY',
              value: user.companyName!,
            ),
          ],

          if (user.street != null ||
              user.suite != null ||
              user.city != null ||
              user.zipcode != null) ...[
             SizedBox(height: 12.h),
            _InfoCard(
              icon: Icons.location_on_outlined,
              label: 'ADDRESS',
              value: [
                if (user.street != null) user.street!,
                if (user.suite != null) user.suite!,
                if (user.city != null) user.city!,
                if (user.zipcode != null) user.zipcode!,
              ].join(', '),
            ),
          ],

        ],
      ),
    );
  }
}


class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppTheme.borderRadiusLarge,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.labelText,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.detailBody,
          ),
        ],
      ),
    );
  }
}
