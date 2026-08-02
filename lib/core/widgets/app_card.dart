import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;
  final Decoration? decoration;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.boxShadow,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    if (onTap == null && onLongPress == null) {
      return Container(
        margin: margin,
        decoration: decoration ?? _defaultDecoration(),
        child: Padding(
          padding: padding ?? AppSpacing.cardPadding,
          child: child,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: decoration ?? _defaultDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius is BorderRadius
            ? effectiveBorderRadius
            : BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: effectiveBorderRadius is BorderRadius
              ? effectiveBorderRadius
              : BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }

  BoxDecoration _defaultDecoration() {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.cardBackground,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg),
      border: Border.all(color: AppColors.divider, width: 1),
      boxShadow: boxShadow ?? const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 12,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}

class AppCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  const AppCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? AppSpacing.cardPadding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            AppSpacing.boxWMD,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  AppSpacing.boxHXS,
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class AppCardDivider extends StatelessWidget {
  final EdgeInsetsGeometry? padding;

  const AppCardDivider({super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: const Divider(height: 1),
    );
  }
}
