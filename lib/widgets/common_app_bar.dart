import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextStyle? style;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPress;
  final bool? centerTitle;
  final double? elevation;
  final Widget? flexibleSpace;
  final Color? backgroundColor;

  const CommonAppBar({
    super.key,
    required this.title,
    this.style,
    this.actions,
    this.showBackButton = false,
    this.onBackPress,
    this.centerTitle,
    this.elevation,
    this.flexibleSpace,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style:
            style ??
            TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: theme.appBarTheme.foregroundColor,
              letterSpacing: 0.5,
            ),
      ),
      centerTitle: centerTitle ?? theme.appBarTheme.centerTitle,
      elevation: elevation ?? theme.appBarTheme.elevation,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      flexibleSpace: flexibleSpace,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: onBackPress ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
