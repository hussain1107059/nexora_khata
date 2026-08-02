import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_spacing.dart';

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isDisabled || widget.isLoading || widget.onPressed == null;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          _buildLoader()
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18),
            AppSpacing.boxWSM,
          ],
          Text(widget.text),
        ],
      ],
    );

    return AnimatedScale(
      scale: _pressed && !disabled ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Listener(
        onPointerDown: (_) {
          if (!disabled) setState(() => _pressed = true);
        },
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: SizedBox(
          width: widget.width,
          height: widget.height ?? 48,
          child: switch (widget.type) {
            ButtonType.primary => ElevatedButton(
                onPressed: disabled ? null : widget.onPressed,
                child: content,
              ),
            ButtonType.outlined => OutlinedButton(
                onPressed: disabled ? null : widget.onPressed,
                child: content,
              ),
            ButtonType.text => TextButton(
                onPressed: disabled ? null : widget.onPressed,
                child: content,
              ),
            ButtonType.danger => ElevatedButton(
                onPressed: disabled ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: content,
              ),
          },
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: widget.type == ButtonType.primary || widget.type == ButtonType.danger
            ? AppColors.white
            : AppColors.primary,
      ),
    );
  }
}

enum ButtonType { primary, outlined, text, danger }

class AppIconButton extends StatefulWidget {
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
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final btnSize = widget.size ?? 40;
    return AnimatedScale(
      scale: _pressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: Material(
          color: widget.backgroundColor ?? AppColors.primaryLight,
          elevation: 0,
          borderRadius: BorderRadius.circular(btnSize / 2),
          child: InkWell(
            onTap: widget.onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: btnSize,
              height: btnSize,
              child: Icon(
                widget.icon,
                size: btnSize * 0.5,
                color: widget.iconColor ?? AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
