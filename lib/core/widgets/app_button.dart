import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_spacing.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.padding,
  });

  factory AppButton.primary(
    String text, {
    Key? key,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
  }) =>
      AppButton(
        key: key,
        text: text,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        type: ButtonType.primary,
      );

  factory AppButton.outlined(
    String text, {
    Key? key,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
  }) =>
      AppButton(
        key: key,
        text: text,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        type: ButtonType.outlined,
      );

  factory AppButton.text(
    String text, {
    Key? key,
    VoidCallback? onPressed,
    IconData? icon,
  }) =>
      AppButton(
        key: key,
        text: text,
        onPressed: onPressed,
        icon: icon,
        type: ButtonType.text,
      );

  factory AppButton.danger(
    String text, {
    Key? key,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
  }) =>
      AppButton(
        key: key,
        text: text,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        type: ButtonType.danger,
      );

  @override
  Widget build(BuildContext context) {
    final disabled = isDisabled || isLoading || onPressed == null;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          _buildLoader()
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18),
            AppSpacing.boxWSM,
          ],
          Text(text),
        ],
      ],
    );

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: switch (type) {
        ButtonType.primary => ElevatedButton(
            onPressed: disabled ? null : onPressed,
            child: content,
          ),
        ButtonType.outlined => OutlinedButton(
            onPressed: disabled ? null : onPressed,
            child: content,
          ),
        ButtonType.text => TextButton(
            onPressed: disabled ? null : onPressed,
            child: content,
          ),
        ButtonType.danger => ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: content,
          ),
      },
    );
  }

  Widget _buildLoader() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: type == ButtonType.primary || type == ButtonType.danger
            ? AppColors.white
            : AppColors.primary,
      ),
    );
  }
}

enum ButtonType { primary, outlined, text, danger }

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final btnSize = size ?? 40;
    return Material(
      color: backgroundColor ?? AppColors.primaryLight,
      borderRadius: BorderRadius.circular(btnSize / 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(btnSize / 2),
        child: SizedBox(
          width: btnSize,
          height: btnSize,
          child: Icon(
            icon,
            size: btnSize * 0.5,
            color: iconColor ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}
