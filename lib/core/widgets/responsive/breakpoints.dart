import 'package:flutter/material.dart';

enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

abstract final class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobile) return ScreenSize.mobile;
    if (width < desktop) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobile &&
      MediaQuery.sizeOf(context).width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}
