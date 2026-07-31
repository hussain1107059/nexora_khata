import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_typography.dart';

enum AppTextType {
  heading1,
  heading2,
  heading3,
  heading4,
  heading5,
  heading6,
  subtitle1,
  subtitle2,
  body1,
  body2,
  caption,
  button,
  overline,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextType type;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;
  final double? height;

  const AppText(
    this.text, {
    super.key,
    this.type = AppTextType.body1,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.height,
  });

  factory AppText.heading1(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.heading1, color: color, textAlign: textAlign);

  factory AppText.heading2(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.heading2, color: color, textAlign: textAlign);

  factory AppText.heading3(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.heading3, color: color, textAlign: textAlign);

  factory AppText.heading4(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.heading4, color: color, textAlign: textAlign);

  factory AppText.subtitle1(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.subtitle1, color: color, textAlign: textAlign);

  factory AppText.subtitle2(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.subtitle2, color: color, textAlign: textAlign);

  factory AppText.body1(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.body1, color: color, textAlign: textAlign);

  factory AppText.body2(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.body2, color: color, textAlign: textAlign);

  factory AppText.caption(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.caption, color: color, textAlign: textAlign);

  factory AppText.button(String text, {Key? key, Color? color, TextAlign? textAlign}) =>
      AppText(text, key: key, type: AppTextType.button, color: color, textAlign: textAlign);

  @override
  Widget build(BuildContext context) {
    final style = _getStyle(context);
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  TextStyle _getStyle(BuildContext context) {
    final defaultColor = type == AppTextType.caption
        ? AppColors.textSecondary
        : AppColors.textPrimary;

    final baseStyle = switch (type) {
      AppTextType.heading1 => AppTypography.heading1,
      AppTextType.heading2 => AppTypography.heading2,
      AppTextType.heading3 => AppTypography.heading3,
      AppTextType.heading4 => AppTypography.heading4,
      AppTextType.heading5 => AppTypography.heading5,
      AppTextType.heading6 => AppTypography.heading6,
      AppTextType.subtitle1 => AppTypography.subtitle1,
      AppTextType.subtitle2 => AppTypography.subtitle2,
      AppTextType.body1 => AppTypography.bodyText1,
      AppTextType.body2 => AppTypography.bodyText2,
      AppTextType.caption => AppTypography.caption,
      AppTextType.button => AppTypography.button,
      AppTextType.overline => AppTypography.overline,
    };

    return baseStyle.copyWith(
      color: color ?? defaultColor,
      height: height,
    );
  }
}
