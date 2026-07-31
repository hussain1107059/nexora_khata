import 'package:flutter/material.dart';
import 'breakpoints.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width;
    if (size >= Breakpoints.desktop && desktop != null) {
      return desktop!;
    }
    if (size >= Breakpoints.mobile && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

class AdaptivePadding extends StatelessWidget {
  final Widget child;

  const AdaptivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= Breakpoints.desktop
        ? 64.0
        : width >= Breakpoints.mobile
            ? 32.0
            : 16.0;
    final vertical = width >= Breakpoints.desktop ? 32.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ),
      child: child,
    );
  }
}

class ConstrainedContent extends StatelessWidget {
  final Widget child;

  const ConstrainedContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: child,
      ),
    );
  }
}
