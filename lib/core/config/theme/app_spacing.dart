import 'package:flutter/material.dart';

abstract final class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  static const double massive = 64;

  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusCircular = 100;

  static const double elevationNone = 0;
  static const double elevationSm = 1;
  static const double elevationMd = 2;
  static const double elevationLg = 4;
  static const double elevationXl = 8;

  // Static const EdgeInsets for reuse
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  static const EdgeInsets paddingHSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets paddingVSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVXl = EdgeInsets.symmetric(vertical: xl);

  static const EdgeInsets paddingHVLg = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  static const EdgeInsets paddingHVXl = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(xl);

  // SizedBox helpers
  static const SizedBox boxXXS = SizedBox(width: xxs, height: xxs);
  static const SizedBox boxXS = SizedBox(width: xs, height: xs);
  static const SizedBox boxSM = SizedBox(width: sm, height: sm);
  static const SizedBox boxMD = SizedBox(width: md, height: md);
  static const SizedBox boxLG = SizedBox(width: lg, height: lg);
  static const SizedBox boxXL = SizedBox(width: xl, height: xl);
  static const SizedBox boxXXL = SizedBox(width: xxl, height: xxl);
  static const SizedBox boxHuge = SizedBox(width: huge, height: huge);

  static const SizedBox boxWXS = SizedBox(width: xs);
  static const SizedBox boxWSM = SizedBox(width: sm);
  static const SizedBox boxWMD = SizedBox(width: md);
  static const SizedBox boxWLG = SizedBox(width: lg);
  static const SizedBox boxWXL = SizedBox(width: xl);

  static const SizedBox boxHXS = SizedBox(height: xs);
  static const SizedBox boxHSM = SizedBox(height: sm);
  static const SizedBox boxHMD = SizedBox(height: md);
  static const SizedBox boxHLG = SizedBox(height: lg);
  static const SizedBox boxHXL = SizedBox(height: xl);
  static const SizedBox boxHXXL = SizedBox(height: xxl);
  static const SizedBox boxHXXXL = SizedBox(height: xxxl);
  static const SizedBox boxHHuge = SizedBox(height: huge);
  static const SizedBox boxHMassive = SizedBox(height: massive);
}
